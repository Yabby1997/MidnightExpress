//
//  RotatingCameraOverlayView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/22/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct RotatingCameraOverlayView: View {
    @StateObject var viewModel: MidnightExpressViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                Spacer()
                TutorialView(stage: $viewModel.tutorialStage)
                ExposureStateView(exposureState: $viewModel.exposureState)
            }
            .opacity(viewModel.orientation == .portrait ? 1.0 : .zero)
            VStack(spacing: 8) {
                Spacer()
                TutorialView(stage: $viewModel.tutorialStage)
                    .rotateClockwise()
                    .rotateClockwise()
                ExposureStateView(exposureState: $viewModel.exposureState)
                    .rotateClockwise()
                    .rotateClockwise()
            }
            .opacity(viewModel.orientation == .portraitUpsideDown ? 1.0 : .zero)
            HStack(spacing: 8) {
                Spacer()
                TutorialView(stage: $viewModel.tutorialStage)
                    .rotateAnticlockwise()
                ExposureStateView(exposureState: $viewModel.exposureState)
                    .rotateAnticlockwise()
            }
            .opacity(viewModel.orientation == .landscapeLeft ? 1.0 : .zero)
            HStack(spacing: 8) {
                ExposureStateView(exposureState: $viewModel.exposureState)
                    .rotateClockwise()
                TutorialView(stage: $viewModel.tutorialStage)
                    .rotateClockwise()
                Spacer()
            }
            .opacity(viewModel.orientation == .landscapeRight ? 1.0 : .zero)
        }
        .padding(12)
        .animation(.easeInOut, value: viewModel.tutorialStage)
        .animation(.easeInOut, value: viewModel.exposureState)
        .animation(.easeInOut, value: viewModel.orientation)
    }
}
