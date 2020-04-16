//
//  YoutubeMiniPlayerView.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

final class YoutubeMiniPlayerView: UIView, NibLoadable, HavingYoutubePlayer {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    private var disposeBag = DisposeBag()
    private let loadTrigger = PublishSubject<Video>()
    private let stopTrigger = PublishSubject<Void>()
    
    var player: YoutubePlayer?
    
    var closeAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func tap() {
        guard let video = player?.video else { return }
        NotificationCenter.default.post(name: .showVideo, object: video)
    }
    
    var videoContainerView: UIView {
        return containerView
    }
    
    @IBAction private func close(_ sender: Any) {
        closeAction?()
    }
    
    deinit {
        print("YoutubeMiniPlayerView deinit")
    }
    
    func load(video: Video) {
        loadTrigger.onNext(video)
    }
    
    func configPlayer() {
        // Init player
        let player = YoutubePlayer()
        player.addPlayer(to: containerView)
        self.player = player
        
        // Binding
        bindViewModel()
    }
    
    func bindViewModel() {
        guard let player = self.player else { return }
        
        disposeBag = DisposeBag()
        
        let input = YoutubeMiniPlayerViewModel.Input(
            loadTrigger: loadTrigger.asDriverOnErrorJustComplete(),
            playTrigger: playButton.rx.tap.asDriver(),
            stopTrigger: stopTrigger.asDriverOnErrorJustComplete(),
            playTime: player.rx.playTime,
            state: player.rx.state,
            duration: player.rx.duration,
            remainingTime: player.rx.remainingTime,
            isReady: player.rx.isReady
        )
        
        let viewModel = YoutubeMiniPlayerViewModel(video: player.video)
        let output = viewModel.transform(input)
        
        output.load
            .drive(onNext: { [unowned self] video in
                self.player?.load(video: video)
            })
            .disposed(by: disposeBag)
        
        output.play
            .drive(onNext: { [unowned self] in
                self.player?.play()
            })
            .disposed(by: rx.disposeBag)
        
        output.pause
            .drive(onNext: { [unowned self] in
                self.player?.pause()
            })
            .disposed(by: rx.disposeBag)
        
        output.duration
            .drive()
            .disposed(by: disposeBag)
        
        output.remainingTime
            .drive()
            .disposed(by: disposeBag)
        
        output.playTime
            .drive()
            .disposed(by: disposeBag)
        
        output.progress
            .drive(progressView.rx.progress)
            .disposed(by: rx.disposeBag)
        
        output.isReady
            .drive(playButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.state
            .drive(onNext: { [unowned self] state in
                print(state)
                
                switch state {
                case .playing, .buffering:
                    self.playButton.setTitle("Pause", for: .normal)
                default:
                    self.playButton.setTitle("Play", for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        output.videoTitle
            .drive(titleLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }
    
    func unbindViewModel() {
        disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        player?.bingPlayerToFront()
    }
}