//
//  AudioDetailNavigator.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/20/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

protocol AudioDetailNavigatorType {
    func toAudioDetail(audio: Audio)
}

struct AudioDetailNavigator: AudioDetailNavigatorType {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController
    
    func toAudioDetail(audio: Audio) {
        let vc: AudioDetailViewController = assembler.resolve(navigationController: navigationController,
                                                              audio: audio)
        navigationController.pushViewController(vc, animated: true)
    }
}
