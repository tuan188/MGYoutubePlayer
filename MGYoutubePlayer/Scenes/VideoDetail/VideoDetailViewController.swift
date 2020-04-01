//
//  VideoDetailViewController.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/23/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import Reusable

final class VideoDetailViewController: UIViewController, BindableType {
    
    // MARK: - IBOutlets
    @IBOutlet weak var playerView: YoutubePlayerView!
    
    // MARK: - Properties
    
    var viewModel: VideoDetailViewModel!

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
        let input = VideoDetailViewModel.Input(loadTrigger: Driver.just(()))
        let output = viewModel.transform(input)
        
        output.title
            .drive(self.rx.title)
            .disposed(by: rx.disposeBag)
        
        output.videoId
            .drive(onNext: { [unowned self] videoId in
                self.playerView.load(videoId: videoId)
            })
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - Binders
extension VideoDetailViewController {
    var videoIdBinder: Binder<String> {
        return Binder(self) { _, videoId in
            print(videoId)
        }
    }
}

// MARK: - StoryboardSceneBased
extension VideoDetailViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}
