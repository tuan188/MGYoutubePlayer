//
//  AudioPlayerView.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/20/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

final class AudioPlayerView: UIView, NibOwnerLoadable, HavingAudioPlayer {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var slider: ProgressSlider!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    private var disposeBag = DisposeBag()
    private let loadTrigger = PublishSubject<Audio>()
    private let stopTrigger = PublishSubject<Void>()
    private let seekTrigger = PublishSubject<AudioPlayerViewModel.SeekState>()
    
    var player: AudioPlayer?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
        configView()
    }
    
    private func configView() {
        coverImageView.clipsToBounds = false
        coverImageView.layer.shadowColor = UIColor.black.cgColor
        coverImageView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        coverImageView.layer.shadowOpacity = 0.5
        coverImageView.layer.shadowRadius = 10
        
        slider.setThumbImage(UIImage.slider, for: .normal)
        
        let valueChanged = slider.rx.controlEvent(.valueChanged).asDriver()
        let touchDown = slider.rx.controlEvent(.touchDown).asDriver()
        
        Driver.merge(valueChanged, touchDown)
            .drive(onNext: { [unowned self] in
                let value = Double(self.slider.value)
                self.seekTrigger.onNext(.dragging(value))
            })
            .disposed(by: rx.disposeBag)
        
        let touchUpInside = slider.rx.controlEvent(.touchUpInside).asDriver()
        let touchUpOutside = slider.rx.controlEvent(.touchUpOutside).asDriver()
        let touchCancel = slider.rx.controlEvent(.touchCancel).asDriver()
        
        Driver.merge(touchUpInside, touchUpOutside, touchCancel)
            .drive(onNext: { [unowned self] in
                let value = Double(self.slider.value)
                self.seekTrigger.onNext(.seek(value))
            })
            .disposed(by: rx.disposeBag)
    }
    
    func load(audio: Audio) {
        if player == nil {
            configPlayer()
        } else {
            bindViewModel()
        }
        
        loadTrigger.onNext(audio)
    }
    
    private func configPlayer() {
        // Init player
        self.player = AudioPlayer()
        
        // Binding
        bindViewModel()
    }
    
    func bindViewModel() {
        guard let player = self.player else { return }
        
        disposeBag = DisposeBag()
        
        let input = AudioPlayerViewModel.Input(
            loadTrigger: loadTrigger.asDriverOnErrorJustComplete(),
            playTrigger: playButton.rx.tap.asDriver(),
            stopTrigger: stopTrigger.asDriverOnErrorJustComplete(),
            seekTrigger: seekTrigger.asDriverOnErrorJustComplete(),
            playTime: player.rx.playTime,
            state: player.rx.state,
            duration: player.rx.duration,
            remainingTime: player.rx.remainingTime,
            isReady: player.rx.isReady,
            loadedFraction: player.rx.loadedFraction
        )
        
        let viewModel = AudioPlayerViewModel()
        let output = viewModel.transform(input)
        
        output.load
            .drive(onNext: { [unowned self] audio in
                self.player?.load(audio: audio)
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
                self.slider.maximumValue = Float(duration)
            })
            .disposed(by: disposeBag)
        
        output.remainingTime
            .drive(onNext: { [unowned self] remainingTime in
                self.remainingTimeLabel.text = "-" + remainingTime.toMMSS()
            })
            .disposed(by: disposeBag)
        
        output.loadedFraction
            .drive(onNext: { [unowned self] progress in
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
                self.playTimeLabel.isHidden = !isReady
                
                if isReady {
                    self.activityIndicatorView.stopAnimating()
                } else {
                    self.remainingTimeLabel.text = "--:--"
                    self.activityIndicatorView.startAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        output.state
            .drive(onNext: { [unowned self] state in
                print("Audio Player", state)
                
                let image: UIImage?
                
                switch state {
                case .waiting:
                    image = UIImage.pause
                case .playing:
                    image = UIImage.pause
                    self.stopMiniPlayer()
                default:
                    image = UIImage.play
                }
                
                self.playButton.setImage(image, for: .normal)
            })
            .disposed(by: disposeBag)
        
        output.seek
            .drive(onNext: { [unowned self] time in
                print("seek")
                self.player?.seek(to: time, completion: { (success) in
                    print("seek success:", success)
                    self.seekTrigger.onNext(.none)
                    self.player?.play()
                })
            })
            .disposed(by: disposeBag)
    }
    
    func unbindViewModel() {
        disposeBag = DisposeBag()
    }
    
    func stopMiniPlayer() {
        NotificationCenter.default.post(name: .stopAudioMiniPlayer, object: player?.audio)
    }

}
