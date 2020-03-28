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
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playerBackgroundView: UIView!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    private var player: YoutubePlayer!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
    }
    
    @IBAction private func play(_ sender: Any) {
        player.play()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configPlayer()
        
        player.load(videoId: "M7lc1UVf-VE")
    }
    
    private func configPlayer() {
        player = YoutubePlayer()
        player.addPlayer(to: playerBackgroundView)
        
        player.duration
            .drive(onNext: { [unowned self] duration in
                self.slider.maximumValue = duration
            })
            .disposed(by: rx.disposeBag)
        
        player.remainingTime
            .drive(onNext: { [unowned self] remainingTime in
                self.remainingTimeLabel.text = "-" + remainingTime.toMMSS()
            })
            .disposed(by: rx.disposeBag)
        
        player.progress
            .drive(onNext: { [unowned self] progress in
                self.slider.value = progress
            })
            .disposed(by: rx.disposeBag)
        
        player.playTime
            .drive(onNext: { [unowned self] playTime in
                self.playTimeLabel.text = playTime.toMMSS()
            })
            .disposed(by: rx.disposeBag)
        
        player.isReady
            .drive(onNext: { [unowned self] isReady in
                self.playButton.isEnabled = isReady
                self.slider.isEnabled = isReady
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        player.bingPlayerToFront()
    }
}
