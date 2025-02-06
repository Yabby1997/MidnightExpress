//
//  ContentView.swift
//  MidnightExpDev
//
//  Created by Seunghun on 12/18/24.
//

import SwiftUI

@MainActor
struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        ZStack {
            CameraView(previewLayer: viewModel.previewLayer)
                .ignoresSafeArea()
                .onTapGesture(coordinateSpace: .local, perform: viewModel.didTapScreen)
            if let focusLockPoint = viewModel.focusLockPoint {
                LockIindicatorView(point: focusLockPoint, isHighlighted: viewModel.isFocusLocked)
            }
            LevelIndicator(level: $viewModel.level)
            VStack() {
                ExposureStateContainerView(
                    orientation: $viewModel.orientation,
                    exposureState: $viewModel.exposureState
                )
                VStack {
                    ControlTypeView(viewModel: viewModel)
                    DialControlView(viewModel: viewModel)
                    ZStack {
                        ShutterButton(viewModel: viewModel)
                        FlipButton(viewModel: viewModel)
                        AFLButton(viewModel: viewModel)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
                .background {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .allowsHitTesting(true)
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 2)
            VStack {
                Text("ISO :\(viewModel.iso)")
                Text("Shutter Speed: \(viewModel.shutterSpeed)")
                Text("EV: \(viewModel.exposureValue)")
                Text("Offset: \(viewModel.exposureOffset)")
                Spacer()
            }
            .font(.subheadline)
            .foregroundStyle(.white)
            .shadow(radius: 5)
        }
        .task { await viewModel.setup() }
        .persistentSystemOverlays(.hidden)
        .statusBar(hidden: true)
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.focusLockPoint) { $1 != nil }
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.isFocusLocked) { $1 }
        .sensoryFeedback(.impact(weight: .heavy), trigger: viewModel.isCapturing)
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
