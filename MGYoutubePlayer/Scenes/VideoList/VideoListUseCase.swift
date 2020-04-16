//
//  VideoListUseCase.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/23/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

protocol VideoListUseCaseType {
    func getVideoList() -> Observable<[Video]>
}

struct VideoListUseCase: VideoListUseCaseType {
    let videoRepository: VideoRepositoryType
    
    func getVideoList() -> Observable<[Video]> {
        return videoRepository.getVideoList()
    }
}
