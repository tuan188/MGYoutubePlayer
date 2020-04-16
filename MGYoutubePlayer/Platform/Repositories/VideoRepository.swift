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
            Video(id: "M7lc1UVf-VE", title: "YouTube Developers Live: Embedded Web Player Customization"),
            Video(id: "jdqsiFw74Jk", title: "Youtube Data API v3 & jQuery To List Channel Videos"),
            Video(id: "TlB_eWDSMt4", title: "Node.js Tutorial for Beginners: Learn Node in 1 Hour | Mosh")
        ])
    }
}
