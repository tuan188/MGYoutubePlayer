//
//  UITabBarController+AudioPlayer.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/23/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

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
        miniPlayer.closeAction = { [weak self, weak miniPlayer] in
            self?.hideAudioMiniPlayer()
            miniPlayer?.pause()
            miniPlayer?.stop()
            miniPlayer?.cleanup()
            miniPlayer?.resetNowPlayingInfoCenter()
            miniPlayer?.unbindViewModel()
            miniPlayer?.player = nil
        }
        
        // shadow
        miniPlayer.layer.shadowColor = UIColor.black.cgColor
        miniPlayer.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        miniPlayer.layer.shadowOpacity = 0.2
        miniPlayer.layer.shadowRadius = 10
        miniPlayer.alpha = 0
        
        view.addSubview(miniPlayer)
        
        // constraints
        let config = AudioMiniPlayerView.Configuration.default
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
        audioMiniPlayerBottomConstraint?.constant = AudioMiniPlayerView.Configuration.default.hiddenBottomMargin
        view.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: animated ? 0.33 : 0) {
            self.audioMiniPlayer?.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func showAudioMiniPlayer(animated: Bool = true) {
        audioMiniPlayerBottomConstraint?.constant = AudioMiniPlayerView.Configuration.default.bottomMargin
        view.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: animated ? 0.33 : 0) {
            self.audioMiniPlayer?.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
}
