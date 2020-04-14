//
//  VideoDetailNavigator.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/23/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

protocol VideoDetailNavigatorType {
    func minimize()
}

struct VideoDetailNavigator: VideoDetailNavigatorType {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController
    
    var tabBarController: MainViewController? {
        return navigationController.tabBarController as? MainViewController
    }
    
    func minimize() {
        
    }
}
