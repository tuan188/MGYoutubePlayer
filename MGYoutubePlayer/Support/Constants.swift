//
//  Constants.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/16/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

extension Notification.Name {
    static let showVideo = Notification.Name(rawValue: "showVideo")
    static let showAudio = Notification.Name(rawValue: "showAudio")
    static let stopYoutubeMiniPlayer = Notification.Name(rawValue: "stopYoutubeMiniPlayer")
    static let stopAudioMiniPlayer = Notification.Name(rawValue: "stopAudioMiniPlayer")
}

extension UIImage {
    static let play = UIImage(named: "play")
    static let pause = UIImage(named: "pause")
    static let videos = UIImage(named: "videos")
    static let audios = UIImage(named: "audios")
    static let slider = UIImage(named: "slider")
    static let audioCover = UIImage(named: "audio_cover")
}
