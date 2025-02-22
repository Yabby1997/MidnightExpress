//
//  TutorialStage.swift
//  MidnightExp
//
//  Created by Seunghun on 2/22/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import Foundation

enum TutorialStage: Int, Equatable {
    case fps
    case shutterAngle
    case exposureBias
    case exposure
    case zoom
    case focus
    case selfie
    case record
    case done
    
    mutating func next() {
        switch self {
        case .fps: self = .shutterAngle
        case .shutterAngle: self = .exposureBias
        case .exposureBias: self = .exposure
        case .exposure: self = .zoom
        case .zoom: self = .focus
        case .focus: self = .selfie
        case .selfie: self = .record
        case .record: self = .done
        case .done: self = .done
        }
    }
}
