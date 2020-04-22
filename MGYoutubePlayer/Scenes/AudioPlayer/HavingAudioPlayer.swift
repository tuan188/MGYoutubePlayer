//
//  HavingAudioPlayer.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/22/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol HavingAudioPlayer: class {
    var player: AudioPlayer? { get set }
    
    func bindViewModel()
    func unbindViewModel()
}

extension HavingAudioPlayer {
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    func movePlayer(to object: HavingAudioPlayer) {
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
