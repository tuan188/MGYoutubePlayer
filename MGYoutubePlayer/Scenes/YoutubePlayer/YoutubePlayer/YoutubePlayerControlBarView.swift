//
//  YoutubePlayerControlBarView.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/16/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

final class YoutubePlayerControlBarView: UIView, NibOwnerLoadable {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var slider: ProgressSlider!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var fullscreenButton: UIButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
        
        slider.loadedProgressTintColor = .lightGray
        slider.setThumbImage(UIImage(named: "slider"), for: .normal)
    }
}
