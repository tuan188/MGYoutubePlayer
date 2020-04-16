//
//  MainViewController.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/10/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

final class MainViewController: UITabBarController, BindableType {
    
    // MARK: - IBOutlets
    
    // MARK: - Properties
    var viewModel: MainViewModel!
    
    private var miniPlayerBottomConstraint: NSLayoutConstraint?
    
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
        miniPlayer.closeAction = { [weak self] in
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
        let miniPlayerHeight: CGFloat = 56
        let margin: CGFloat = 12
        miniPlayer.translatesAutoresizingMaskIntoConstraints = false
        miniPlayer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin).isActive = true
        miniPlayer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -margin).isActive = true
        let bottomConstraint = miniPlayer.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: 120)
        bottomConstraint.isActive = true
        self.miniPlayerBottomConstraint = bottomConstraint
        miniPlayer.heightAnchor.constraint(equalToConstant: miniPlayerHeight).isActive = true
    
        return miniPlayer
    }
    
    func removeMiniPlayer() {
        miniPlayer?.removeFromSuperview()
    }
    
    func hideMiniPlayer() {
        miniPlayerBottomConstraint?.constant = 120
        view.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: 0.5) {
            self.miniPlayer?.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func showMiniPlayer() {
        miniPlayerBottomConstraint?.constant = -12
        view.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: 0.5) {
            self.miniPlayer?.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
}

