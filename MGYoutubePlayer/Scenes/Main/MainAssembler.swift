//
//  MainAssembler.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/10/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

protocol MainAssembler {
    func resolve(window: UIWindow) -> MainViewController
    func resolve(window: UIWindow) -> MainViewModel
    func resolve(window: UIWindow) -> MainNavigatorType
    func resolve() -> MainUseCaseType
}

extension MainAssembler {
    func resolve(window: UIWindow) -> MainViewModel {
        return MainViewModel(
            navigator: resolve(window: window),
            useCase: resolve()
        )
    }
}

extension MainAssembler where Self: DefaultAssembler {
    func resolve(window: UIWindow) -> MainViewController {
        // Video List
        let videoListNavigationController = UINavigationController()
        
        let videoListViewController: VideoListViewController = self.resolve(
            navigationController: videoListNavigationController
        )
        
        videoListViewController.tabBarItem = UITabBarItem(
            title: "Video List",
            image: UIImage.videos,
            selectedImage: nil
        )
        
        videoListNavigationController.viewControllers = [videoListViewController]
        
        // Audio List
        let audioListNavigationController = UINavigationController()
        
        let audioListViewController: AudioListViewController = self.resolve(
            navigationController: audioListNavigationController
        )
        
        audioListViewController.tabBarItem = UITabBarItem(
            title: "Audio List",
            image: UIImage.audios,
            selectedImage: nil
        )
        
        audioListNavigationController.viewControllers = [audioListViewController]
        
        // Main
        let mainViewController = MainViewController()
        
        mainViewController.viewControllers = [
            videoListNavigationController,
            audioListNavigationController
        ]
        
        let vm: MainViewModel = resolve(window: window)
        mainViewController.bindViewModel(to: vm)
        
        return mainViewController
    }
    
    func resolve(window: UIWindow) -> MainNavigatorType {
        return MainNavigator(assembler: self, window: window)
    }
    
    func resolve() -> MainUseCaseType {
        return MainUseCase()
    }
}
