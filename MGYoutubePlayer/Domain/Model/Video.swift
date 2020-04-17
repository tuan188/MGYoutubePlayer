//
//  Video.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/23/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

struct Video {
    var id = ""
    var title = ""
}

extension Video {
    func isSameAs(_ video: Video) -> Bool {
        return self.id == video.id
    }
}
