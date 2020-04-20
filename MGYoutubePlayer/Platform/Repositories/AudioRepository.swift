//
//  AudioRepository.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/17/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol AudioRepositoryType {
    func getAudioList() -> Observable<[Audio]>
}

struct AudioRepository: AudioRepositoryType {
    func getAudioList() -> Observable<[Audio]> {
        return Observable.just([
            Audio(url: "https://files.freemusicarchive.org/storage-freemusicarchive-org/music/WFMU/Broke_For_Free/Directionless_EP/Broke_For_Free_-_01_-_Night_Owl.mp3",
                  title: "Night Owl"),
            Audio(url: "https://files.freemusicarchive.org/storage-freemusicarchive-org/music/no_curator/Tours/Enthusiast/Tours_-_01_-_Enthusiast.mp3",
                  title: "Enthusiast"),
            Audio(url: "https://files.freemusicarchive.org/storage-freemusicarchive-org/music/no_curator/Jahzzar/Travellers_Guide_Excerpt/Jahzzar_-_05_-_Siesta.mp3",
                  title: "Siesta"),
            Audio(url: "https://files.freemusicarchive.org/storage-freemusicarchive-org/music/ccCommunity/The_Kyoto_Connection/Wake_Up/The_Kyoto_Connection_-_09_-_Hachiko_The_Faithtful_Dog.mp3",
                  title: "Hachiko (The Faithtful Dog)")
        ])
    }
}

