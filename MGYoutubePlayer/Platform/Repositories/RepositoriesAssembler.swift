//
//  RepositoriesAssembler.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/16/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol RepositoriesAssembler {
    func resolve() -> VideoRepositoryType
}

extension Assembler where Self: DefaultAssembler {
    func resolve() -> VideoRepositoryType {
        return VideoRepository()
    }
}
