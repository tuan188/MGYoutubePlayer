//
//  VideoDetailNavigator.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/23/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

protocol VideoDetailNavigatorType {
    func toVideoDetail(video: Video)
}

struct VideoDetailNavigator: VideoDetailNavigatorType {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController
    
    var tabBarController: MainViewController? {
        return navigationController.tabBarController as? MainViewController
    }
    
    func toVideoDetail(video: Video) {
        let videoDetailVC: VideoDetailViewController = assembler.resolve(navigationController: navigationController,
                                                                         video: video)
        navigationController.pushViewController(videoDetailVC, animated: true)
    }
}
