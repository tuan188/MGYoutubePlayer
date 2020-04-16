//
//  CacheManager.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/16/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

final class CacheManager {
    static let instance = CacheManager()
    
    var youtubePlayer: YoutubePlayer?
    
    private init() {
        
    }
}
