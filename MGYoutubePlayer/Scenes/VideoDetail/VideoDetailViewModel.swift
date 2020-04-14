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
        let videoId: Driver<String>
        let minimize: Driver<Void>
    }

    func transform(_ input: Input) -> Output {
        let title = input.loadTrigger
            .map { self.video.title }
    
        let videoId = input.loadTrigger
            .map { self.video.id }
        
        let minimize = input.minimizeTrigger
            .do(onNext: navigator.minimize)
        
        return Output(
            title: title,
            videoId: videoId,
            minimize: minimize
        )
    }
}
