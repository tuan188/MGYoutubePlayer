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
        
    }
    
    struct Output {
        
    }
    
    func transform(_ input: Input) -> Output {
        return Output()
    }
}
