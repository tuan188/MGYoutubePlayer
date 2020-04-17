//
//  HavingYoutubePlayer.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol HavingYoutubePlayer: class {
    var player: YoutubePlayer? { get set }
    var videoContainerView: UIView { get }
    
    func bindViewModel()
    func unbindViewModel()
}

extension HavingYoutubePlayer {
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    var isActive: Bool {
        return player?.isActive ?? false
    }
    
    func movePlayer(to object: HavingYoutubePlayer) {
        player?.movePlayer(to: object.videoContainerView)
        object.player = player
        object.bindViewModel()
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
}
