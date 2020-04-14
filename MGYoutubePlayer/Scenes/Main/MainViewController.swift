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
        
    }
    
    func bindViewModel() {
        let input = MainViewModel.Input()
        _ = viewModel.transform(input)
    }
    
}

// MARK: - Binders
extension MainViewController {
    
}

extension UITabBarController {
    var miniPlayer: YoutubeMiniPlayerView? {
        return view.subviews.first(where: { $0 is YoutubeMiniPlayerView }) as? YoutubeMiniPlayerView
    }
    
    var hasMiniPlayer: Bool {
        return miniPlayer != nil
    }
    
    @discardableResult
    func addMiniPlayer() -> YoutubeMiniPlayerView {
        if let miniPlayer = self.miniPlayer {
            return miniPlayer
        }
        
        var bottomInset: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            if let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets {
                bottomInset = safeAreaInsets.bottom
            }
        }
        
        let miniPlayer = YoutubeMiniPlayerView.loadFromNib()
        miniPlayer.isUserInteractionEnabled = true
        
        let screenSize = UIScreen.main.bounds
        let miniPlayerHeight: CGFloat = 64
        miniPlayer.frame = CGRect(x: 0,
                                  y: screenSize.height + bottomInset - miniPlayerHeight - tabBar.bounds.height,
                                  width: screenSize.width,
                                  height: miniPlayerHeight)
        view.addSubview(miniPlayer)
        return miniPlayer
    }
    
    func removeMiniPlayer() {
        miniPlayer?.removeFromSuperview()
    }
}

