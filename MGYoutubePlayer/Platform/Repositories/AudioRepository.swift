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
                  title: "Night Owl",
                  imageUrl: "https://cdna.artstation.com/p/assets/images/images/017/271/394/large/binh-nguy-n-joker-fan-art.jpg"
            ),
            Audio(url: "https://files.freemusicarchive.org/storage-freemusicarchive-org/music/no_curator/Tours/Enthusiast/Tours_-_01_-_Enthusiast.mp3",
                  title: "Enthusiast",
                  imageUrl: "https://images.fineartamerica.com/images/artworkimages/mediumlarge/2/12-tupac-shakur-artwork-taoteching-art.jpg"
            ),
            Audio(url: "https://files.freemusicarchive.org/storage-freemusicarchive-org/music/no_curator/Jahzzar/Travellers_Guide_Excerpt/Jahzzar_-_05_-_Siesta.mp3",
                  title: "Siesta",
                  imageUrl: "https://www.en.laouina.com/wp-content/uploads/2019/05/andywarholpainting-affordableart-artdealers-artforsale-artwebsites-buyartonline-contemporaryart-bestartistpainter2019-fineart-Banksyartwork-jonathanthepainter-laouina.jpg"
            ),
            Audio(url: "https://files.freemusicarchive.org/storage-freemusicarchive-org/music/ccCommunity/The_Kyoto_Connection/Wake_Up/The_Kyoto_Connection_-_09_-_Hachiko_The_Faithtful_Dog.mp3",
                  title: "Hachiko (The Faithtful Dog)",
                  imageUrl: "https://i.pinimg.com/474x/f1/1f/2e/f11f2e66bfb126a05b0c5bed5827e595.jpg"
            )
        ])
    }
}

