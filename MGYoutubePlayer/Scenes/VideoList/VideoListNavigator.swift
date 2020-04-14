//
//  VideoListNavigator.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/23/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit

protocol VideoListNavigatorType {
    func toVideoDetail(video: Video)
}

struct VideoListNavigator: VideoListNavigatorType {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController
    
    var tabBarController: UITabBarController? {
        return navigationController.tabBarController
    }

    func toVideoDetail(video: Video) {
        let videoDetailVC: VideoDetailViewController = assembler.resolve(navigationController: navigationController,
                                                                         video: video)
        navigationController.pushViewController(videoDetailVC, animated: true)
    }
}
