//
//  YoutubePlayerViewModel.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/8/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

final class YoutubePlayerViewModel: ViewModelType {
    struct Input {
        let state: Driver<YoutubePlayer.State>
        let play: Driver<Void>
        let stop: Driver<Void>
        let pause: Driver<Void>
        let seek: Driver<Float>
    }
    
    struct Output {
        let state: Driver<YoutubePlayer.State>
    }
    
    func transform(_ input: Input) -> Output {
        fatalError()
    }
}
