//
//  AudioDetailNavigator.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/20/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

protocol AudioDetailNavigatorType {
    
}

struct AudioDetailNavigator: AudioDetailNavigatorType {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController
}
