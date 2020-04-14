//
//  YoutubeMiniPlayerView.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

final class YoutubeMiniPlayerView: UIView, NibLoadable, HavingYoutubePlayer {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var playAction: (() -> Void)?
    var closeAction: (() -> Void)?
    var player: YoutubePlayer?
    
    var videoContainerView: UIView {
        return containerView
    }
    
    @IBAction private func play(_ sender: Any) {
        print(#function)
    }
    
    @IBAction private func close(_ sender: Any) {
        print(#function)
    }
    
    func bindViewModel() {
        
    }

}
