//
//  ShowingYoutubeMiniPlayer.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/23/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

protocol ShowingYoutubeMiniPlayer {
    
}

extension ShowingYoutubeMiniPlayer where Self: UIViewController {
    func showYoutubeMiniPlayer() {
        if let tabBarController = self.tabBarController,
            let miniPlayer = tabBarController.youtubeMiniPlayer,
            miniPlayer.isActive {
            
            after(interval: 0.1) {  // to break animation chaining
                tabBarController.showYoutubeMiniPlayer()
            }
        }
    }
    
    func hideYoutubeMiniPlayer() {
        after(interval: 0.1) {  // to break animation chaining
            self.tabBarController?.hideYoutubeMiniPlayer()
        }
    }
}
