//
//  MainViewController.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/10/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

final class MainViewController: UITabBarController, BindableType {
    
    static weak var shared: MainViewController?
    
    // MARK: - Properties
    var viewModel: MainViewModel!
    
    private var miniPlayerBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MainViewController.shared = self
        
        configView()
    }
    
    deinit {
        logDeinit()
    }
    
    // MARK: - Methods
    
    private func configView() {
        addMiniPlayer()
    }
    
    func bindViewModel() {
        let input = MainViewModel.Input()
        _ = viewModel.transform(input)
    }
    
}

// MARK: - Binders
extension MainViewController {
    
}

// MARK: - Mini player
extension MainViewController {
    var miniPlayer: YoutubeMiniPlayerView? {
        return view.subviews.first(where: { $0 is YoutubeMiniPlayerView }) as? YoutubeMiniPlayerView
    }
    
    var hasMiniPlayer: Bool {
        return miniPlayer?.player != nil
    }
    
    @discardableResult
    func addMiniPlayer() -> YoutubeMiniPlayerView {
        if let miniPlayer = self.miniPlayer {
            return miniPlayer
        }
        
        let miniPlayer = YoutubeMiniPlayerView.loadFromNib()
        miniPlayer.isUserInteractionEnabled = true
        miniPlayer.closeAction = { [weak self, miniPlayer] in
            miniPlayer.stop()
            self?.hideMiniPlayer()
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
        let bottomConstraint = miniPlayer.bottomAnchor.constraint(equalTo: tabBar.topAnchor,
                                                                  constant: config.hiddenBottomMargin)
        bottomConstraint.isActive = true
        self.miniPlayerBottomConstraint = bottomConstraint
        miniPlayer.heightAnchor.constraint(equalToConstant: config.height).isActive = true
    
        return miniPlayer
    }
    
    func removeMiniPlayer() {
        miniPlayer?.removeFromSuperview()
    }
    
    func hideMiniPlayer(animated: Bool = true) {
        miniPlayerBottomConstraint?.constant = MiniPlayerConfiguration.youtube.hiddenBottomMargin
        view.setNeedsUpdateConstraints()
        
        func setMiniPlayerAlpha() {
            miniPlayer?.alpha = 0
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
    
    func showMiniPlayer(animated: Bool = true) {
        miniPlayerBottomConstraint?.constant = MiniPlayerConfiguration.youtube.bottomMargin
        view.setNeedsUpdateConstraints()
        
        func setMiniPlayerAlpha() {
            miniPlayer?.alpha = 1
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
}
