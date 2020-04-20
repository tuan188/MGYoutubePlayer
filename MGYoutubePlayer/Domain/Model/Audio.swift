//
//  Audio.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/17/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

struct Audio {
    var url = ""
    var title = ""
}

extension Audio {
    func isSameAs(_ audio: Audio) -> Bool {
        return self.url == audio.url
    }
}
