//
//  LevelIndicator.swift
//  MidnightExp
//
//  Created by Seunghun on 1/14/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct LevelIndicator: View {
    @Binding var level: Level
    
    var body: some View {
        switch level {
        case let .portrait(angle): HorizonLevelIndicator(originalAngle: .degrees(.zero), actualAngle: .degrees(angle))
        case let .portraitUpsideDown(angle): HorizonLevelIndicator(originalAngle: .degrees(angle < .zero ? -180 : 180), actualAngle: .degrees(angle))
        case let .landscapeRight(angle): HorizonLevelIndicator(originalAngle: .degrees(90), actualAngle: .degrees(angle))
        case let .landscapeLeft(angle): HorizonLevelIndicator(originalAngle: .degrees(-90), actualAngle: .degrees(angle))
        case let .floor(roll, pitch): SurfaceLevelIndicator(roll: .degrees(roll), pitch: .degrees(pitch))
        case let .sky(roll, pitch): SurfaceLevelIndicator(roll: .degrees(roll < .zero ? roll + 180 : roll - 180), pitch: .degrees(pitch))
        }
    }
}

struct HorizonLevelIndicator: View {
    let originalAngle: Angle
    let actualAngle: Angle
    
    var body: some View {
        let isLeveled: Bool = originalAngle.isClose(to: actualAngle, tolerance: .degrees(2))
        ZStack {
            HStack {
                Rectangle().frame(width: 15, height: 2)
                Spacer().frame(width: 170)
                Rectangle().frame(width: 15, height: 2)
            }
            .foregroundStyle(isLeveled ? .yellow : .white)
            .rotationEffect(originalAngle)
            Rectangle().frame(width: isLeveled ? 170 : 160, height: 2)
                .foregroundStyle(isLeveled ? .yellow : .white)
                .rotationEffect(isLeveled ? originalAngle : actualAngle)
        }
        .animation(.bouncy(duration: 0.1), value: isLeveled)
        .sensoryFeedback(.impact(weight: .medium), trigger: isLeveled) { $0 != $1 && $1 }
    }
}

struct SurfaceLevelIndicator: View {
    let roll: Angle
    let pitch: Angle
    
    var body: some View {
        let isLeveled: Bool = roll.isClose(to: .degrees(.zero), tolerance: .degrees(2)) && pitch.isClose(to: .degrees(.zero), tolerance: .degrees(2))
        ZStack {
            ZStack {
                Rectangle().frame(width: 30, height: 2)
                Rectangle().frame(width: 2, height: 30)
            }
            .foregroundStyle(.yellow)
            ZStack {
                Rectangle().frame(width: 30, height: 2)
                Rectangle().frame(width: 2, height: 30)
            }
            .foregroundStyle(isLeveled ? .yellow : .white)
            .offset(x: isLeveled ? .zero : -roll.degrees, y: isLeveled ? .zero : -pitch.degrees)
        }
        .animation(.bouncy, value: isLeveled)
        .sensoryFeedback(.impact(weight: .medium), trigger: isLeveled) { $0 != $1 && $1 }
    }
}

extension Angle {
    fileprivate func isClose(to other: Angle, tolerance: Angle) -> Bool {
        cos(abs(radians - other.radians)) >= cos(tolerance.radians)
    }
}
