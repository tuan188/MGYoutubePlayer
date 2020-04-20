//
//  AudioDetailViewController.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/20/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import Reusable

final class AudioDetailViewController: UIViewController, BindableType {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: LoadMoreTableView!
    @IBOutlet weak var audioPlayerView: AudioPlayerView!
    
    // MARK: - Properties
    
    var viewModel: AudioDetailViewModel!
    
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
        let input = AudioDetailViewModel.Input()
        let output = viewModel.transform(input)
    }
}

// MARK: - Binders
extension AudioDetailViewController {
    
}

// MARK: - StoryboardSceneBased
extension AudioDetailViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}
