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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        after(interval: 0.1) {
//            MainViewController.shared?.hideMiniPlayer()
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        moveVideoToMiniPlayer()
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
        /*
        guard let mainViewController = MainViewController.shared else { return }
        
        let miniPlayer = mainViewController.addMiniPlayer()
        
        if !miniPlayer.isActive {
            playerView.movePlayer(to: miniPlayer)
        }
 */
    }
    
    func loadAudio(_ audio: Audio) {
        audioPlayerView.load(audio: audio)
        /*
        guard let mainViewController = MainViewController.shared else { return }
        
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
 */
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
