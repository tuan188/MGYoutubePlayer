//
//  YoutubeMiniPlayerViewModel.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/13/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

struct YoutubeMiniPlayerViewModel {
    var video: VideoProtocol?
}

// MARK: - ViewModelType
extension YoutubeMiniPlayerViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<VideoProtocol>
        let playTrigger: Driver<Void>
        let stopTrigger: Driver<String?>
        let playTime: Driver<Float>
        let state: Driver<YoutubePlayer.State>
        let duration: Driver<Float>
        let remainingTime: Driver<Float>
        let isReady: Driver<Bool>
    }
    
    struct Output {
        let load: Driver<VideoProtocol>
        let play: Driver<Void>
        let pause: Driver<Void>
        let stop: Driver<Void>
        let playTime: Driver<Float>
        let state: Driver<YoutubePlayer.State>
        let duration: Driver<Float>
        let remainingTime: Driver<Float>
        let progress: Driver<Float>
        let isReady: Driver<Bool>
        let videoTitle: Driver<String>
    }
    
    func transform(_ input: Input) -> Output {
        let video = input.loadTrigger
            .mapToOptional()
            .startWith(self.video)
            .unwrap()
        
        let videoTitle = video
            .map { $0.title }
        
        let state = input.state
        
        let playState = input.playTrigger
            .withLatestFrom(state)
            
        let play = playState
            .filter { $0 != .playing && $0 != .buffering }
            .mapToVoid()
        
        let pause = playState
            .filter { $0 == .playing || $0 == .buffering }
            .mapToVoid()
        
        let progress = Driver.combineLatest(input.playTime, input.duration) { $0 / $1 }
        
        let stop = input.stopTrigger
            .withLatestFrom(video) { ($0, $1) }
            .filter { playingVideoId, video in
                guard let playingVideoId = playingVideoId else { return true }
                return video.id != playingVideoId
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
            videoTitle: videoTitle
        )
    }
}
