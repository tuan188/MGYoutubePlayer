//
//  AudioDetailUseCase.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/20/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

protocol AudioDetailUseCaseType {
    func getAudioList() -> Observable<[Audio]>
}

struct AudioDetailUseCase: AudioDetailUseCaseType {
    let audioRepository: AudioRepositoryType
    
    func getAudioList() -> Observable<[Audio]> {
        return audioRepository.getAudioList()
    }
}
