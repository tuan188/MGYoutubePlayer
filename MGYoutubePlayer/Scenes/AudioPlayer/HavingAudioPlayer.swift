//
//  HavingAudioPlayer.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/22/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import MediaPlayer

protocol HavingAudioPlayer: class {
    var player: AudioPlayer? { get set }
    
    // MPRemoteCommandCenter
    var playTarget: Any? { get set }
    var pauseTarget: Any? { get set }
    var backwardTarget: Any? { get set }
    var forwardTarget: Any? { get set }
    var changePositionTarget: Any? { get set }
    
    // Notifications
    var notificationDisposeBag: DisposeBag { get set }
    
    func setAudio(_ audio: AudioProtocol)
    
    // Binding
    func bindViewModel()
    func unbindViewModel()
    
    // Now playing
    func updateNowPlaying()
}

extension HavingAudioPlayer {
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    var isActive: Bool {
        return player?.isActive ?? false
    }
    
    func movePlayer(to object: HavingAudioPlayer) {
        // Return player from miniplayer to its owner
        if let miniPlayer = object as? AudioMiniPlayerView,
            let owner = miniPlayer.player?.owner {
            miniPlayer.movePlayer(to: owner)
        }
        
        // transfer player
        object.player = player
        object.bindViewModel()
        
        // Set new owner for player
        if self is AudioMiniPlayerView,
            let playerView = object as? AudioPlayerView {
            player?.owner = playerView
        }
        
        // register
        object.cleanup()
        object.registerInterruptionAndRouteChangeNotifications()
        object.setupRemoteTransportControls()
        
        // clean up
        player = nil
        unbindViewModel()
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.stop()
    }
    
    func seekTo(time: Double) {
        player?.seek(to: time)
    }
    
    func backward(time: Double) {
        guard let player = player else { return }
        seekTo(time: max(player.playTime - 15, 0.0))
    }
    
    func forward(time: Double) {
        guard let player = player else { return }
        seekTo(time: min(player.playTime + 30, player.duration))
    }
}

// MARK: - MPRemoteCommandCenter
extension HavingAudioPlayer {
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        playTarget = commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.play()
            return .success
        }
        
        pauseTarget = commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.pause()
            return .success
        }
        
        changePositionTarget = commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                let event = event as? MPChangePlaybackPositionCommandEvent,
                !event.positionTime.isNaN
                else { return .commandFailed }
            
            self.seekTo(time: event.positionTime)
            return .success
        }
        
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(15)]
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(15)]
        
        backwardTarget = commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.backward(time: 15)
            return .success
        }
        
        forwardTarget = commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.forward(time: 15)
            return .success
        }
    }
    
    func removeTargetRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.removeTarget(playTarget)
        commandCenter.pauseCommand.removeTarget(pauseTarget)
        commandCenter.changePlaybackPositionCommand.removeTarget(changePositionTarget)
        commandCenter.previousTrackCommand.removeTarget(backwardTarget)
        commandCenter.nextTrackCommand.removeTarget(forwardTarget)
    }
    
    func updateNowPlayingInfoCenter(isPlaying: Bool,
                                    title: String? = nil,
                                    playTime: Double? = nil,
                                    duration: Double? = nil,
                                    artWorkImage: UIImage? = nil) {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
        
        guard isPlaying || title == nowPlayingInfo[MPMediaItemPropertyTitle] as? String else { return }
        
        if let title = title {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
        }
        
        if let duration = duration {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        }
        
        if let playTime = playTime {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playTime
        }
        
        if let artWorkImage = artWorkImage {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 30, height: 30),
                                                                            requestHandler: { _ in artWorkImage })
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? player?.player.rate : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func resetNowPlayingInfoCenter() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}

// MARK: - Notification Handlers
extension HavingAudioPlayer {
    
    func registerInterruptionAndRouteChangeNotifications() {
        NotificationCenter.default.rx.notification(AVAudioSession.interruptionNotification)
            .subscribe(onNext: handleInterruption(notification:))
            .disposed(by: notificationDisposeBag)
        
        NotificationCenter.default.rx.notification(AVAudioSession.routeChangeNotification)
            .subscribe(onNext: handleRouteChange(notification:))
            .disposed(by: notificationDisposeBag)
    }
    
    func unregisterInterruptionAndRouteChangeNotifications() {
        notificationDisposeBag = DisposeBag()
    }
    
    private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        
        switch type {
        case .began:
            var shouldPause = true
            if #available(iOS 10.3, *),
                (notification.userInfo?[AVAudioSessionInterruptionWasSuspendedKey] as? UInt ) != nil {
                shouldPause = false
            }
            
            if shouldPause {
                pause()
            }
        case .ended:
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    print("Interruption Ended - playback should resume")
                    play()
                } else {
                    print("Interruption Ended - playback should NOT resume")
                }
            }
        @unknown default:
            break
        }
    }
    
    private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                return
        }
        switch reason {
        case .newDeviceAvailable:
            let session = AVAudioSession.sharedInstance()
            for output in session.currentRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                print("headphones connected")
            }
        case .oldDeviceUnavailable:
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                    print("headphones disconnected")
                    pause()
                }
            }
        default:
            break
        }
    }
}

extension HavingAudioPlayer {
    func cleanup() {
        removeTargetRemoteTransportControls()
        unregisterInterruptionAndRouteChangeNotifications()
    }
}
