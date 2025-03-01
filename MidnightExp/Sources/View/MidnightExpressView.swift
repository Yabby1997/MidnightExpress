//
//  MidnightExpressView.swift
//  MidnightExpDev
//
//  Created by Seunghun on 12/18/24.
//

import SwiftUI

@MainActor
struct MidnightExpressView: View {
    @StateObject var viewModel = MidnightExpressViewModel()
    
    var body: some View {
        VStack() {
            ZStack {
                CameraView(previewLayer: viewModel.previewLayer)
                    .onTapGesture(coordinateSpace: .local, perform: viewModel.didTapScreen)
                    .onTapGesture(count: 2, coordinateSpace: .local, perform: viewModel.didDoubleTapScreen)
                LevelIndicator(level: $viewModel.level)
                LockIindicatorView(viewModel: viewModel)
                RotatingCameraOverlayView(viewModel: viewModel)
                DebugView(viewModel: viewModel)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .aspectRatio(3 / 4, contentMode: .fit)
            .padding(.horizontal, 2)
            VStack {
                ControlTypeView(viewModel: viewModel)
                DialControlView(viewModel: viewModel)
                ZStack {
                    AFLButton(viewModel: viewModel)
                    ShutterButton(viewModel: viewModel)
                    FlipButton(viewModel: viewModel)
                }
                .padding(.top, 12)
                .padding(.horizontal, 40)
            }
        }
        .padding(.vertical, 8)
        .persistentSystemOverlays(.hidden)
        .statusBar(hidden: true)
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.focusLockPoint) { $1 != nil }
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.isFocusLocked) { $1 }
        .sensoryFeedback(.impact(weight: .heavy), trigger: viewModel.isCapturing)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: viewModel.zoomFactor) { abs(Int($0 * 10) - Int($1 * 10)) == 1 }
        .fullScreenCover(isPresented: Binding(get: { viewModel.onboardingStage != .ready }, set: { _ in })) {
            OnboardingView(stage: $viewModel.onboardingStage)
        }
        .onTapGesture(count: 3) {
            // TODO: Remove this line for release. Just for test only.
            UserDefaults.standard.resetSettings()
        }
    }
}

extension Orientation {
    var angle: Angle {
        switch self {
        case .portrait: return .degrees(.zero)
        case .portraitUpsideDown: return .degrees(180)
        case .landscapeLeft: return .degrees(-90)
        case .landscapeRight: return .degrees(90)
        }
    }
}
