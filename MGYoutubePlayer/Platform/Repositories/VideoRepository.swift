//
//  VideoRepository.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/16/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol VideoRepositoryType {
    func getVideoList() -> Observable<[Video]>
}

struct VideoRepository: VideoRepositoryType {
    func getVideoList() -> Observable<[Video]> {
        return Observable.just([
            Video(videoId: "M7lc1UVf-VE", videoTitle: "YouTube Developers Live: Embedded Web Player Customization"),
            Video(videoId: "jdqsiFw74Jk", videoTitle: "Youtube Data API v3 & jQuery To List Channel Videos"),
            Video(videoId: "TlB_eWDSMt4", videoTitle: "Node.js Tutorial for Beginners: Learn Node in 1 Hour | Mosh")
        ])
    }
}
