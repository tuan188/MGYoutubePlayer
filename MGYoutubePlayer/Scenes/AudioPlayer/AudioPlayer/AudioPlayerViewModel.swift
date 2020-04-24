//
//  AudioPlayerViewModel.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/21/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

struct AudioPlayerViewModel: ViewModelType {
    enum SeekState {
        case none
        case dragging(Double)
        case seek(Double)
    }
    
    struct Input {
        let setAudioTrigger: Driver<AudioProtocol>
        let loadTrigger: Driver<AudioProtocol>
        let playTrigger: Driver<Void>
        let stopTrigger: Driver<Void>
        let seekTrigger: Driver<AudioPlayerViewModel.SeekState>
        let playTime: Driver<Double>
        let state: Driver<AudioPlayer.State>
        let duration: Driver<Double>
        let remainingTime: Driver<Double>
        let isReady: Driver<Bool>
        let loadedFraction: Driver<Double>
    }
    
    struct Output {
        let audio: Driver<AudioProtocol>
        let load: Driver<AudioProtocol>
        let play: Driver<Void>
        let pause: Driver<Void>
        let stop: Driver<Void>
        let seek: Driver<Double>
        let playTime: Driver<Double>
        let state: Driver<AudioPlayer.State>
        let duration: Driver<Double>
        let remainingTime: Driver<Double>
        let isReady: Driver<Bool>
        let loadedFraction: Driver<Double>
    }
    
    func transform(_ input: Input) -> Output {
        let audio = Driver.merge(input.setAudioTrigger, input.loadTrigger)
        
        let state = input.state
        
        let playState = input.playTrigger
            .withLatestFrom(state)
        
        let play = playState
            .filter { $0 != .playing && $0 != .waiting }
            .mapToVoid()
        
        let pause = playState
            .filter { $0 == .playing || $0 == .waiting }
            .mapToVoid()
        
        let seekState = input.seekTrigger
            .startWith(.none)
        
        let seek = seekState
            .mapToOptional()
            .map { state -> Double? in
                if case let .seek(seconds) = state {
                    return seconds
                }
                return nil
            }
            .unwrap()
        
        let seekTime = seekState
            .mapToOptional()
            .map { state -> Double? in
                if case let .dragging(seconds) = state {
                    return seconds
                }
                return nil
            }
            .unwrap()
        
        let playTime = input.playTime
            .withLatestFrom(seekState) { ($0, $1) }
            .filter { _, seekState in
                switch seekState {
                case .dragging, .seek:
                    return false
                default:
                    return true
                }
            }
            .map { $0.0 }
        
        let displayTime = Driver.merge(playTime, seekTime)
        
        let remainingTime = Driver.combineLatest(input.duration, displayTime) { $0 - $1 }
        
        return Output(
            audio: audio,
            load: input.loadTrigger,
            play: play,
            pause: pause,
            stop: input.stopTrigger,
            seek: seek,
            playTime: displayTime,
            state: state,
            duration: input.duration,
            remainingTime: remainingTime,
            isReady: input.isReady,
            loadedFraction: input.loadedFraction
        )
    }
}
