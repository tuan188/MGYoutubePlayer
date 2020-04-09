//
//  YoutubePlayerViewModel.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/8/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

final class YoutubePlayerViewModel: ViewModelType {
    
    enum SeekState {
        case none
        case dragging(Float)
        case seek(Float)
    }
    
    struct Input {
        let loadTrigger: Driver<String>
        let playTrigger: Driver<Void>
        let stopTrigger: Driver<Void>
        let seekTrigger: Driver<YoutubePlayerViewModel.SeekState>
        let playTime: Driver<Float>
        let state: Driver<YoutubePlayer.State>
        let duration: Driver<Float>
        let remainingTime: Driver<Float>
        let isReady: Driver<Bool>
        let loadedFraction: Driver<Float>
    }
    
    struct Output {
        let load: Driver<String>
        let play: Driver<Void>
        let pause: Driver<Void>
        let stop: Driver<Void>
        let seek: Driver<Float>
        let playTime: Driver<Float>
        let state: Driver<YoutubePlayer.State>
        let duration: Driver<Float>
        let remainingTime: Driver<Float>
        let isReady: Driver<Bool>
        let loadedFraction: Driver<Float>
    }
    
    func transform(_ input: Input) -> Output {
        let state = input.state
        
        let play = input.playTrigger
            .withLatestFrom(input.state)
            .filter { $0 != .playing && $0 != .buffering }
            .mapToVoid()
        
        let pause = input.playTrigger
            .withLatestFrom(input.state)
            .filter { $0 == .playing || $0 == .buffering }
            .mapToVoid()
        
        let seekState = input.seekTrigger
            .startWith(.none)
        
        let seek = seekState
            .mapToOptional()
            .map { state -> Float? in
                if case let .seek(seconds) = state {
                    return seconds
                }
                return nil
            }
            .unwrap()
        
        let seekTime = seekState
            .mapToOptional()
            .map { state -> Float? in
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
