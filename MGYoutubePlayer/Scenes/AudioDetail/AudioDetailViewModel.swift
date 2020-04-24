//
//  AudioDetailViewModel.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/20/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

struct AudioDetailViewModel {
    let navigator: AudioDetailNavigatorType
    let useCase: AudioDetailUseCaseType
    let audio: Audio
}

// MARK: - ViewModelType
extension AudioDetailViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let reloadTrigger: Driver<Void>
        let selectAudioTrigger: Driver<IndexPath>
    }
    
    struct Output {
        let audio: Driver<Audio>
        let error: Driver<Error>
        let isLoading: Driver<Bool>
        let isReloading: Driver<Bool>
        let audioList: Driver<[Audio]>
        let selectedAudio: Driver<Void>
        let isEmpty: Driver<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        let audio = input.loadTrigger
            .map { self.audio }
        
        let getListResult = getList(
            loadTrigger: input.loadTrigger,
            reloadTrigger: input.reloadTrigger,
            getItems: useCase.getAudioList)
        
        let (audioList, error, isLoading, isReloading) = getListResult.destructured
        
        let audios = audioList
            .map { $0.filter { $0.url != self.audio.url } }
        
        let selectedAudio = select(trigger: input.selectAudioTrigger, items: audios)
            .do(onNext: navigator.toAudioDetail)
            .mapToVoid()
        
        let isEmpty = checkIfDataIsEmpty(trigger: Driver.merge(isLoading, isReloading),
                                         items: audioList)
        
        return Output(
            audio: audio,
            error: error,
            isLoading: isLoading,
            isReloading: isReloading,
            audioList: audios,
            selectedAudio: selectedAudio,
            isEmpty: isEmpty
        )
    }
}
