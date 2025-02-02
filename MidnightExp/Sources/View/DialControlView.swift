//
//  DialControlView.swift
//  MidnightExp
//
//  Created by Seunghun on 1/14/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI
import HaebitUI

protocol DialControlViewModel: ObservableObject {
    var orientation: Orientation { get set }
    var controlType: ControlType { get set }
    var frameRate: Int { get set }
    var shutterAngle: Int { get set }
    var exposureBias: Float { get set }
    var zoomOffset: Float { get set }
}

struct DialControlView<ViewModel: DialControlViewModel>: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            HaebitApertureRing(
                selection: $viewModel.frameRate,
                entries: .constant([4, 6, 8, 12, 24]),
                feedbackStyle: .constant(.medium),
                isMute: .constant(true)
            ) { 
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 4, height: 8)
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
                    .offset(y: -4)
            } content: { value in
                DialView(title: "\(value)", viewModel: viewModel)
            }
            .opacity(viewModel.controlType == .frameRate ? 1.0 : .zero)
            HaebitApertureRing(
                selection: $viewModel.shutterAngle,
                entries: .constant([360, 315, 270, 225, 180]),
                feedbackStyle: .constant(.medium),
                isMute: .constant(true)
            ) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 4, height: 8)
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
                    .offset(y: -4)
            } content: { value in
                DialView(title: "\(value)°", viewModel: viewModel)
            }
            .opacity(viewModel.controlType == .shutterAngle ? 1.0 : .zero)
            HaebitApertureRing(
                selection: $viewModel.exposureBias,
                entries: .constant([-2.0, -1.7, -1.3, -1.0, -0.7, -0.3, 0, 0.3, 0.7, 1.0, 1.3, 1.7, 2.0]),
                feedbackStyle: .constant(.medium),
                isMute: .constant(true)
            ) {
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 4, height: 8)
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
                    .offset(y: -4)
            } content: { value in
                DialView(title: String(format: "%+0.1f", value), viewModel: viewModel)
            }
            .opacity(viewModel.controlType == .exposure ? 1.0 : .zero)
            OffsetSlider(offset: $viewModel.zoomOffset)
                .opacity(viewModel.controlType == .zoom ? 1.0 : .zero)
        }
        .padding(.vertical, 10)
        .animation(.easeIn, value: viewModel.controlType)
    }
}

extension ContentViewModel: DialControlViewModel {}
