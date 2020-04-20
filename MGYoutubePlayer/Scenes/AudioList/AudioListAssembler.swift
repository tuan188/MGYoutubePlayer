//
//  AudioListAssembler.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/20/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit

protocol AudioListAssembler {
    func resolve(navigationController: UINavigationController) -> AudioListViewController
    func resolve(navigationController: UINavigationController) -> AudioListViewModel
    func resolve(navigationController: UINavigationController) -> AudioListNavigatorType
    func resolve() -> AudioListUseCaseType
}

extension AudioListAssembler {
    func resolve(navigationController: UINavigationController) -> AudioListViewController {
        let vc = AudioListViewController.instantiate()
        let vm: AudioListViewModel = resolve(navigationController: navigationController)
        vc.bindViewModel(to: vm)
        return vc
    }

    func resolve(navigationController: UINavigationController) -> AudioListViewModel {
        return AudioListViewModel(
            navigator: resolve(navigationController: navigationController),
            useCase: resolve()
        )
    }
}

extension AudioListAssembler where Self: DefaultAssembler {
    func resolve(navigationController: UINavigationController) -> AudioListNavigatorType {
        return AudioListNavigator(assembler: self, navigationController: navigationController)
    }

    func resolve() -> AudioListUseCaseType {
        return AudioListUseCase(audioRepository: resolve())
    }
}
