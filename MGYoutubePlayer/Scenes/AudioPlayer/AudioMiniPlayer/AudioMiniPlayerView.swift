//
//  AudioMiniPlayerView.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/20/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

final class AudioMiniPlayerView: UIView, NibLoadable, HavingAudioPlayer {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    private var disposeBag = DisposeBag()
    private let loadTrigger = PublishSubject<Audio>()
    
    var player: AudioPlayer?
    
    var closeAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(tapGesture)
        
        tintColor = UIColor(white: 0.1, alpha: 1)
        progressView.tintColor = UIColor.purple
    }
    
    @objc
    private func tap() {
        guard let video = player?.audio else { return }
        NotificationCenter.default.post(name: .showAudio, object: video)
    }
    
    @IBAction private func close(_ sender: Any) {
        closeAction?()
    }
    
    deinit {
        print("AudioMiniPlayerView deinit")
    }
    
    func load(audio: Audio) {
        loadTrigger.onNext(audio)
    }
    
    func configPlayer() {
        // Init player
        let player = AudioPlayer()
        self.player = player
        
        // Binding
        bindViewModel()
    }
    
    func bindViewModel() {
        guard let player = self.player else { return }
        
        disposeBag = DisposeBag()
        
        let stopTrigger = NotificationCenter.default.rx.notification(.stopAudioMiniPlayer)
            .map { $0.object as? Audio }
            .asDriverOnErrorJustComplete()
        
        let input = AudioMiniPlayerViewModel.Input(
            loadTrigger: loadTrigger.asDriverOnErrorJustComplete(),
            playTrigger: playButton.rx.tap.asDriver(),
            stopTrigger: stopTrigger,
            playTime: player.rx.playTime,
            state: player.rx.state,
            duration: player.rx.duration,
            remainingTime: player.rx.remainingTime,
            isReady: player.rx.isReady
        )
        
        let viewModel = AudioMiniPlayerViewModel(audio: player.audio)
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
            .drive()
            .disposed(by: disposeBag)
        
        output.remainingTime
            .drive()
            .disposed(by: disposeBag)
        
        output.playTime
            .drive()
            .disposed(by: disposeBag)
        
        output.progress
            .map { Float($0) }
            .drive(progressView.rx.progress)
            .disposed(by: disposeBag)
        
        output.isReady
            .drive(playButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.state
            .drive(onNext: { [unowned self] state in
                print("Youtube Mini Player", state)
                
                switch state {
                case .playing, .waiting:
                    self.playButton.setImage(UIImage.pause, for: .normal)
                default:
                    self.playButton.setImage(UIImage.play, for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        output.audioTitle
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func unbindViewModel() {
        disposeBag = DisposeBag()
    }
}
