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
    @StateObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            Circle()
                .frame(width: 6, height: 6)
                .foregroundStyle(.white)
            ZStack {
                HaebitApertureRing(
                    selection: $viewModel.frameRate,
                    entries: .constant([4, 6, 8, 12, 24]),
                    feedbackStyle: .constant(.medium),
                    isMute: .constant(true)
                ) { value in
                    DialView(title: "\(value)", viewModel: viewModel)
                }
                .opacity(viewModel.controlType == .frameRate ? 1.0 : .zero)
                HaebitApertureRing(
                    selection: $viewModel.shutterAngle,
                    entries: .constant([360, 315, 270, 225, 180]),
                    feedbackStyle: .constant(.medium),
                    isMute: .constant(true)
                ) { value in
                    DialView(title: "\(value)°", viewModel: viewModel)
                }
                .opacity(viewModel.controlType == .shutterAngle ? 1.0 : .zero)
                HaebitApertureRing(
                    selection: $viewModel.exposureBias,
                    entries: .constant([-2.0, -1.7, -1.3, -1.0, -0.7, -0.3, 0, 0.3, 0.7, 1.0, 1.3, 1.7, 2.0]),
                    feedbackStyle: .constant(.medium),
                    isMute: .constant(true)
                ) { value in
                    DialView(title: String(format: "%+0.1f", value), viewModel: viewModel)
                }
                .opacity(viewModel.controlType == .exposure ? 1.0 : .zero)
                OffsetSlider(offset: $viewModel.zoomOffset)
                    .opacity(viewModel.controlType == .zoom ? 1.0 : .zero)
            }
            .frame(height: 40)
            .animation(.easeIn, value: viewModel.controlType)
        }
    }
}
