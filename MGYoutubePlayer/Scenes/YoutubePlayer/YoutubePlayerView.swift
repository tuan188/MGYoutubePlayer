//
//  YoutubePlayerView.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/26/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

final class YoutubePlayerView: UIView, NibOwnerLoadable {
    @IBOutlet weak var slider: ProgressSlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playerBackgroundView: UIView!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    private var player: YoutubePlayer?
    private var disposeBag = DisposeBag()
    
    private let loadTrigger = PublishSubject<String>()
    private let playTrigger = PublishSubject<Void>()
    private let stopTrigger = PublishSubject<Void>()
    private let seekTrigger = PublishSubject<YoutubePlayerViewModel.SeekState>()
    
    var isConfigured: Bool {
        return player != nil
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
    }
    
    @IBAction private func play(_ sender: Any) {
        playTrigger.onNext(())
    }
    
    func load(videoId: String) {
        loadTrigger.onNext(videoId)
    }
    
    func configPlayer() {
        // Init player
        let player = YoutubePlayer()
        player.addPlayer(to: playerBackgroundView)
        self.player = player
        
        // Binding
        bindViewModel()
    }
    
    func bindViewModel() {
        guard let player = self.player else { return }
        
        disposeBag = DisposeBag()
        
        let input = YoutubePlayerViewModel.Input(
            loadTrigger: loadTrigger.asDriverOnErrorJustComplete(),
            playTrigger: playTrigger.asDriverOnErrorJustComplete(),
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
            .drive(onNext: { [unowned self] videoId in
                self.player?.load(videoId: videoId)
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
            .drive(onNext: { [unowned self] duration in
                self.slider.maximumValue = Float(duration)
                self.durationLabel.text = duration.toMMSS()
            })
            .disposed(by: disposeBag)
        
        output.remainingTime
            .drive(onNext: { [unowned self] remainingTime in
                self.remainingTimeLabel.text = "-" + remainingTime.toMMSS()
            })
            .disposed(by: disposeBag)
        
        output.loadedFraction
            .drive(onNext: { progress in
                self.slider.loadedProgress = CGFloat(progress)
            })
            .disposed(by: disposeBag)
        
        output.playTime
            .drive(onNext: { [unowned self] playTime in
                self.slider.value = Float(playTime)
                self.playTimeLabel.text = playTime.toMMSS()
            })
            .disposed(by: disposeBag)
        
        output.isReady
            .drive(onNext: { [unowned self] isReady in
                print("Ready:", isReady)
                self.playButton.isEnabled = isReady
                self.slider.isEnabled = isReady
            })
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
        
        output.seek
            .drive(onNext: { [unowned self] time in
                print("seek")
                self.player?.seek(to: time)
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        player?.bingPlayerToFront()
    }
    
    @IBAction private func progressSliderValueChanged(_ sender: UISlider) {
        seekTrigger.onNext(.dragging(sender.value))
    }
    
    @IBAction private func progressSliderTouchedDown(_ sender: UISlider) {
        guard sender.isEnabled else { return }
        seekTrigger.onNext(.dragging(sender.value))
    }
    
    @IBAction private func progressSliderTouchedUpInside(_ sender: UISlider) {
        guard sender.isEnabled else { return }
        seekTrigger.onNext(.seek(sender.value))
        seekTrigger.onNext(.none)
    }
    
    @IBAction private func progressSliderTouchedUpOutside(_ sender: UISlider) {
        guard sender.isEnabled else { return }
        seekTrigger.onNext(.seek(sender.value))
        seekTrigger.onNext(.none)
    }
    
    @IBAction private func progressSliderTouchedCancel(_ sender: UISlider) {
        guard sender.isEnabled else { return }
        seekTrigger.onNext(.seek(sender.value))
        seekTrigger.onNext(.none)
    }
}
