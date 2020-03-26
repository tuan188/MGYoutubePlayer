//
//  AppDelegate.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/22/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var assembler: Assembler = DefaultAssembler()

    func applicationDidFinishLaunching(_ application: UIApplication) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
    
        if NSClassFromString("XCTest") != nil { // test
            window.rootViewController = UnitTestViewController()
            window.makeKeyAndVisible()
        } else {
            bindViewModel(window: window)
        }
    }

    private func bindViewModel(window: UIWindow) {
        let vm: AppViewModel = assembler.resolve(window: window)
        let input = AppViewModel.Input(loadTrigger: Driver.just(()))
        let output = vm.transform(input)
        
        output.toVideoList
            .drive()
            .disposed(by: rx.disposeBag)
    }
}
