//
//  AudioDetailAssembler.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/20/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

protocol AudioDetailAssembler {
    func resolve(navigationController: UINavigationController, audio: Audio) -> AudioDetailViewController
    func resolve(navigationController: UINavigationController, audio: Audio) -> AudioDetailViewModel
    func resolve(navigationController: UINavigationController) -> AudioDetailNavigatorType
    func resolve() -> AudioDetailUseCaseType
}

extension AudioDetailAssembler {
    func resolve(navigationController: UINavigationController, audio: Audio) -> AudioDetailViewController {
        let vc = AudioDetailViewController.instantiate()
        let vm: AudioDetailViewModel = resolve(navigationController: navigationController, audio: audio)
        vc.bindViewModel(to: vm)
        return vc
    }
    
    func resolve(navigationController: UINavigationController, audio: Audio) -> AudioDetailViewModel {
        return AudioDetailViewModel(
            navigator: resolve(navigationController: navigationController),
            useCase: resolve(),
            audio: audio
        )
    }
}

extension AudioDetailAssembler where Self: DefaultAssembler {
    func resolve(navigationController: UINavigationController) -> AudioDetailNavigatorType {
        return AudioDetailNavigator(assembler: self, navigationController: navigationController)
    }
    
    func resolve() -> AudioDetailUseCaseType {
        return AudioDetailUseCase()
    }
}
