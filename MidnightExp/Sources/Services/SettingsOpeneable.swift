//
//  SettingsOpeneable.swift
//  MidnightExp
//
//  Created by Seunghun on 2/15/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import UIKit

@MainActor
protocol SettingsOpenable {
    func open()
}

final class UIApplicationSettingsOpener: SettingsOpenable {
    static var shared = UIApplicationSettingsOpener()
    
    private init() {}
    
    func open() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
