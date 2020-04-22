//
//  MainViewController.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/10/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

final class MainViewController: UITabBarController, BindableType {
    
    // MARK: - Properties
    var viewModel: MainViewModel!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
    }
    
    deinit {
        logDeinit()
    }
    
    // MARK: - Methods
    
    private func configView() {
        addYoutubeMiniPlayer()
        addAudioMiniPlayer()
    }
    
    func bindViewModel() {
        let input = MainViewModel.Input()
        _ = viewModel.transform(input)
    }
    
}

// MARK: - Binders
extension MainViewController {
    
}

// MARK: - Youtube Mini player
extension UITabBarController {
    var youtubeMiniPlayer: YoutubeMiniPlayerView? {
        return view.subviews.first(where: { $0 is YoutubeMiniPlayerView }) as? YoutubeMiniPlayerView
    }
    
    static let youtubeMiniPlayerBottomConstraintIdentifier = "youtubeMiniPlayerBottomConstraint"
    
    var youtubeMiniPlayerBottomConstraint: NSLayoutConstraint? {
        return view.constraints
            .first(where: {
                $0.identifier == UITabBarController.youtubeMiniPlayerBottomConstraintIdentifier
            })
    }
    
    @discardableResult
    func addYoutubeMiniPlayer() -> YoutubeMiniPlayerView {
        if let miniPlayer = self.youtubeMiniPlayer {
            return miniPlayer
        }
        
        let miniPlayer = YoutubeMiniPlayerView.loadFromNib()
        miniPlayer.isUserInteractionEnabled = true
        miniPlayer.closeAction = { [weak self, miniPlayer] in
            miniPlayer.stop()
            self?.hideYoutubeMiniPlayer()
        }
        
        // shadow
        miniPlayer.layer.shadowColor = UIColor.black.cgColor
        miniPlayer.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        miniPlayer.layer.shadowOpacity = 0.2
        miniPlayer.layer.shadowRadius = 10
        miniPlayer.alpha = 0
        
        view.addSubview(miniPlayer)
        
        // constraints
        let config = MiniPlayerConfiguration.youtube
        miniPlayer.translatesAutoresizingMaskIntoConstraints = false
        miniPlayer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: config.leftMargin).isActive = true
        miniPlayer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: config.rightMargin).isActive = true
        miniPlayer.heightAnchor.constraint(equalToConstant: config.height).isActive = true
        
        let bottomConstraint = miniPlayer.bottomAnchor
            .constraint(equalTo: tabBar.topAnchor, constant: config.hiddenBottomMargin)
        bottomConstraint.identifier = UITabBarController.youtubeMiniPlayerBottomConstraintIdentifier
        bottomConstraint.isActive = true
    
        return miniPlayer
    }
    
    func removeYoutubeMiniPlayer() {
        youtubeMiniPlayer?.removeFromSuperview()
    }
    
    func hideYoutubeMiniPlayer(animated: Bool = true) {
        youtubeMiniPlayerBottomConstraint?.constant = MiniPlayerConfiguration.youtube.hiddenBottomMargin
        view.setNeedsUpdateConstraints()
        
        func setMiniPlayerAlpha() {
            youtubeMiniPlayer?.alpha = 0
            view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.33) {
                setMiniPlayerAlpha()
            }
        } else {
            setMiniPlayerAlpha()
        }
    }
    
    func showYoutubeMiniPlayer(animated: Bool = true) {
        youtubeMiniPlayerBottomConstraint?.constant = MiniPlayerConfiguration.youtube.bottomMargin
        view.setNeedsUpdateConstraints()
        
        func setMiniPlayerAlpha() {
            youtubeMiniPlayer?.alpha = 1
            view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.33) {
                setMiniPlayerAlpha()
            }
        } else {
            setMiniPlayerAlpha()
        }
    }
}

// MARK: - Audio Mini player
extension UITabBarController {
    var audioMiniPlayer: AudioMiniPlayerView? {
        return view.subviews.first(where: { $0 is AudioMiniPlayerView }) as? AudioMiniPlayerView
    }
    
    static let audioMiniPlayerBottomConstraintIdentifier = "audioMiniPlayerBottomConstraintIdentifier"
    
    var audioMiniPlayerBottomConstraint: NSLayoutConstraint? {
        return view.constraints
            .first(where: {
                $0.identifier == UITabBarController.audioMiniPlayerBottomConstraintIdentifier
            })
    }
    
    @discardableResult
    func addAudioMiniPlayer() -> AudioMiniPlayerView {
        if let miniPlayer = self.audioMiniPlayer {
            return miniPlayer
        }
        
        let miniPlayer = AudioMiniPlayerView.loadFromNib()
        miniPlayer.isUserInteractionEnabled = true
        miniPlayer.closeAction = { [weak self, miniPlayer] in
            miniPlayer.stop()
            self?.hideAudioMiniPlayer()
        }
        
        // shadow
        miniPlayer.layer.shadowColor = UIColor.black.cgColor
        miniPlayer.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        miniPlayer.layer.shadowOpacity = 0.2
        miniPlayer.layer.shadowRadius = 10
        miniPlayer.alpha = 0
        
        view.addSubview(miniPlayer)
        
        // constraints
        let config = MiniPlayerConfiguration.audio
        miniPlayer.translatesAutoresizingMaskIntoConstraints = false
        miniPlayer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: config.leftMargin).isActive = true
        miniPlayer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: config.rightMargin).isActive = true
        miniPlayer.heightAnchor.constraint(equalToConstant: config.height).isActive = true
        
        let bottomConstraint = miniPlayer.bottomAnchor
            .constraint(equalTo: tabBar.topAnchor, constant: config.hiddenBottomMargin)
        bottomConstraint.identifier = UITabBarController.audioMiniPlayerBottomConstraintIdentifier
        bottomConstraint.isActive = true
        
        return miniPlayer
    }
    
    func removeAudioMiniPlayer() {
        audioMiniPlayer?.removeFromSuperview()
    }
    
    func hideAudioMiniPlayer(animated: Bool = true) {
        audioMiniPlayerBottomConstraint?.constant = MiniPlayerConfiguration.audio.hiddenBottomMargin
        view.setNeedsUpdateConstraints()
        
        func setMiniPlayerAlpha() {
            audioMiniPlayer?.alpha = 0
            view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.33) {
                setMiniPlayerAlpha()
            }
        } else {
            setMiniPlayerAlpha()
        }
    }
    
    func showAudioMiniPlayer(animated: Bool = true) {
        audioMiniPlayerBottomConstraint?.constant = MiniPlayerConfiguration.audio.bottomMargin
        view.setNeedsUpdateConstraints()
        
        func setMiniPlayerAlpha() {
            audioMiniPlayer?.alpha = 1
            view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.33) {
                setMiniPlayerAlpha()
            }
        } else {
            setMiniPlayerAlpha()
        }
    }
}

struct MiniPlayerConfiguration {
    var height: CGFloat = 60
    var leftMargin: CGFloat = 14
    var rightMargin: CGFloat = -14
    var bottomMargin: CGFloat = -12
    var hiddenBottomMargin: CGFloat = 120
    
    static let youtube = MiniPlayerConfiguration()
    static let audio = MiniPlayerConfiguration()
}
