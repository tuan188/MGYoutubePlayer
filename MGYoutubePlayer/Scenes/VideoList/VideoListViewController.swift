//
//  VideoListViewController.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/23/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import Reusable


final class VideoListViewController: UIViewController, BindableType, ShowingYoutubeMiniPlayer {

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: LoadMoreTableView!

    // MARK: - Properties

    var viewModel: VideoListViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showYoutubeMiniPlayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideYoutubeMiniPlayer()
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
        
        title = "Video List"
    }

    func bindViewModel() {
        let showVideoTrigger = NotificationCenter.default.rx.notification(.showVideo)
            .map { $0.object as? Video }
            .unwrap()
            .asDriverOnErrorJustComplete()
        
        let input = VideoListViewModel.Input(
            loadTrigger: Driver.just(()),
            reloadTrigger: tableView.refreshTrigger,
            selectVideoTrigger: tableView.rx.itemSelected.asDriver(),
            showVideoTrigger: showVideoTrigger
        )

        let output = viewModel.transform(input)

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
    }
}

// MARK: - Binders
extension VideoListViewController {

}

// MARK: - UITableViewDelegate
extension VideoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - StoryboardSceneBased
extension VideoListViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}
