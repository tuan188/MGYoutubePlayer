//
//  VideoListViewModel.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/23/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

struct VideoListViewModel {
    let navigator: VideoListNavigatorType
    let useCase: VideoListUseCaseType
}

// MARK: - ViewModelType
extension VideoListViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let reloadTrigger: Driver<Void>
        let selectVideoTrigger: Driver<IndexPath>
        let showVideoTrigger: Driver<Video>
    }

    struct Output {
        let error: Driver<Error>
        let isLoading: Driver<Bool>
        let isReloading: Driver<Bool>
        let videoList: Driver<[Video]>
        let selectedVideo: Driver<Void>
        let isEmpty: Driver<Bool>
    }

    func transform(_ input: Input) -> Output {
        let getListResult = getList(
            loadTrigger: input.loadTrigger,
            reloadTrigger: input.reloadTrigger,
            getItems: useCase.getVideoList)
        
        let (videoList, error, isLoading, isReloading) = getListResult.destructured

        let selectedVideo = Driver.merge(select(trigger: input.selectVideoTrigger, items: videoList),
                                         input.showVideoTrigger)
            .do(onNext: navigator.toVideoDetail)
            .mapToVoid()

        let isEmpty = checkIfDataIsEmpty(trigger: Driver.merge(isLoading, isReloading),
                                         items: videoList)

        return Output(
            error: error,
            isLoading: isLoading,
            isReloading: isReloading,
            videoList: videoList,
            selectedVideo: selectedVideo,
            isEmpty: isEmpty
        )
    }
}
