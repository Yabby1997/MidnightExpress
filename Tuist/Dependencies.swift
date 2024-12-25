//
//  Dependencies.swift
//  HaebitManifests
//
//  Created by Seunghun on 5/11/24.
//

import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: .init(
        [
            .remote(url: "https://github.com/Yabby1997/LightMeter", requirement: .exact("0.2.0")),
            .remote(url: "https://github.com/Yabby1997/Obscura", requirement: .exact("0.7.0")),
        ]
    ),
    platforms: [.iOS]
)
