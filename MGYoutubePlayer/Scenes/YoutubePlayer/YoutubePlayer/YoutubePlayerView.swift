//
//  YoutubePlayerView.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/26/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

final class YoutubePlayerView: UIView, NibOwnerLoadable, HavingYoutubePlayer {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var controlBarView: YoutubePlayerControlBarView!
    
    // MARK: - Properties
    
    private var disposeBag = DisposeBag()
    private let loadTrigger = PublishSubject<Video>()
    private let stopTrigger = PublishSubject<Void>()
    private let seekTrigger = PublishSubject<YoutubePlayerViewModel.SeekState>()
    
    var player: YoutubePlayer?
    
    var videoContainerView: UIView {
        return containerView
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
        configView()
    }
    
    private func configView() {
        controlBarView.tintColor = UIColor.white
        
        let valueChanged = controlBarView.slider.rx.controlEvent(.valueChanged).asDriver()
        let touchDown = controlBarView.slider.rx.controlEvent(.touchDown).asDriver()
            
        Driver.merge(valueChanged, touchDown)
            .drive(onNext: { [unowned self] in
                let value = self.controlBarView.slider.value
                self.seekTrigger.onNext(.dragging(value))
            })
            .disposed(by: rx.disposeBag)
        
        let touchUpInside = controlBarView.slider.rx.controlEvent(.touchUpInside).asDriver()
        let touchUpOutside = controlBarView.slider.rx.controlEvent(.touchUpOutside).asDriver()
        let touchCancel = controlBarView.slider.rx.controlEvent(.touchCancel).asDriver()
        
        Driver.merge(touchUpInside, touchUpOutside, touchCancel)
            .drive(onNext: { [unowned self] in
                let value = self.controlBarView.slider.value
                self.seekTrigger.onNext(.seek(value))
                self.seekTrigger.onNext(.none)
            })
            .disposed(by: rx.disposeBag)
    }
    
    deinit {
        print("YoutubePlayerView deinit")
    }
    
    func load(video: Video) {
        if player == nil {
            configPlayer()
        } else {
            bindViewModel()
        }
        
        loadTrigger.onNext(video)
    }
    
    private func configPlayer() {
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
        
        let input = YoutubePlayerViewModel.Input(
            loadTrigger: loadTrigger.asDriverOnErrorJustComplete(),
            playTrigger: controlBarView.playButton.rx.tap.asDriver(),
            stopTrigger: stopTrigger.asDriverOnErrorJustComplete(),
            seekTrigger: seekTrigger.asDriverOnErrorJustComplete(),
            playTime: player.rx.playTime,
            state: player.rx.state,
            duration: player.rx.duration,
            remainingTime: player.rx.remainingTime,
            isReady: player.rx.isReady,
            loadedFraction: player.rx.loadedFraction
        )
        
        let viewModel = YoutubePlayerViewModel()
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
            .disposed(by: disposeBag)
        
        output.pause
            .drive(onNext: { [unowned self] in
                self.player?.pause()
            })
            .disposed(by: disposeBag)
        
        output.stop
            .drive(onNext: { [unowned self] in
                self.player?.stop()
            })
            .disposed(by: disposeBag)
        
        output.duration
            .drive(onNext: { [unowned self] duration in
                self.controlBarView.slider.maximumValue = Float(duration)
            })
            .disposed(by: disposeBag)
        
        output.remainingTime
            .drive(onNext: { [unowned self] remainingTime in
                self.controlBarView.remainingTimeLabel.text = "-" + remainingTime.toMMSS()
            })
            .disposed(by: disposeBag)
        
        output.loadedFraction
            .drive(onNext: { [unowned self] progress in
                self.controlBarView.slider.loadedProgress = CGFloat(progress)
            })
            .disposed(by: disposeBag)
        
        output.playTime
            .drive(onNext: { [unowned self] playTime in
                self.controlBarView.slider.value = Float(playTime)
                self.controlBarView.playTimeLabel.text = playTime.toMMSS()
            })
            .disposed(by: disposeBag)
        
        output.isReady
            .drive(onNext: { [unowned self] isReady in
                print("Ready:", isReady)
                self.controlBarView.playButton.isEnabled = isReady
                self.controlBarView.slider.isEnabled = isReady
                self.controlBarView.playTimeLabel.isHidden = !isReady
                
                if isReady {
                    self.controlBarView.activityIndicatorView.stopAnimating()
                } else {
                    self.controlBarView.remainingTimeLabel.text = "--:--"
                    self.controlBarView.activityIndicatorView.startAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        output.state
            .drive(onNext: { [unowned self] state in
                print("Youtube Player", state)
                
                switch state {
                case .playing, .buffering:
                    self.controlBarView.playButton.setImage(UIImage.pause, for: .normal)
                    self.stopOtherPlayers()
                default:
                    self.controlBarView.playButton.setImage(UIImage.play, for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        output.seek
            .drive(onNext: { [unowned self] time in
                print("seek")
                self.player?.seek(to: time)
                self.player?.play()
            })
            .disposed(by: disposeBag)
    }
    
    func unbindViewModel() {
        disposeBag = DisposeBag()
    }
    
    func stopOtherPlayers() {
        NotificationCenter.default.post(name: .stopYoutubeMiniPlayer, object: player?.video)
        NotificationCenter.default.post(name: .stopAudioMiniPlayer, object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        player?.bingPlayerToFront()
    }
}
