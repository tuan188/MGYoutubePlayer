//
//  YoutubePlayerViewModel.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/28/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import AVFoundation
import MediaPlayer

enum YoutubePlayer {
    enum Status: Int {
        case paused
        case waiting
        case playing
    }
    
    enum SeekState: Int {
        case none
        case begin
        case seeking
        case end
    }
}

final class YoutubePlayerViewModel {
    struct Input {
        let audioUrl: Driver<String>
        let coverImageUrl: Driver<String>
        let play: Driver<Void>
        let stop: Driver<Void>
        let seek: Driver<TimeInterval>
        let seekState: Driver<YoutubePlayer.SeekState>
    }
    
    struct Output {
        let coverImageUrl: Driver<URL>
        let duration: Driver<TimeInterval>
        let currentTime: Driver<TimeInterval>
        let endTime: Driver<TimeInterval>
        let downloadedProgress: Driver<Float>
        let status: Driver<YoutubePlayer.Status>
        let play: Driver<Void>
        let seek: Driver<Void>
        let stop: Driver<Void>
        let scheduleNextBuffer: Driver<Void>
        let isPlayable: Driver<Bool>
        let isLoading: Driver<Bool>
    }
    
    let audioUrl: String?
    let coverImageUrl: String?
    
    private let player = AVPlayer()
    private var statusObservation: NSKeyValueObservation?
    private var timeControlStatusObservation: NSKeyValueObservation?
    private var timeObserver: Any?
    private var durationObservation: NSKeyValueObservation?
    
    private let errorSubject = PublishSubject<Error>()
    private let downloadedProgressSubject = PublishSubject<Float>()
    private let statusSubject = PublishSubject<YoutubePlayer.Status>()
    private let currentTimeSubject = PublishSubject<TimeInterval>()
    private let seekStateSubject = PublishSubject<YoutubePlayer.SeekState>()
    private let durationSubject = PublishSubject<Double>()
    private let loadingSubject = PublishSubject<Bool>()
    
    init(audioUrl: String?, coverImageUrl: String?) {
        self.audioUrl = audioUrl
        self.coverImageUrl = coverImageUrl
        
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 100),
            queue: DispatchQueue.main) { [weak self] (currentTime) in
                self?.currentTimeSubject.onNext(currentTime.seconds)
                
//                if let buffer = self?.player.currentItem?.currentBuffer(),
//                    let duration = self?.player.currentItem?.duration {
//                    self?.downloadedProgressSubject
//                        .onNext(Float((buffer + currentTime.seconds) / duration.seconds))
//                }
        }
        
        timeControlStatusObservation = player.observe(\.timeControlStatus) { [weak self] (player, _) in
            guard let status = YoutubePlayer.Status(rawValue: player.timeControlStatus.rawValue) else { return }
            self?.statusSubject.onNext(status)
        }
    }
    
    deinit {
        print("Audio ViewModel deinit")
        
        timeControlStatusObservation?.invalidate()
        timeControlStatusObservation = nil
        
        durationObservation?.invalidate()
        durationObservation = nil
        
        if let observer = self.timeObserver {
            player.removeTimeObserver(observer)
        }
    }
    
    func transform(_ input: Input) -> Output {
        let coverImageUrl = input.coverImageUrl
            .mapToOptional()
            .startWith(self.coverImageUrl)
            .map { $0.flatMap { URL(string: $0) } }
            .unwrap()
        
        let audioUrl = input.audioUrl
            .mapToOptional()
            .startWith(self.audioUrl)
            .map { $0.flatMap { URL(string: $0) } }
            .unwrap()
        
        let scheduleNextBuffer = audioUrl
            .do(onNext: { [weak self] url in
                let playerItem = AVPlayerItem(url: url)
                playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
                
                self?.durationObservation?.invalidate()
                self?.durationObservation = nil
                self?.observeDuration(of: playerItem)
                
                self?.player.replaceCurrentItem(with: playerItem)
                //                self?.player.automaticallyWaitsToMinimizeStalling = false
                
                self?.loadingSubject.onNext(true)
            })
            .mapToVoid()
        
        let playerStatus = statusSubject
            .asDriverOnErrorJustComplete()
            .startWith(.paused)
        
        let duration = durationSubject
            .asDriverOnErrorJustComplete()
            .do(onNext: { [weak self] _ in
                self?.loadingSubject.onNext(false)
            })
            .startWith(0.0)
        
        let seekState = Driver.merge(input.seekState, seekStateSubject.asDriverOnErrorJustComplete())
            .startWith(.none)
        
        let currentPlayingTime: Driver<TimeInterval> = currentTimeSubject
            .asDriverOnErrorJustComplete()
            .withLatestFrom(seekState) { ($0, $1) }
            .filter { _, seekState in
                seekState == YoutubePlayer.SeekState.none || seekState == YoutubePlayer.SeekState.end
        }
        .map { time, _ -> TimeInterval in time }
        .startWith(0.0)
        
        let seekingTime = input.seek
        
        let currentTime = Driver.merge(currentPlayingTime, seekingTime)
        
        let endTime = Driver.combineLatest(duration, currentTime) {
            $0 - $1
        }
        
        func seekTo(time: TimeInterval) {
            let timescale = player.currentItem?.asset.duration.timescale ?? 1
            
            player.seek(
                to: CMTime(seconds: time, preferredTimescale: timescale),
                completionHandler: { [weak self] _ in
                    after(interval: 0.1) {
                        self?.seekStateSubject.onNext(.end)
                    }
            })
        }
        
        let seek = seekState
            .filter { $0 == .seeking }
            .withLatestFrom(seekingTime)
            .do(onNext: { seekingTime in
                seekTo(time: seekingTime)
            })
            .mapToVoid()
        
        let downloadedProgress = downloadedProgressSubject
            .asDriverOnErrorJustComplete()
        
        let play = input.play
            .withLatestFrom(Driver.combineLatest(duration, currentTime, playerStatus.asDriver()))
            .do(onNext: { [weak self] duration, currentTime, status in
                self?.player.pause()
                if abs(currentTime - duration) < 0.1 {
                    seekTo(time: 0.0)
                }
                
                switch status {
                case .paused:
                    self?.player.play()
                default:
                    break
                }
            })
            .mapToVoid()
        
        let stop = input.stop
            .do(onNext: { [weak self] in
                self?.player.pause()
            })
        
        let isPlayable = duration
            .map { $0 > 0.0 }
            .startWith(false)
        
        let isLoading = Driver.merge(loadingSubject.asDriverOnErrorJustComplete(),
                                     playerStatus.map { $0 == YoutubePlayer.Status.waiting })
        
        return Output(
            coverImageUrl: coverImageUrl,
            duration: duration,
            currentTime: currentTime,
            endTime: endTime,
            downloadedProgress: downloadedProgress,
            status: playerStatus,
            play: play,
            seek: seek,
            stop: stop,
            scheduleNextBuffer: scheduleNextBuffer,
            isPlayable: isPlayable,
            isLoading: isLoading
        )
    }
}

enum YoutubePlayerError: Error {
    case invalidDuration
}

extension YoutubePlayerViewModel {
    
    func observeDuration(of playerItem: AVPlayerItem) {
        durationObservation = playerItem.observe(\.duration, changeHandler: { [weak self] (item, _) in
            let duration = item.asset.duration.seconds
            
            if !duration.isNaN,
                !duration.isZero {
                self?.durationSubject.onNext(duration)
            }
        })
    }
}
