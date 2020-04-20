//
//  ProgressSlider.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 4/1/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

class ProgressSlider: UISlider { // swiftlint:disable:this final_class
    
    var trackHeight: CGFloat = 4.0 {
        didSet {
            layoutIfNeeded()
        }
    }
    
    var loadedProgressTintColor = UIColor.gray {
        didSet {
            self.progressView?.progressTintColor = loadedProgressTintColor
        }
    }
    
    var loadedProgress: CGFloat {
        set {
            guard newValue >= 0.0 && newValue <= 1.0 else {
                return
            }
            self.progressView?.progress = newValue
        }
        
        get {
            return self.progressView?.progress ?? 0.0
        }
    }
    
    private weak var progressView: ProgressView?
    private let offset: CGFloat = 3.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //        addLongGesture()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        addLongGesture()
        setup()
    }
    
    private func setup() {
        self.maximumTrackTintColor = UIColor.clear
        let progressView = ProgressView()
        progressView.isUserInteractionEnabled = false
        insertSubview(progressView, at: 0)
        self.progressView = progressView
    }
    
    private func addLongGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(tapAndSlide(gestures:)))
        longPress.minimumPressDuration = 0
        self.addGestureRecognizer(longPress)
    }
    
    @objc
    private func tapAndSlide(gestures: UILongPressGestureRecognizer) {
        let pointTapped = gestures.location(in: self)
        let thumbWidth = getThumbRect().size.width
        var value: Float = 0.0
        
        if pointTapped.x <= thumbWidth / 2 {
            value = self.minimumValue
        } else if pointTapped.x >= self.bounds.size.width - thumbWidth / 2 {
            value = self.maximumValue
        } else {
            let percentage = Float((pointTapped.x - thumbWidth / 2) / (self.bounds.size.width - thumbWidth))
            let delta = percentage * (self.maximumValue - self.minimumValue)
            value = self.minimumValue + delta
        }
        
        if gestures.state == .began {
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                options: .curveEaseInOut,
                animations: {
                    self.setValue(value, animated: true)
                    super.sendActions(for: .touchDown)
                },
                completion: nil)
        } else {
            self.setValue(value, animated: false)
        }
        
        if gestures.state == .changed {
            super.sendActions(for: .valueChanged)
        }
        
        if gestures.state == .ended {
            super.sendActions(for: .touchUpInside)
        }
    }
    
    private func getThumbRect() -> CGRect {
        let trackRect = self.trackRect(forBounds: self.bounds)
        return self.thumbRect(forBounds: self.bounds, trackRect: trackRect, value: self.value)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = trackHeight
        self.progressView?.frame = newBounds
        return newBounds
    }
}
