//
//  SomeGame.swift
//  HPGLaunchScreenKit_Example
//
//  Created by Brett Owers on 5/18/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import AnimatedLaunchScreenKit



public class ExampleViewController: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DEFAULT_HPG_CONFIGURATION.cardColor
        print("view.frame: \(view.frame)")
        print("UIScreen.main.bounds: \(UIScreen.main.bounds)")

        let label = UILabel()
        label.text = "Main App Screen"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
