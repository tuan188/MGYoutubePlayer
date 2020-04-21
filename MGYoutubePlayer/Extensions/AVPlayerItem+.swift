//
//  AVPlayerItem+.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/21/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import AVFoundation

extension AVPlayerItem {
    public func totalBuffer() -> Double {
        return self.loadedTimeRanges
            .map({ $0.timeRangeValue })
            .reduce(0, { acc, cur in
                return acc + CMTimeGetSeconds(cur.start) + CMTimeGetSeconds(cur.duration)
            })
    }
    
    public func currentBuffer() -> Double {
        let currentTime = self.currentTime()
        guard let timeRange = self.loadedTimeRanges.map({ $0.timeRangeValue })
            .first(where: { $0.containsTime(currentTime) }) else { return -1 }
        return CMTimeGetSeconds(timeRange.end) - currentTime.seconds
    }
}
