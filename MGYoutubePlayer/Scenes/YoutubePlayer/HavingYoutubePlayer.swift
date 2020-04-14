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
}

extension HavingYoutubePlayer {
    func movePlayer(to object: HavingYoutubePlayer) {
        player?.movePlayer(to: object.videoContainerView)
        object.player = player
        object.bindViewModel()
    }
}
