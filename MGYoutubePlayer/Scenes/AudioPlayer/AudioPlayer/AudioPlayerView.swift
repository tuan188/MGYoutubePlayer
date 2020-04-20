//
//  AudioPlayerView.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/20/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

final class AudioPlayerView: UIView, NibOwnerLoadable {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var slider: ProgressSlider!
    @IBOutlet weak var remainingTimeLabel: UILabel!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
        
        coverImageView.clipsToBounds = false
        coverImageView.layer.shadowColor = UIColor.black.cgColor
        coverImageView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        coverImageView.layer.shadowOpacity = 0.5
        coverImageView.layer.shadowRadius = 10
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
