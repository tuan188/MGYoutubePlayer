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
    
    // MARK: - Properties
    
    var viewModel: VideoDetailViewModel!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        after(interval: 0.1) {
            MainViewController.instance?.hideMiniPlayer()
        }
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
            reloadTrigger: tableView.refreshTrigger,
            selectVideoTrigger: tableView.rx.itemSelected.asDriver()
        )
        let output = viewModel.transform(input)
        
        output.title
            .drive(self.rx.title)
            .disposed(by: rx.disposeBag)
        
        output.video
            .drive(videoBinder)
            .disposed(by: rx.disposeBag)
        
        output.error
            .drive(rx.error)
            .disposed(by: rx.disposeBag)
        
        output.isLoading
            .drive(rx.isLoading)
            .disposed(by: rx.disposeBag)
        
        output.isReloading
            .drive(tableView.isRefreshing)
            .disposed(by: rx.disposeBag)
        
        output.selectedVideo
            .drive()
            .disposed(by: rx.disposeBag)
        
        output.isEmpty
            .drive()
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
        guard let mainViewController = MainViewController.instance else { return }
        
        let miniPlayer = mainViewController.addMiniPlayer()
        
        if !miniPlayer.isActive {
            playerView.movePlayer(to: miniPlayer)
        }
    }
    
    func loadVideo(_ video: Video) {
        guard let mainViewController = MainViewController.instance else { return }
        
        // if miniplayer exists
        if let miniPlayer = mainViewController.miniPlayer {
            // if videos are the same, move player from mini player to player view and hide mini player
            if let miniPlayerVideo = miniPlayer.player?.video,
                miniPlayerVideo.isSameAs(video) {
                miniPlayer.movePlayer(to: playerView)
                
                if !playerView.isActive {
                    playerView.load(video: video)
                }
            } else if miniPlayer.isActive {
                // keep playing, init another player and assign to view controller's player view
                playerView.load(video: video)
            } else {
                // if not playing, move player from mini player to player view, hide mini player and load video
                miniPlayer.movePlayer(to: playerView)
                playerView.load(video: video)
            }
        } else {
            playerView.load(video: video)
        }
    }
}

// MARK: - Binders
extension VideoDetailViewController {
    var videoBinder: Binder<Video> {
        return Binder(self) { vc, video in
            vc.loadVideo(video)
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
