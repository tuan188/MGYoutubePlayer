//
//  MainNavigator.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/10/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

protocol MainNavigatorType {
    
}

struct MainNavigator: MainNavigatorType {
    unowned let assembler: Assembler
    unowned let window: UIWindow
}
