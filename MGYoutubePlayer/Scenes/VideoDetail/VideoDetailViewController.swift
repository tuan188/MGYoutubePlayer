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
    @IBOutlet weak var tableView: LoadMoreTableView!
    @IBOutlet weak var playerView: YoutubePlayerView!
    @IBOutlet weak var minimizeButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    var viewModel: VideoDetailViewModel!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        moveVideoToMiniPlayer()
    }

    deinit {
        logDeinit()
    }
    
    // MARK: - Methods
    
    private func configView() {
        tableView.do {
            $0.estimatedRowHeight = 550
            $0.rowHeight = UITableView.automaticDimension
            $0.register(cellType: VideoCell.self)
            $0.refreshFooter = nil
        }
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
    }

    func bindViewModel() {
        let loadTrigger = self.rx.methodInvoked(#selector(UIViewController.viewWillAppear))
            .map { $0.first as? Bool ?? false }
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = VideoDetailViewModel.Input(
            loadTrigger: loadTrigger,
            minimizeTrigger: minimizeButton.rx.tap.asDriver()
        )
        let output = viewModel.transform(input)
        
        output.title
            .drive(self.rx.title)
            .disposed(by: rx.disposeBag)
        
        output.video
            .drive(videoBinder)
            .disposed(by: rx.disposeBag)
        
        output.minimize
            .drive(minimizeBinder)
            .disposed(by: rx.disposeBag)
        
        output.videoList
            .drive(tableView.rx.items) { tableView, index, video in
                return tableView.dequeueReusableCell(
                    for: IndexPath(row: index, section: 0),
                    cellType: VideoCell.self)
                    .then {
                        $0.bindViewModel(VideoViewModel(video: video))
                    }
            }
            .disposed(by: rx.disposeBag)
    }
    
    private func moveVideoToMiniPlayer() {
        guard let tabBarController = self.tabBarController as? MainViewController,
            !tabBarController.hasMiniPlayer else { return }
        
        let miniPlayer = tabBarController.addMiniPlayer()
        tabBarController.showMiniPlayer()
        playerView.movePlayer(to: miniPlayer)
    }
    
    @discardableResult
    private func moveVideoFromMiniPlayer() -> Bool {
        guard let tabBarController = self.tabBarController as? MainViewController,
            let miniPlayer = tabBarController.miniPlayer else { return false }
        
        miniPlayer.movePlayer(to: playerView)
        tabBarController.hideMiniPlayer()
        return true
    }
}

// MARK: - Binders
extension VideoDetailViewController {
    var videoBinder: Binder<Video> {
        return Binder(self) { vc, video in
            if let tabBarController = vc.tabBarController as? MainViewController,
                let player = tabBarController.miniPlayer?.player {
                if player.video?.id == video.id {
                    vc.moveVideoFromMiniPlayer()
//                    vc.playerView.player?.pause()
//                    vc.playerView.player?.play()
                } else {
                    tabBarController.hideMiniPlayer()
                    vc.playerView.load(video: video)
                }
            } else {
                vc.playerView.load(video: video)
            }
        }
    }
    
    var minimizeBinder: Binder<Void> {
        return Binder(self) { vc, _  in
            vc.moveVideoToMiniPlayer()
        }
    }
}

// MARK: - UITableViewDelegate
extension VideoDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - StoryboardSceneBased
extension VideoDetailViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}
