//
//  VideoListNavigator.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/23/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

protocol VideoListNavigatorType {
    func toVideoDetail(video: Video)
}

struct VideoListNavigator: VideoListNavigatorType {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController

    func toVideoDetail(video: Video) {
        let vc: VideoDetailViewController = assembler.resolve(navigationController: navigationController, video: video)
        navigationController.pushViewController(vc, animated: true)
    }
}
