//
//  ExposureStateContainerView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/6/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct ExposureStateContainerView: View {
    @Binding var orientation: Orientation
    @Binding var exposureState: ExposureState
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ExposureStateView(exposureState: $exposureState)
            }
            .opacity(orientation == .portrait && exposureState != .correctExposure ? 1.0 : .zero)
            VStack {
                Spacer()
                ExposureStateView(exposureState: $exposureState)
                    .rotateClockwise()
                    .rotateClockwise()
            }
            .opacity(orientation == .portraitUpsideDown && exposureState != .correctExposure ? 1.0 : .zero)
            HStack {
                Spacer()
                ExposureStateView(exposureState: $exposureState)
                    .rotateAnticlockwise()
            }
            .opacity(orientation == .landscapeLeft && exposureState != .correctExposure ? 1.0 : .zero)
            HStack {
                ExposureStateView(exposureState: $exposureState)
                    .rotateClockwise()
                Spacer()
            }
            .opacity(orientation == .landscapeRight && exposureState != .correctExposure ? 1.0 : .zero)
        }
        .padding(12)
        .animation(.easeInOut, value: exposureState)
        .animation(.easeInOut, value: orientation)
    }
}
