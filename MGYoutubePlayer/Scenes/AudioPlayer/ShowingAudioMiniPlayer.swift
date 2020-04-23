//
//  ShowingAudioMiniPlayer.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/23/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol ShowingAudioMiniPlayer {

}

extension ShowingAudioMiniPlayer where Self: UIViewController {
    func showAudioMiniPlayer() {
        if let tabBarController = self.tabBarController,
            let miniPlayer = tabBarController.audioMiniPlayer,
            miniPlayer.isActive {
            
            after(interval: 0.1) { // to break animation chaining
                tabBarController.showAudioMiniPlayer()
            }
        }
    }
    
    func hideAudioMiniPlayer() {
        after(interval: 0.1) { // to break animation chaining
            self.tabBarController?.hideAudioMiniPlayer()
        }
    }
}
