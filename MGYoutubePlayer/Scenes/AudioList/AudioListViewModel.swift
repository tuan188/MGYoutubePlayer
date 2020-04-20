//
//  AudioListViewModel.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/20/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

struct AudioListViewModel {
    let navigator: AudioListNavigatorType
    let useCase: AudioListUseCaseType
}

// MARK: - ViewModelType
extension AudioListViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let reloadTrigger: Driver<Void>
        let selectAudioTrigger: Driver<IndexPath>
    }

    struct Output {
        let error: Driver<Error>
        let isLoading: Driver<Bool>
        let isReloading: Driver<Bool>
        let audioList: Driver<[Audio]>
        let selectedAudio: Driver<Void>
        let isEmpty: Driver<Bool>
    }

    func transform(_ input: Input) -> Output {
        let getListResult = getList(
            loadTrigger: input.loadTrigger,
            reloadTrigger: input.reloadTrigger,
            getItems: useCase.getAudioList)
        
        let (audioList, error, isLoading, isReloading) = getListResult.destructured

        let selectedAudio = select(trigger: input.selectAudioTrigger, items: audioList)
            .do(onNext: navigator.toAudioDetail)
            .mapToVoid()

        let isEmpty = checkIfDataIsEmpty(trigger: Driver.merge(isLoading, isReloading),
                                         items: audioList)

        return Output(
            error: error,
            isLoading: isLoading,
            isReloading: isReloading,
            audioList: audioList,
            selectedAudio: selectedAudio,
            isEmpty: isEmpty
        )
    }
}