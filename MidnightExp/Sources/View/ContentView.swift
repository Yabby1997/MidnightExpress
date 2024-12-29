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
                OffsetSlider(offset: $viewModel.zoomOffset)
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
                ZStack {
                    HStack {
                        Spacer()
                        Button(action: viewModel.didTapToggle) {
                            Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30)
                                .foregroundStyle(.white)
                        }
                    }
                    HStack {
                        Spacer()
                        Button(action: viewModel.didTapShutter) {
                            Circle()
                                .frame(width: 60, height: 60)
                                .foregroundStyle(viewModel.isCapturing ? .red : .white)
                        }
                        Spacer()
                    }
                }
                .shadow(radius: 5)
            }
            .padding(.horizontal, 20)
            if let focusLockPoint = viewModel.focusLockPoint {
                LockIindicatorView(point: focusLockPoint, isHighlighted: viewModel.isFocusLocked)
            }
        }
        .task { await viewModel.setup() }
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.focusLockPoint) { $1 != nil }
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.isFocusLocked) { $1 }
    }
}
