//
//  AudioListViewController.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/20/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import Reusable

final class AudioListViewController: UIViewController, BindableType, ShowingAudioMiniPlayer {

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: LoadMoreTableView!

    // MARK: - Properties

    var viewModel: AudioListViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showAudioMiniPlayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideAudioMiniPlayer()
    }

    deinit {
        logDeinit()
    }

    // MARK: - Methods

    private func configView() {
        tableView.do {
            $0.estimatedRowHeight = 550
            $0.rowHeight = UITableView.automaticDimension
            $0.register(cellType: AudioCell.self)
            $0.refreshFooter = nil
        }

        tableView.rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        title = "AudioList"
    }

    func bindViewModel() {
        let showAudioTrigger = NotificationCenter.default.rx.notification(.showAudio)
            .map { $0.object as? Audio }
            .unwrap()
            .asDriverOnErrorJustComplete()
        
        let input = AudioListViewModel.Input(
            loadTrigger: Driver.just(()),
            reloadTrigger: tableView.refreshTrigger,
            selectAudioTrigger: tableView.rx.itemSelected.asDriver(),
            showAudioTrigger: showAudioTrigger
        )

        let output = viewModel.transform(input)

        output.audioList
            .drive(tableView.rx.items) { tableView, index, audio in
                return tableView.dequeueReusableCell(
                    for: IndexPath(row: index, section: 0),
                    cellType: AudioCell.self)
                    .then {
                        $0.bindViewModel(AudioViewModel(audio: audio))
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

        output.selectedAudio
            .drive()
            .disposed(by: rx.disposeBag)

        output.isEmpty
            .drive()
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - Binders
extension AudioListViewController {

}

// MARK: - UITableViewDelegate
extension AudioListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - StoryboardSceneBased
extension AudioListViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}
