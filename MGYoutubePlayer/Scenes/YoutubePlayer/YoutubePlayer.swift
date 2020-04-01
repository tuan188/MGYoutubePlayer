//
//  YoutubePlayer.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/28/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView
import RxSwift
import RxCocoa

class YoutubePlayer: NSObject {  // swiftlint:disable:this final_class
    
    enum State {
        case unstarted
        case ended
        case playing
        case paused
        case buffering
        case queued
        case unknow
    }
    
    private var playerView: WKYTPlayerView?
    private var superView: UIView?
    private var timer: Timer?
    
    // MARK: - Public properties
    
    private let _state = BehaviorSubject(value: YoutubePlayer.State.unstarted)
    
    var state: Driver<YoutubePlayer.State> {
        return _state.asDriver(onErrorJustReturn: .unknow)
    }
    
    private let _playTime = BehaviorSubject(value: Float(0.0))
    
    var playTime: Driver<Float> {
        return _playTime.asDriver(onErrorJustReturn: 0.0)
    }
    
    private let _duration = BehaviorSubject(value: Float(0.0))
    
    var duration: Driver<Float> {
        return _duration.asDriver(onErrorJustReturn: 0.0)
    }
    
    private let _progress = BehaviorSubject(value: Float(0.0))
    
    var progress: Driver<Float> {
        return _progress.asDriver(onErrorJustReturn: 0.0)
    }
    
    private let _remainingTime = BehaviorSubject(value: Float(0.0))
    
    var remainingTime: Driver<Float> {
        return _remainingTime.asDriver(onErrorJustReturn: 0.0)
    }
    
    private let _error = PublishSubject<Error>()
    
    var error: Driver<Error> {
        return _error.asDriverOnErrorJustComplete()
    }
    
    private let _isReady = BehaviorSubject(value: false)
    
    var isReady: Driver<Bool> {
        return _isReady.asDriver(onErrorJustReturn: false)
    }
    
    private let _loadedFraction = BehaviorSubject(value: Float(0.0))
    
    var loadedFraction: Driver<Float> {
        return _loadedFraction.asDriver(onErrorJustReturn: 0.0)
    }
    
    // MARK: - Methods
    
    deinit {
        timer?.invalidate()
    }
    
    func addPlayer(to view: UIView) {
        let player = WKYTPlayerView(frame: view.bounds)
        player.delegate = self
        view.addSubview(player)
        
        playerView = player
        superView = view
    }
    
    func load(videoId: String) {
        _playTime.onNext(0)
        _duration.onNext(0)
        _state.onNext(.unstarted)
        _isReady.onNext(false)
        _progress.onNext(0)
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
            self?.playerView?.getVideoLoadedFraction({ (fraction, error) in
                if let error = error {
                    print(error)
                } else {
                    print(fraction)
                    self?._loadedFraction.onNext(fraction)
                }
            })
        })
        
        playerView?.load(withVideoId: videoId, playerVars: [
            "controls": 0,
            "playsinline": 1,
            "autohide": 1,
            "showinfo": 0,
            "modestbranding": 1
        ])
    }
    
    func play() {
        playerView?.playVideo()
    }
    
    func stop() {
        playerView?.stopVideo()
    }
    
    func pause() {
        playerView?.pauseVideo()
    }
    
    func bingPlayerToFront() {
        guard let playerView = playerView else { return }
        superView?.bringSubviewToFront(playerView)
    }
    
    private func getDuration(for playerView: WKYTPlayerView, playTime: Float = 0.0) {
        playerView.getDuration({ [weak self] (time, error) in
            if let error = error {
                self?._error.onNext(error)
            } else {
                self?._playTime.onNext(playTime)
                
                let duration = Float(time)
                self?._duration.onNext(duration)
                
                let progress = playTime / duration
                self?._progress.onNext(progress)
                
                let remainingTime = duration - playTime
                self?._remainingTime.onNext(remainingTime)
            }
        })
    }
}

// MARK: - WKYTPlayerViewDelegate
extension YoutubePlayer: WKYTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        _isReady.onNext(true)
        getDuration(for: playerView, playTime: 0)
    }

    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        switch state {
        case .unstarted:
            _state.onNext(.unstarted)
        case .ended:
            _state.onNext(.ended)
        case .playing:
            _state.onNext(.playing)
        case .paused:
            _state.onNext(.paused)
        case .buffering:
            _state.onNext(.buffering)
        case .queued:
            _state.onNext(.queued)
        case .unknown:
            _state.onNext(.unknow)
        default:
            break
        }
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo quality: WKYTPlaybackQuality) {
        
    }
    
    func playerView(_ playerView: WKYTPlayerView, receivedError error: WKYTPlayerError) {
        
    }
    
    func playerView(_ playerView: WKYTPlayerView, didPlayTime playTime: Float) {
        getDuration(for: playerView, playTime: playTime)
    }
    
    func playerViewPreferredWebViewBackgroundColor(_ playerView: WKYTPlayerView) -> UIColor {
        return UIColor.black
    }
    
    func playerViewPreferredInitialLoading(_ playerView: WKYTPlayerView) -> UIView? {
        return nil
    }
    
    func playerViewIframeAPIDidFailed(toLoad playerView: WKYTPlayerView) {
        
    }
}
