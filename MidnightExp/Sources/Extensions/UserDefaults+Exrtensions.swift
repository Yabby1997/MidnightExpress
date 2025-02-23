//
//  UserDefaults+Exrtensions.swift
//  MidnightExpDev
//
//  Created by Seunghun on 2/17/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import Foundation

extension UserDefaults {
    func resetSettings() {
        SettingsKey.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }
}
