//
//  UnitTestViewController.swift
//  MGYoutubePlayer
//
//  Created by Tuan Truong on 3/22/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit

final class UnitTestViewController: UIViewController {
    var testingLabel: UILabel!
    var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        testingLabel = UILabel().then {
            $0.text = "Testing..."
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 40, weight: .thin)
        }
        view.addSubview(testingLabel)
        
        indicator = UIActivityIndicatorView().then {
            $0.style = .gray
            $0.startAnimating()
        }
        view.addSubview(indicator)
        
        // constraint
        testingLabel.translatesAutoresizingMaskIntoConstraints = false
        testingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        testingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.topAnchor.constraint(equalTo: testingLabel.bottomAnchor, constant: 18).isActive = true
    }
}