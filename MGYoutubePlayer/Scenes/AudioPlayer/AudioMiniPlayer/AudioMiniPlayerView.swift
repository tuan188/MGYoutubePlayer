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

    private let loadTrigger = PublishSubject<AudioProtocol>()
    private let setAudioTrigger = PublishSubject<AudioProtocol>()
    private var disposeBag = DisposeBag()
    
    // HavingAudioPlayer
    var notificationDisposeBag = DisposeBag()
    var player: AudioPlayer?
    var playTarget: Any?
    var pauseTarget: Any?
    var backwardTarget: Any?
    var forwardTarget: Any?
    var changePositionTarget: Any?
    
    var closeAction: (() -> Void)?
    
    struct Configuration {
        var height: CGFloat = 60
        var leftMargin: CGFloat = 14
        var rightMargin: CGFloat = -14
        var bottomMargin: CGFloat = -12
        var hiddenBottomMargin: CGFloat = 120
        
        static let `default` = Configuration()
    }
    
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
    
    func load(audio: AudioProtocol) {
        loadTrigger.onNext(audio)
    }
    
    func configPlayer() {
        // Init player
        let player = AudioPlayer()
        self.player = player
        
        // Binding
        bindViewModel()
    }
    
    // MARK: - HavingAudioPlayer
    
    func setAudio(_ audio: AudioProtocol) {
        
    }
    
    func updateNowPlaying() {
        guard let player = self.player,
            let audio = player.audio
            else { return }
        
        self.updateNowPlayingInfoCenter(
            isPlaying: player.isPlaying,
            title: audio.title,
            playTime: player.playTime,
            duration: player.duration,
            artWorkImage: imageView.image
        )
    }
    
    // MARK: - Bindings
    
    func bindViewModel() {
        guard let player = self.player else { return }
        
        disposeBag = DisposeBag()
        
        let stopTrigger = NotificationCenter.default.rx.notification(.stopAudioMiniPlayer)
            .map { $0.object as? String }
            .asDriverOnErrorJustComplete()
        
        let input = AudioMiniPlayerViewModel.Input(
            setAudioTrigger: setAudioTrigger.asDriverOnErrorJustComplete(),
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
        
        output.audio
            .drive(onNext: { [unowned self] audio in
                self.titleLabel.text = audio.title
                self.imageView.sd_setImage(with: URL(string: audio.artworkUrl),
                                           placeholderImage: UIImage.audioCover,
                                           progress: nil,
                                           completed: nil)
            })
            .disposed(by: disposeBag)
        
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
                if let owner = self.player?.owner {
                    self.player?.pause()
                    self.movePlayer(to: owner)
                } else {
                    self.player?.stop()
                    self.unbindViewModel()
                    self.player = nil
                }
                
                self.cleanup()
            })
            .disposed(by: disposeBag)
        
        output.duration
            .drive(onNext: { [unowned self] _ in
                self.updateNowPlaying()
            })
            .disposed(by: disposeBag)
        
        output.remainingTime
            .drive()
            .disposed(by: disposeBag)
        
        output.playTime
            .drive(onNext: { [unowned self] _ in
                self.updateNowPlaying()
            })
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
                
                let image: UIImage?
                
                switch state {
                case .waiting:
                    image = UIImage.pause
                case .playing:
                    image = UIImage.pause
                    
                    self.cleanup()
                    
                    // Notifications
                    self.registerInterruptionAndRouteChangeNotifications()
                    
                    // Info Center
                    self.setupRemoteTransportControls()
                default:
                    image = UIImage.play
                }
                
                self.updateNowPlaying()
                self.playButton.setImage(image, for: .normal)
            })
            .disposed(by: disposeBag)
    }
    
    func unbindViewModel() {
        disposeBag = DisposeBag()
        notificationDisposeBag = DisposeBag()
    }
}
