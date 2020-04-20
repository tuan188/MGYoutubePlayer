//
//  AudioListUseCase.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/20/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

protocol AudioListUseCaseType {
    func getAudioList() -> Observable<[Audio]>
}

struct AudioListUseCase: AudioListUseCaseType {
    let audioRepository: AudioRepositoryType
    
    func getAudioList() -> Observable<[Audio]> {
        return audioRepository.getAudioList()
    }
}
