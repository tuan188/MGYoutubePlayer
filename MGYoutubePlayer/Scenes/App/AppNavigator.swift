//
//  AppNavigator.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/22/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit

protocol AppNavigatorType {
    func toVideoList()
}

struct AppNavigator: AppNavigatorType {
    unowned let assembler: Assembler
    unowned let window: UIWindow
    
    func toVideoList() {
        let nav = UINavigationController()
        let vc: VideoListViewController = assembler.resolve(navigationController: nav)
        nav.viewControllers = [vc]
        
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
}
