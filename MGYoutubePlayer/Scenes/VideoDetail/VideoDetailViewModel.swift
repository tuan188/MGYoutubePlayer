//
//  VideoDetailViewModel.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/23/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

struct VideoDetailViewModel {
    let navigator: VideoDetailNavigatorType
    let useCase: VideoDetailUseCaseType
    let video: Video
}

// MARK: - ViewModelType
extension VideoDetailViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let minimizeTrigger: Driver<Void>
    }

    struct Output {
        let title: Driver<String>
        let video: Driver<Video>
        let minimize: Driver<Void>
    }

    func transform(_ input: Input) -> Output {
        let title = input.loadTrigger
            .map { self.video.title }
    
        let video = input.loadTrigger
            .map { self.video }
        
        let minimize = input.minimizeTrigger
            .do(onNext: navigator.minimize)
        
        return Output(
            title: title,
            video: video,
            minimize: minimize
        )
    }
}
