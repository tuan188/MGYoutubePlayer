//
//  VideoCell.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/23/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

final class VideoCell: UITableViewCell, NibReusable {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindViewModel(_ viewModel: VideoViewModel?) {
        titleLabel.text = viewModel?.title
    }
}
