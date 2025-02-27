//
//  TutorialStage.swift
//  MidnightExp
//
//  Created by Seunghun on 2/22/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import Foundation

enum TutorialStage: Int, Equatable, Codable {
    case fps
    case shutterAngle
    case exposureBias
    case exposure
    case zoom
    case focus
    case selfie
    case record
    case done
    
    func hasReached(_ other: TutorialStage) -> Bool {
        self.rawValue >= other.rawValue
    }
}
