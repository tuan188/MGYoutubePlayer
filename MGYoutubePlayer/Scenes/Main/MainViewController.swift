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
    static var shared: MainViewController?
    
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
