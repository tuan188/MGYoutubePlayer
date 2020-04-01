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
    @IBOutlet weak var slider: ProgressSlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playerBackgroundView: UIView!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    private var player: YoutubePlayer!
    private var state = YoutubePlayer.State.unknow
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
    }
    
    @IBAction private func play(_ sender: Any) {
        switch state {
        case .playing, .buffering:
            player.pause()
        default:
            player.play()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configPlayer()
    }
    
    func load(videoId: String) {
        player.load(videoId: videoId)
    }
    
    private func configPlayer() {
        player = YoutubePlayer()
        player.addPlayer(to: playerBackgroundView)
        
        player.duration
            .drive(onNext: { [unowned self] duration in
                self.slider.maximumValue = duration
                self.durationLabel.text = duration.toMMSS()
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
        
        player.loadedFraction
            .drive(onNext: { progress in
                self.slider.loadedProgress = CGFloat(progress)
            })
            .disposed(by: rx.disposeBag)
        
        player.playTime
            .drive(onNext: { [unowned self] playTime in
                self.playTimeLabel.text = playTime.toMMSS()
            })
            .disposed(by: rx.disposeBag)
        
        player.isReady
            .drive(onNext: { [unowned self] isReady in
                print("Ready:", isReady)
                self.playButton.isEnabled = isReady
                self.slider.isEnabled = isReady
            })
            .disposed(by: rx.disposeBag)
        
        player.state
            .drive(onNext: { [unowned self] state in
                self.state = state
                print(state)
                
                switch state {
                case .playing, .buffering:
                    self.playButton.setTitle("Pause", for: .normal)
                default:
                    self.playButton.setTitle("Play", for: .normal)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        player.bingPlayerToFront()
    }
}
