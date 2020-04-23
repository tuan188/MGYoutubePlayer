//
//  AudioPlayer.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/20/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import AVFoundation
import MediaPlayer

final class AudioPlayer: NSObject {
    enum State {
        case unknown
        case paused
        case waiting
        case playing
    }
    
    // MARK: - Public properties
    
    private(set) var player = AVPlayer()
    private(set) var audio: Audio?
    
    var playTime: Double {
        return _playTime.value
    }
    
    var state: AudioPlayer.State {
        return _state.value
    }
    
    var duration: Double {
        return _duration.value
    }
    
    var remainingTime: Double {
        return _remainingTime.value
    }
    
    var isReady: Bool {
        return _isReady.value
    }
    
    var loadedFraction: Double {
        return _loadedFraction.value
    }
    
    var isPlaying: Bool {
        let state = self.state
        return state == .playing || state == .waiting
    }
    
    var isActive: Bool {
        let state = self.state
        return state == .playing
            || state == .waiting
            || (state == .paused && playTime > 0)
    }
    
    // MARK: - Private properties
    
    fileprivate let _state = BehaviorRelay(value: AudioPlayer.State.unknown)
    fileprivate let _playTime = BehaviorRelay(value: Double.zero)
    fileprivate let _duration = BehaviorRelay(value: Double.zero)
    fileprivate let _remainingTime = BehaviorRelay(value: Double.zero)
    fileprivate let _error = PublishSubject<Error>()
    fileprivate let _isReady = BehaviorRelay(value: false)
    fileprivate let _loadedFraction = BehaviorRelay(value: Double.zero)
    
    private var statusObservation: NSKeyValueObservation?
    private var timeControlStatusObservation: NSKeyValueObservation?
    private var timeObserver: Any?
    private var durationObservation: NSKeyValueObservation?
    
    override init() {
        super.init()
        
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 100),
            queue: DispatchQueue.main) { [weak self] (currentTime) in
                guard let self = self else { return }
                
                self._playTime.accept(currentTime.seconds)
                
                if let buffer = self.player.currentItem?.currentBuffer(),
                    let duration = self.player.currentItem?.duration.seconds,
                    !duration.isNaN {
                    
                    self._loadedFraction.accept((buffer + currentTime.seconds) / duration)
                    self._remainingTime.accept(duration - currentTime.seconds)
                }
        }
        
        timeControlStatusObservation = player.observe(\.timeControlStatus) { [weak self] (player, _) in
            let state: AudioPlayer.State
            
            switch player.timeControlStatus {
            case .waitingToPlayAtSpecifiedRate:
                state = .waiting
            case .playing:
                state = .playing
            default:
                state = .paused
            }
            
            self?._state.accept(state)
        }
    }
    
    deinit {
        print("AudioPlayer deinit")
        
        timeControlStatusObservation?.invalidate()
        timeControlStatusObservation = nil
        
        durationObservation?.invalidate()
        durationObservation = nil
        
        if let observer = self.timeObserver {
            player.removeTimeObserver(observer)
        }
    }
    
    func load(audio: Audio) {
        guard let url = URL(string: audio.url) else { return }
        resetStats()
        self.audio = audio
        
        let playerItem = AVPlayerItem(url: url)
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        
        durationObservation?.invalidate()
        durationObservation = playerItem.observe(\.duration, changeHandler: { [weak self] (item, _) in
            let duration = item.asset.duration.seconds
            
            if !duration.isNaN,
                !duration.isZero {
                self?._duration.accept(duration)
                self?._isReady.accept(true)
            } else {
                self?._isReady.accept(false)
            }
        })
        
        player.replaceCurrentItem(with: playerItem)
//        player.automaticallyWaitsToMinimizeStalling = false
    }
    
    func resetStats() {
        _playTime.accept(0)
        _duration.accept(0)
        _state.accept(.unknown)
        _isReady.accept(false)
        _remainingTime.accept(0)
    }
    
    func play() {
        guard duration > 0 else { return }
        
        if Int(remainingTime) > 0 {
            player.play()
        } else {
            seek(to: 0) { [weak self] (_) in
                self?.player.play()
            }
        }
    }
    
    func stop() {
        resetStats()
        seek(to: 0) { [weak self] (_) in
            self?.player.pause()
        }
    }
    
    func pause() {
        player.pause()
    }
    
    func seek(to seconds: Double, completion: ((Bool) -> Void)? = nil) {
        let timescale = player.currentItem?.asset.duration.timescale ?? 1
        
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: timescale)) {
            completion?($0)
        }
    }
}

enum AudioPlayerError: Error {
    case unknown
}

// MARK: - Reactive
extension Reactive where Base: AudioPlayer {
    var state: Driver<AudioPlayer.State> {
        return self.base._state.asDriver(onErrorJustReturn: .unknown)
    }
    
    var playTime: Driver<Double> {
        return self.base._playTime.asDriver(onErrorJustReturn: 0.0)
    }
    
    var duration: Driver<Double> {
        return self.base._duration.asDriver(onErrorJustReturn: 0.0)
    }
    
    var remainingTime: Driver<Double> {
        return self.base._remainingTime.asDriver(onErrorJustReturn: 0.0)
    }
    
    var error: Driver<Error> {
        return self.base._error.asDriver(onErrorJustReturn: AudioPlayerError.unknown)
    }
    
    var isReady: Driver<Bool> {
        return self.base._isReady.asDriver(onErrorJustReturn: false)
    }
    
    var loadedFraction: Driver<Double> {
        return self.base._loadedFraction.asDriver(onErrorJustReturn: 0.0)
    }
    
    var isPlaying: Driver<Bool> {
        return self.base._state
            .map { $0 == AudioPlayer.State.playing || $0 == AudioPlayer.State.waiting }
            .asDriver(onErrorJustReturn: false)
    }
}
