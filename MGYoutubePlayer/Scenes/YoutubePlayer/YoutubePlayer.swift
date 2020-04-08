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

struct YoutubePlayerError: Error {
    
}

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
    
    enum SeekState {
        case none
        case dragging
        case seek(TimeInterval)
    }
    
    struct Options {
        var controls = false
        var playsInline = true
        var autohide = true
        var showInfo = false
        var modestBranding = true
        
        func toDictionary() -> [String: Any] {
            return [
                "controls": controls ? 1 : 0,
                "playsinline": playsInline ? 1 : 0,
                "autohide": autohide ? 1 : 0,
                "showinfo": showInfo ? 1 : 0,
                "modestbranding": modestBranding ? 1 : 0
            ]
        }
    }
    
    private var playerView: WKYTPlayerView?
    private var superView: UIView?
    private var timer: Timer?
    
    // MARK: - Public properties
    
    private(set) var playTime: Float = 0.0
    private(set) var state: YoutubePlayer.State = .unknow
    private(set) var duration: Float = 0.0
    private(set) var remainingTime: Float = 0.0
    private(set) var isReady = false
    private(set) var loadedFraction: Float = 0.0
    
    // MARK: - Private properties
    
    fileprivate let _state = BehaviorSubject(value: YoutubePlayer.State.unknow)
    fileprivate let _playTime = BehaviorSubject(value: Float(0.0))
    fileprivate let _duration = BehaviorSubject(value: Float(0.0))
    fileprivate let _remainingTime = BehaviorSubject(value: Float(0.0))
    fileprivate let _error = PublishSubject<Error>()
    fileprivate let _isReady = BehaviorSubject(value: false)
    fileprivate let _loadedFraction = BehaviorSubject(value: Float(0.0))
    
    // MARK: - Methods
    
    deinit {
        timer?.invalidate()
    }
    
    func addPlayer(to view: UIView) {
        let player = WKYTPlayerView(frame: view.bounds)
        player.delegate = self
        view.addSubview(player)
        
        // Constraints
        player.translatesAutoresizingMaskIntoConstraints = false
        player.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        player.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        player.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        player.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        playerView = player
        superView = view
    }
    
    func load(videoId: String, options: Options = Options()) {
        playTime = 0
        duration = 0
        state = .unknow
        isReady = false
        
        _playTime.onNext(0)
        _duration.onNext(0)
        _state.onNext(.unknow)
        _isReady.onNext(false)
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
            self?.playerView?.getVideoLoadedFraction({ (fraction, error) in
                if let error = error {
                    self?._error.onNext(error)
                } else {
                    self?._loadedFraction.onNext(fraction)
                }
            })
        })
        
        playerView?.load(withVideoId: videoId, playerVars: options.toDictionary())
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
    
    func seek(to seconds: Float) {
        playerView?.seek(toSeconds: seconds, allowSeekAhead: true)
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
                let duration = Float(time)
                self?.duration = duration
                self?._duration.onNext(duration)
                
                let remainingTime = duration - playTime
                self?.remainingTime = remainingTime
                self?._remainingTime.onNext(remainingTime)
            }
        })
    }
}

// MARK: - Reactive
extension Reactive where Base: YoutubePlayer {
    var state: Driver<YoutubePlayer.State> {
        return self.base._state.asDriver(onErrorJustReturn: .unknow)
    }
    
    var playTime: Driver<Float> {
        return self.base._playTime.asDriver(onErrorJustReturn: 0.0)
    }
    
    var duration: Driver<Float> {
        return self.base._duration.asDriver(onErrorJustReturn: 0.0)
    }
    
    var remainingTime: Driver<Float> {
        return self.base._remainingTime.asDriver(onErrorJustReturn: 0.0)
    }
    
    var error: Driver<Error> {
        return self.base._error.asDriver(onErrorJustReturn: YoutubePlayerError())
    }
    
    var isReady: Driver<Bool> {
        return self.base._isReady.asDriver(onErrorJustReturn: false)
    }
    
    var loadedFraction: Driver<Float> {
        return self.base._loadedFraction.asDriver(onErrorJustReturn: 0.0)
    }
}

// MARK: - WKYTPlayerViewDelegate
extension YoutubePlayer: WKYTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        _isReady.onNext(true)
        getDuration(for: playerView, playTime: 0)
    }

    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        let playerState: YoutubePlayer.State
        
        switch state {
        case .unstarted:
            playerState = .unstarted
        case .ended:
            playerState = .ended
        case .playing:
            playerState = .playing
        case .paused:
            playerState = .paused
        case .buffering:
            playerState = .buffering
        case .queued:
            playerState = .queued
        default:
            playerState = .unknow
        }
        
        self.state = playerState
        self._state.onNext(playerState)
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo quality: WKYTPlaybackQuality) {
        
    }
    
    func playerView(_ playerView: WKYTPlayerView, receivedError error: WKYTPlayerError) {
        
    }
    
    func playerView(_ playerView: WKYTPlayerView, didPlayTime playTime: Float) {
        self.playTime = playTime
        _playTime.onNext(playTime)
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
