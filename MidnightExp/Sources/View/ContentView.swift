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
            VStack(spacing: 12) {
                Spacer()
                Button(action: viewModel.didTapUnlock) { Text("Unlock") }
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(.yellow)
                    .shadow(radius: 5)
                    .opacity(viewModel.isFocusUnlockable ? 1.0 : .zero)
                    .animation(.easeInOut, value: viewModel.isFocusUnlockable)
                Slider(
                    value: .init(
                        get: { viewModel.exposureBias },
                        set: { viewModel.didChangeExposureBiasSlider(value: $0) }
                    ),
                    in: -2...2,
                    step: 0.1
                )
                Slider(
                    value: .init(
                        get: { Float(viewModel.frameRate) },
                        set: { viewModel.frameRate = Int($0) }
                    ),
                    in: 6...24,
                    step: 1
                )
                Button {
                    viewModel.didTapShutter()
                } label: {
                    Text(viewModel.isCapturing ? "STOP" : "START")
                        .font(.title2)
                        .foregroundStyle(viewModel.isCapturing ? .red : .white)
                        .shadow(radius: 5)
                }
                Spacer().frame(height: 50)
            }
            .padding(.horizontal, 20)
            if let focusLockPoint = viewModel.focusLockPoint {
                LockIindicatorView(point: focusLockPoint, isHighlighted: viewModel.isFocusLocked)
            }
        }
        .task {
            await viewModel.setup()
        }
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.focusLockPoint)
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.isFocusLocked) { $1 }
    }
}
