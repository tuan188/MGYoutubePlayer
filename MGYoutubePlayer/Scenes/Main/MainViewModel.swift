//
//  MainViewModel.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/10/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

struct MainViewModel {
    let navigator: MainNavigatorType
    let useCase: MainUseCaseType
}

// MARK: - ViewModelType
extension MainViewModel: ViewModelType {
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(_ input: Input) -> Output {
        return Output()
    }
}
