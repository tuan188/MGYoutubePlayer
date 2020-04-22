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
    @IBOutlet weak var playerView: AudioPlayerView!
    
    // MARK: - Properties
    
    var viewModel: AudioDetailViewModel!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        moveAudioToMiniPlayer()
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
    }
    
    func bindViewModel() {
        let loadTrigger = self.rx.methodInvoked(#selector(UIViewController.viewWillAppear))
            .map { $0.first as? Bool ?? false }
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = AudioDetailViewModel.Input(
            loadTrigger: loadTrigger,
            reloadTrigger: tableView.refreshTrigger,
            selectAudioTrigger: tableView.rx.itemSelected.asDriver()
        )
        let output = viewModel.transform(input)
        
        output.audio
            .map { $0.title }
            .drive(self.rx.title)
            .disposed(by: rx.disposeBag)
        
        output.audio
            .drive(audioBinder)
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
    }
    
    private func moveAudioToMiniPlayer() {
        guard playerView.isPlaying,
            let tabBarController = self.tabBarController
            else { return }

        if let miniPlayer = tabBarController.audioMiniPlayer,
            !miniPlayer.isPlaying {
            playerView.movePlayer(to: miniPlayer)
        } else {
            let miniPlayer = tabBarController.addAudioMiniPlayer()
            playerView.movePlayer(to: miniPlayer)
        }
    }
    
    func loadAudio(_ audio: Audio) {
        guard let tabBarController = self.tabBarController else { return }
        
        // if miniplayer exists
        if let miniPlayer = tabBarController.audioMiniPlayer {
            // if audios are the same, move player from mini player to player view and hide mini player
            if let miniPlayerAudio = miniPlayer.player?.audio,
                miniPlayerAudio.isSameAs(audio) {
                miniPlayer.movePlayer(to: playerView)
                
                if !playerView.isPlaying {
                    playerView.load(audio: audio)
                }
            } else if miniPlayer.isPlaying {
                // keep playing, init another player and assign to view controller's player view
                playerView.load(audio: audio)
            } else {
                // if not playing, move player from mini player to player view, hide mini player and load audio
                miniPlayer.movePlayer(to: playerView)
                playerView.load(audio: audio)
            }
        } else {
            playerView.load(audio: audio)
        }
    }
}

// MARK: - Binders
extension AudioDetailViewController {
    var audioBinder: Binder<Audio> {
        return Binder(self) { vc, audio in
            vc.loadAudio(audio)
        }
    }
}

// MARK: - UITableViewDelegate
extension AudioDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - StoryboardSceneBased
extension AudioDetailViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}
