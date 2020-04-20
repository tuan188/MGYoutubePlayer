//
//  Assembler.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/22/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

protocol Assembler: class,
    AudioDetailAssembler,
    AudioListAssembler,
    RepositoriesAssembler,
    MainAssembler,
    VideoDetailAssembler,
    VideoListAssembler,
    AppAssembler {
    
}

final class DefaultAssembler: Assembler {
    
}
