//
//  AudioMiniPlayerViewModel.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/22/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

struct AudioMiniPlayerViewModel {
    var audio: Audio?
}

// MARK: - ViewModelType
extension AudioMiniPlayerViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Audio>
        let playTrigger: Driver<Void>
        let stopTrigger: Driver<Audio?>
        let playTime: Driver<Double>
        let state: Driver<AudioPlayer.State>
        let duration: Driver<Double>
        let remainingTime: Driver<Double>
        let isReady: Driver<Bool>
    }
    
    struct Output {
        let load: Driver<Audio>
        let play: Driver<Void>
        let pause: Driver<Void>
        let stop: Driver<Void>
        let playTime: Driver<Double>
        let state: Driver<AudioPlayer.State>
        let duration: Driver<Double>
        let remainingTime: Driver<Double>
        let progress: Driver<Double>
        let isReady: Driver<Bool>
        let audioTitle: Driver<String>
    }
    
    func transform(_ input: Input) -> Output {
        let audio = input.loadTrigger
            .mapToOptional()
            .startWith(self.audio)
            .unwrap()
        
        let audioTitle = audio
            .map { $0.title }
        
        let state = input.state
        
        let playState = input.playTrigger
            .withLatestFrom(state)
        
        let play = playState
            .filter { $0 != .playing && $0 != .waiting }
            .mapToVoid()
        
        let pause = playState
            .filter { $0 == .playing || $0 == .waiting }
            .mapToVoid()
        
        let progress = Driver.combineLatest(input.playTime, input.duration) { $0 / $1 }
        
        let stop = input.stopTrigger
            .withLatestFrom(audio) { ($0, $1) }
            .filter { playingAudio, thisAudio in
                guard let playingAudio = playingAudio else { return true }
                return !playingAudio.isSameAs(thisAudio)
            }
            .mapToVoid()
        
        return Output(
            load: input.loadTrigger,
            play: play,
            pause: pause,
            stop: stop,
            playTime: input.playTime,
            state: state,
            duration: input.duration,
            remainingTime: input.remainingTime,
            progress: progress,
            isReady: input.isReady,
            audioTitle: audioTitle
        )
    }
}
