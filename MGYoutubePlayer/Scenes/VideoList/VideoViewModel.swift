//
//  VideoViewModel.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/23/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

struct VideoViewModel {
    let video: Video
    
    var id: String {
        return video.videoId
    }
        
    var title: String {
        return video.videoTitle
    }
        
}
