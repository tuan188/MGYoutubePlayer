//
//  AudioListNavigator.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/20/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

protocol AudioListNavigatorType {
    func toAudioDetail(audio: Audio)
}

struct AudioListNavigator: AudioListNavigatorType {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController

    func toAudioDetail(audio: Audio) {
        let vc: AudioDetailViewController = assembler.resolve(navigationController: navigationController, audio: audio)
        navigationController.pushViewController(vc, animated: true)
    }
}
