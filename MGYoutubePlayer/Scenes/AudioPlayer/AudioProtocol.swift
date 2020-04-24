//
//  AudioProtocol.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/24/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol AudioProtocol {
    var audioUrl: String { get set }
    var title: String { get set }
    var artworkUrl: String { get set }
}
