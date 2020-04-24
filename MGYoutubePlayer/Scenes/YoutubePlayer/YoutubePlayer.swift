//
//  YoutubePlayer.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/28/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class YoutubePlayer: NSObject {
    
    enum State {
        case unstarted
        case ended
        case playing
        case paused
        case buffering
        case queued
        case unknown
    }
    
    // MARK: - Public properties
    
    var shouldRequestDurationChanges = false
    private(set) var playerView: WKYTPlayerView?
    private(set) var video: VideoProtocol?
    
    var playTime: Float {
        return _playTime.value
    }
    
    var state: YoutubePlayer.State {
        return _state.value
    }
    
    var duration: Float {
        return _duration.value
    }
    
    var remainingTime: Float {
        return _remainingTime.value
    }
    
    var isReady: Bool {
        return _isReady.value
    }
    
    var loadedFraction: Float {
        return _loadedFraction.value
    }
    
    var isPlaying: Bool {
        let state = self.state
        return state == YoutubePlayer.State.playing || state == YoutubePlayer.State.buffering
    }
    
    var isActive: Bool {
        let state = self.state
        return state == YoutubePlayer.State.playing
            || state == YoutubePlayer.State.buffering
            || state == YoutubePlayer.State.paused
    }
    
    // MARK: - Private properties
    private var superView: UIView?
    private var timer: Timer?
    
    fileprivate let _state = BehaviorRelay(value: YoutubePlayer.State.unknown)
    fileprivate let _playTime = BehaviorRelay(value: Float.zero)
    fileprivate let _duration = BehaviorRelay(value: Float.zero)
    fileprivate let _remainingTime = BehaviorRelay(value: Float.zero)
    fileprivate let _error = PublishSubject<Error>()
    fileprivate let _isReady = BehaviorRelay(value: false)
    fileprivate let _loadedFraction = BehaviorRelay(value: Float.zero)
    
    // MARK: - Methods
    
    deinit {
        print("YoutubePlayer deinit")
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
    
    func movePlayer(to view: UIView) {
        guard let player = self.playerView else { return }
        player.removeFromSuperview()
        view.addSubview(player)
        superView = view
        
        // Constraints
        player.translatesAutoresizingMaskIntoConstraints = false
        player.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        player.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        player.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        player.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    func load(video: VideoProtocol) {
        let playerVars = [
            "autohide": 0,
            "controls": 0,
            "playsinline": 1,
            "showinfo": 0,
            "rel": 0,
            "modestbranding": 1,
            "iv_load_policy": 3
            //"theme" : "dark"
            //"autoplay"     : 1
        ]
        load(video: video, playerVars: playerVars)
    }
    
    func load(video: VideoProtocol, playerVars: [String: Any]) {
        resetStats()
        self.video = video
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
            self?.playerView?.getVideoLoadedFraction({ (fraction, error) in
                if let error = error {
                    self?._error.onNext(error)
                } else {
                    self?._loadedFraction.accept(fraction)
                }
            })
        })
        
        playerView?.load(withVideoId: video.id, playerVars: playerVars)
    }
    
    private func resetStats() {
        _playTime.accept(0)
        _duration.accept(0)
        _state.accept(.unknown)
        _isReady.accept(false)
        
        timer?.invalidate()
    }
    
    func reload() {
        guard let videoId = self.video?.id else { return }
        
        resetStats()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
            self?.playerView?.getVideoLoadedFraction({ (fraction, error) in
                if let error = error {
                    self?._error.onNext(error)
                } else {
                    self?._loadedFraction.accept(fraction)
                }
            })
        })
        playerView?.cueVideo(byId: videoId, startSeconds: 0, suggestedQuality: .auto)
    }
    
    func play() {
        playerView?.playVideo()
    }
    
    func stop() {
        resetStats()
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
                self?._duration.accept(duration)
                
                let remainingTime = duration - playTime
                self?._remainingTime.accept(remainingTime)
            }
        })
    }
}

enum YoutubePlayerError: Error {
    case unknown
}

// MARK: - Reactive
extension Reactive where Base: YoutubePlayer {
    var state: Driver<YoutubePlayer.State> {
        return self.base._state.asDriver(onErrorJustReturn: .unknown)
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
        return self.base._error.asDriver(onErrorJustReturn: YoutubePlayerError.unknown)
    }
    
    var isReady: Driver<Bool> {
        return self.base._isReady.asDriver(onErrorJustReturn: false)
    }
    
    var loadedFraction: Driver<Float> {
        return self.base._loadedFraction.asDriver(onErrorJustReturn: 0.0)
    }
    
    var isPlaying: Driver<Bool> {
        return self.base._state
            .map { $0 == YoutubePlayer.State.playing || $0 == YoutubePlayer.State.buffering }
            .asDriver(onErrorJustReturn: false)
    }
}

// MARK: - WKYTPlayerViewDelegate
extension YoutubePlayer: WKYTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        _isReady.accept(true)
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
            playerState = .unknown
        }
        
        self._state.accept(playerState)
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo quality: WKYTPlaybackQuality) {
        
    }
    
    func playerView(_ playerView: WKYTPlayerView, receivedError error: WKYTPlayerError) {
        
    }
    
    func playerView(_ playerView: WKYTPlayerView, didPlayTime playTime: Float) {
        _playTime.accept(playTime)
        
        if shouldRequestDurationChanges {
            getDuration(for: playerView, playTime: playTime)
        } else {
            let remainingTime = self.duration - playTime
            self._remainingTime.accept(remainingTime)
        }
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
