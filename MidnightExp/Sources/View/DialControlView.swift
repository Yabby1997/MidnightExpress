//
//  DialControlView.swift
//  MidnightExp
//
//  Created by Seunghun on 1/14/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI
import HaebitUI

struct DialControlView: View {
    @Binding var orientation: Orientation
    @Binding var controlType: ControlType
    @Binding var frameRate: Int
    @Binding var shutterAngle: Int
    @Binding var exposureBias: Float
    @Binding var zoomOffset: Float
    
    var body: some View {
        ZStack {
            HaebitApertureRing(
                selection: $frameRate,
                entries: .constant([4, 6, 8, 10, 12]),
                feedbackStyle: .constant(.medium),
                isMute: .constant(true)
            ) { value in
                FrameRateView(value: value, orientation: $orientation)
            }
            .opacity(controlType == .frameRate ? 1.0 : .zero)
            HaebitApertureRing(
                selection: $shutterAngle,
                entries: .constant([360, 315, 270, 225, 180]),
                feedbackStyle: .constant(.medium),
                isMute: .constant(true)
            ) { value in
                Text("\(value)°")
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(radius: 2)
                    .rotationEffect(orientation.angle)
                    .animation(.easeInOut, value: orientation)
            }
            .opacity(controlType == .shutterAngle ? 1.0 : .zero)
            HaebitApertureRing(
                selection: $exposureBias,
                entries: .constant([-2.0, -1.7, -1.3, -1.0, -0.7, -0.3, 0, 0.3, 0.7, 1.0, 1.3, 1.7, 2.0]),
                feedbackStyle: .constant(.medium),
                isMute: .constant(true)
            ) { value in
                Text(String(format: "%+0.1f", value))
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(radius: 2)
                    .rotationEffect(orientation.angle)
                    .animation(.easeInOut, value: orientation)
            }
            .opacity(controlType == .exposure ? 1.0 : .zero)
            OffsetSlider(offset: $zoomOffset)
                .opacity(controlType == .zoom ? 1.0 : .zero)
        }
        .padding(.vertical, 10)
        .animation(.easeIn, value: controlType)
    }
}


struct FrameRateView: View {
    let value: Int
    @Binding var orientation: Orientation
    
    var body: some View {
        Text("\(value)")
            .font(.system(size: 18, weight: .semibold, design: .monospaced))
            .minimumScaleFactor(0.7)
            .lineLimit(1)
            .fixedSize(horizontal: false, vertical: true)
            .shadow(radius: 2)
            .rotationEffect(orientation.angle)
            .animation(.easeInOut, value: orientation)
    }
}
