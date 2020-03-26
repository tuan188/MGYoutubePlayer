//
//  YoutubePlayerView.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/26/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView

final class YoutubePlayerView: UIView, NibOwnerLoadable {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playerBackgroundView: UIView!
    
    private var playerView: WKYTPlayerView?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
    }
    
    @IBAction private func play(_ sender: Any) {
        play(videoId: "M7lc1UVf-VE")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addPlayer()
    }
    
    private func addPlayer() {
        let player = WKYTPlayerView(frame: playerBackgroundView.bounds)
        playerBackgroundView.addSubview(player)
        playerView = player
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let playerView = playerView {
            self.bringSubviewToFront(playerView)
        }
    }
    
    func play(videoId: String) {
        playerView?.load(withVideoId: videoId, playerVars: [
            "controls": 0,
            "playsinline": 1,
            "autohide": 1,
            "showinfo": 0,
            "modestbranding": 1
        ])
    }
}
