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
        let reloadTrigger: Driver<Void>
        let selectVideoTrigger: Driver<IndexPath>
    }

    struct Output {
        let video: Driver<Video>
        let error: Driver<Error>
        let isLoading: Driver<Bool>
        let isReloading: Driver<Bool>
        let videoList: Driver<[Video]>
        let selectedVideo: Driver<Void>
        let isEmpty: Driver<Bool>
    }

    func transform(_ input: Input) -> Output {
        let video = input.loadTrigger
            .map { self.video }
        
        let getListResult = getList(
            loadTrigger: input.loadTrigger,
            reloadTrigger: input.reloadTrigger,
            getItems: useCase.getVideoList)
        
        let (videoList, error, isLoading, isReloading) = getListResult.destructured
        
        let videos = videoList
            .map { $0.filter { $0.videoId != self.video.videoId } }
        
        let selectedVideo = select(trigger: input.selectVideoTrigger, items: videos)
            .do(onNext: navigator.toVideoDetail)
            .mapToVoid()
        
        let isEmpty = checkIfDataIsEmpty(trigger: Driver.merge(isLoading, isReloading),
                                         items: videoList)
        
        return Output(
            video: video,
            error: error,
            isLoading: isLoading,
            isReloading: isReloading,
            videoList: videos,
            selectedVideo: selectedVideo,
            isEmpty: isEmpty
        )
    }
}
