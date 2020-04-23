//
//  UITabBarController+YoutubePlayer.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/23/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

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
        let config = YoutubeMiniPlayerView.Configuration.default
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
        youtubeMiniPlayerBottomConstraint?.constant = YoutubeMiniPlayerView.Configuration.default.hiddenBottomMargin
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
        youtubeMiniPlayerBottomConstraint?.constant = YoutubeMiniPlayerView.Configuration.default.bottomMargin
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
