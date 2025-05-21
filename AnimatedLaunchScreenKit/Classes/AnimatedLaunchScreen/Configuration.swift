//
//  HPGLaunchScreenConfiguration.swift
//  HPGLaunchScreenKit_Example
//
//  Created by Brett Owers on 5/18/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

public struct AnimatedLaunchScreenConfiguration {
    public let backgroundColor: UIColor
    public let cardColor: UIColor
    public let highlightColor: UIColor
    public let columns: [[UIImage]]
    public let animationDurations: LaunchScreenTiming
    public init(
        backgroundColor: UIColor,
        cardColor: UIColor,
        highlightColor: UIColor,
        columns: [[UIImage]],
        animationDurations: LaunchScreenTiming
    ) {
        self.backgroundColor = backgroundColor
        self.cardColor = cardColor
        self.highlightColor = highlightColor
        self.columns = columns
        self.animationDurations = animationDurations
    }
    
    

}

