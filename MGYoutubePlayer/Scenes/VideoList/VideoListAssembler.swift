//
//  VideoListAssembler.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/23/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit

protocol VideoListAssembler {
    func resolve(navigationController: UINavigationController) -> VideoListViewController
    func resolve(navigationController: UINavigationController) -> VideoListViewModel
    func resolve(navigationController: UINavigationController) -> VideoListNavigatorType
    func resolve() -> VideoListUseCaseType
}

extension VideoListAssembler {
    func resolve(navigationController: UINavigationController) -> VideoListViewController {
        let vc = VideoListViewController.instantiate()
        let vm: VideoListViewModel = resolve(navigationController: navigationController)
        vc.bindViewModel(to: vm)
        return vc
    }

    func resolve(navigationController: UINavigationController) -> VideoListViewModel {
        return VideoListViewModel(
            navigator: resolve(navigationController: navigationController),
            useCase: resolve()
        )
    }
}

extension VideoListAssembler where Self: DefaultAssembler {
    func resolve(navigationController: UINavigationController) -> VideoListNavigatorType {
        return VideoListNavigator(assembler: self, navigationController: navigationController)
    }

    func resolve() -> VideoListUseCaseType {
        return VideoListUseCase()
    }
}