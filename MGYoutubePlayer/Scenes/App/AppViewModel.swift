//
//  AppViewModel.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/22/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

struct AppViewModel {
    let navigator: AppNavigatorType
    let useCase: AppUseCaseType
}

// MARK: - ViewModelType
extension AppViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
    }
    
    struct Output {
        let toVideoList: Driver<Void>
    }
    
    func transform(_ input: Input) -> Output {
        let toVideoList = input.loadTrigger
            .do(onNext: navigator.toVideoList)
        
        return Output(toVideoList: toVideoList)
    }
}
