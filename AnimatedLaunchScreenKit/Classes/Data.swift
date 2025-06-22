//
//  HPGAssets.swift
//  HPGLaunchScreenKit_Example
//
//  Created by Brett Owers on 5/18/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

public class HPGAssets {
    public static func image(for type: HPGAssetType) -> UIImage? {
        let bundleURL = Bundle(for: HPGAssets.self).url(forResource: "AnimatedLaunchScreenKitAssets", withExtension: "bundle")
        let assetBundle = bundleURL.flatMap { Bundle(url: $0) }

        let image = UIImage(named: type.rawValue, in: assetBundle, compatibleWith: nil)

        return image
    }
    
    public static var columnOne: [UIImage] {
        return [
            .smashingDips, .cheesewheel, .getyourhotpotatoes, .tractor,
            .loadedspud, .fries, .baked, .butter, .potatuhs, .peeler, .whatcani,
            .smashingDips, .cheesewheel, .getyourhotpotatoes, .tractor,
            .loadedspud, .fries, .baked, .butter, .potatuhs, .peeler, .whatcani,
            .smashingDips, .cheesewheel, .getyourhotpotatoes, .tractor,
            .loadedspud, .fries, .baked, .butter, .potatuhs, .peeler, .whatcani
        ].compactMap { image(for: $0) }
    }
    public static var columnTwo: [UIImage] {
        return [
            .saltandpepper, .potatuhs, .droolingpotato, .whatcani, .truck, .illhaveuh, .sun, .getyourhotpotatoes,
            .mashed, .crispycrisps, .butter, .potatuhs, .peeler, .whatcani,
            .saltandpepper, .potatuhs, .droolingpotato, .whatcani, .truck, .illhaveuh, .sun, .getyourhotpotatoes,
            .mashed, .crispycrisps, .butter, .potatuhs, .peeler, .whatcani
            
        ].compactMap { image(for: $0) }
    }
    public static var columnThree: [UIImage] {
        return [
            .crispycrisps, .sun, .loadedspud, .peeler,
            .baked, .cheesewheel, .whatcani, .mashed, .smashingDips, .potatochip, .illhaveuh,  .saltandpepper, .potatuhs, .droolingpotato, .whatcani, .truck,
            .crispycrisps, .sun, .loadedspud, .peeler,
            .baked, .cheesewheel, .whatcani, .mashed, .smashingDips, .potatochip, .illhaveuh,  .saltandpepper, .potatuhs, .droolingpotato, .whatcani, .truck
            
        ].compactMap { image(for: $0) }
    }
    
    public static var columnFour: [UIImage] {
        return [
            .mashed, .whatcani, .butter, .illhaveuh,
            .cheesewheel, .potatuhs, .tractor, .crispycrisps, .saltandpepper, .getyourhotpotatoes, .droolingpotato, .crispycrisps, .sun, .loadedspud, .peeler,
            .baked,
            .mashed, .whatcani, .butter, .illhaveuh,
            .cheesewheel, .potatuhs, .tractor, .crispycrisps, .saltandpepper, .getyourhotpotatoes, .droolingpotato, .crispycrisps, .sun, .loadedspud, .peeler,
            .baked
        ].compactMap { image(for: $0) }
    }
    
    public static var columnFive : [UIImage] {
        return [
            .cheesewheel, .baked, .sun, .getyourhotpotatoes, .mashed,
            .crispycrisps, .hashbrown, .illhaveuh, .truck, .baked, .potatochip, .loadedspud,.mashed, .whatcani, .butter, .illhaveuh,
            .cheesewheel, .baked, .sun, .getyourhotpotatoes, .mashed,
            .crispycrisps, .hashbrown, .illhaveuh, .truck, .baked, .potatochip, .loadedspud,.mashed, .whatcani, .butter, .illhaveuh,
        ].compactMap { image(for: $0) }
    }

    public static var allTextGraphics: [UIImage] {
        return [
            .baked, .crispycrisps, .getyourhotpotatoes, .illhaveuh,
            .loadedspud, .potatuhs, .smashingDips, .whatcani
        ].compactMap { image(for: $0) }
    }

    public static var allCartoonGraphics: [UIImage] {
        return [
            .bakedpotato, .butter, .cheesewheel, .droolingpotato,
            .fries, .hashbrown, .mashed, .masher, .peeler,
            .potatochip, .saltandpepper, .sheet, .sun, .tractor, .truck
        ].compactMap { image(for: $0) }
    }
}


public enum HPGAssetType: String, CaseIterable {
    // Text-based graphics
    case baked
    case crispycrisps
    case getyourhotpotatoes
    case illhaveuh
    case loadedspud
    case potatuhs
    case smashingDips = "smashing-dips"
    case whatcani

    // Cartoon graphics
    case bakedpotato
    case butter
    case cheesewheel
    case droolingpotato
    case fries
    case hashbrown
    case logo
    case mashed
    case masher
    case peeler
    case potatochip
    case saltandpepper
    case sheet
    case sun
    case tractor
    case truck
}
