//
//  ProgressView.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/1/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

class ProgressView: UIView {  // swiftlint:disable:this final_class
    
    let path = UIBezierPath()
    
    var progress: CGFloat = 0.0 {
        didSet {
            guard progress >= 0.0 && progress <= 1.0 else {
                progress = oldValue
                return
            }
            
            progressView.frame.size.width = self.progress * self.bounds.width
        }
        
    }
    
    var progressTintColor = UIColor.gray {
        didSet {
            progressView.backgroundColor = progressTintColor
        }
    }
    
    var trackTintColor = UIColor.lightGray.withAlphaComponent(0.5) {
        didSet {
            backgroundColor = trackTintColor
        }
    }
    
    lazy var progressView: UIView = {
        let progressView = UIView()
        progressView.frame = self.bounds
        progressView.frame.size.width = self.progress * self.bounds.width
        progressView.backgroundColor = self.progressTintColor
        return progressView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = trackTintColor
        clipsToBounds = true
        layer.cornerRadius = 2.0
        addSubview(progressView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.frame = self.bounds
        progressView.frame.size.width = self.progress * self.bounds.width
    }
    
}
