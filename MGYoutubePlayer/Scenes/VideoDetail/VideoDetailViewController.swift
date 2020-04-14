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
    @IBOutlet weak var minimizeButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    var viewModel: VideoDetailViewModel!
    
//    override var viewForPopupInteractionGestureRecognizer: UIView {
//        return playerView
//    }

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        configView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        moveVideoToMiniPlayer()
    }

    deinit {
        logDeinit()
    }
    
    // MARK: - Methods

    func configView() {
        if moveVideoFromMiniPlayer() {
//            (self.tabBarController as? MainViewController)?.miniPlayer?.removeFromSuperview()
        } else {
            playerView.configPlayer()
        }
    }

    func bindViewModel() {
        let loadTrigger = self.rx.methodInvoked(#selector(UIViewController.viewWillAppear))
            .map { $0.first as? Bool ?? false }
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
//        self.rx.methodInvoked(#selector(UIViewController.viewDidAppear))
//            .map { $0.first as? Bool ?? false }
//            .skip(1)
//            .mapToVoid()
//            .asDriverOnErrorJustComplete()
//            .drive(onNext: { [unowned self] in
////                self.playerView.continuePlay()
//            })
//            .disposed(by: rx.disposeBag)
        
        let input = VideoDetailViewModel.Input(
            loadTrigger: loadTrigger,
            minimizeTrigger: minimizeButton.rx.tap.asDriver()
        )
        let output = viewModel.transform(input)
        
        output.title
            .drive(self.rx.title)
            .disposed(by: rx.disposeBag)
        
        output.videoId
            .drive(videoIdBinder)
            .disposed(by: rx.disposeBag)
        
        output.minimize
            .drive(minimizeBinder)
            .disposed(by: rx.disposeBag)
    }
    
    private func moveVideoToMiniPlayer() {
        guard let tabBarController = self.tabBarController else { return }
        
        let miniPlayer = tabBarController.addMiniPlayer()
        playerView.movePlayer(to: miniPlayer)
    }
    
    @discardableResult
    private func moveVideoFromMiniPlayer() -> Bool {
        guard let tabBarController = self.tabBarController,
            let miniPlayer = tabBarController.miniPlayer else { return false }
        
        miniPlayer.movePlayer(to: playerView)
        tabBarController.removeMiniPlayer()
        return true
    }
}

// MARK: - Binders
extension VideoDetailViewController {
    var videoIdBinder: Binder<String> {
        return Binder(self) { vc, videoId in
            if let tabBarController = vc.tabBarController,
                tabBarController.hasMiniPlayer {
                vc.moveVideoFromMiniPlayer()
            } else {
                vc.playerView.configPlayer()
                vc.playerView.load(videoId: videoId)
            }
        }
    }
    
    var minimizeBinder: Binder<Void> {
        return Binder(self) { vc, _  in
//            vc.moveVideoToMiniPlayer()
        }
    }
}

// MARK: - StoryboardSceneBased
extension VideoDetailViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}
