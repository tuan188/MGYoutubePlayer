//
//  Float+.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/28/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

extension Float {
    public func toMMSS() -> String {
        guard !self.isNaN else { return "00:00" }
        
        let ts = Int(self.rounded())
        let s = ts % 60
        let m = (ts / 60) % 60
        let h = (ts / 3600) % 60
        
        return h == 0
            ? String(format: "%02d:%02d", m, s)
            : String(format: "%d:%02d:%02d", h, m, s)
    }
}
