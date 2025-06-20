//
//  Defaults.swift
//  AnimatedLaunchScreenKit
//
//  Created by Brett Owers on 5/19/25.
//

import Foundation
@MainActor public let DEFAULT_HPG_CONFIGURATION = AnimatedLaunchScreenConfiguration(
    backgroundColor: UIColor(hex: "E16416"),
    cardColor: UIColor(hex: "E29C1A"),
    highlightColor: UIColor(hex: "E1C916"),
    columns: [
        HPGAssets.columnOne ,
        HPGAssets.columnTwo ,
        HPGAssets.columnThree,
        HPGAssets.columnFour ,
        HPGAssets.columnFive 
             
             ],
    animationDurations: .init(totalDuration: 4.0, initialDelay: 0.5, spinDuration: 1.5)
)
