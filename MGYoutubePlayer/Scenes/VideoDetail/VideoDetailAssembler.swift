//
//  VideoDetailAssembler.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/23/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit

protocol VideoDetailAssembler {
    func resolve(navigationController: UINavigationController, video: Video) -> VideoDetailViewController
    func resolve(navigationController: UINavigationController, video: Video) -> VideoDetailViewModel
    func resolve(navigationController: UINavigationController) -> VideoDetailNavigatorType
    func resolve() -> VideoDetailUseCaseType
}

extension VideoDetailAssembler {
    func resolve(navigationController: UINavigationController, video: Video) -> VideoDetailViewController {
        let vc = VideoDetailViewController.instantiate()
        let vm: VideoDetailViewModel = resolve(navigationController: navigationController, video: video)
        vc.bindViewModel(to: vm)
        return vc
    }

    func resolve(navigationController: UINavigationController, video: Video) -> VideoDetailViewModel {
        return VideoDetailViewModel(
            navigator: resolve(navigationController: navigationController),
            useCase: resolve(),
            video: video
        )
    }
}

extension VideoDetailAssembler where Self: DefaultAssembler {
    func resolve(navigationController: UINavigationController) -> VideoDetailNavigatorType {
        return VideoDetailNavigator(assembler: self, navigationController: navigationController)
    }

    func resolve() -> VideoDetailUseCaseType {
        return VideoDetailUseCase(videoRepository: resolve())
    }
}
