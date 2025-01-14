//
//  ContentView.swift
//  MidnightExpDev
//
//  Created by Seunghun on 12/18/24.
//

import SwiftUI
import HaebitUI

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
                Spacer()
                VStack(spacing: 12) {
                    Text(viewModel.isFocusUnlockable ? "AF-L" : "AF")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .animation(.easeIn, value: viewModel.isFocusUnlockable)
                        .foregroundStyle(viewModel.isFocusUnlockable ? .yellow : .gray)
                        .onTapGesture { viewModel.didTapUnlock() }
                    HStack(spacing: 20) {
                        Text("\(viewModel.frameRate)fps")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .animation(.easeIn, value: viewModel.frameRate)
                            .foregroundStyle(viewModel.controlType == .frameRate ? .white : .gray)
                            .onTapGesture { viewModel.controlType = .frameRate }
                            .frame(width: 60)
                        Text("\(viewModel.shutterAngle)°")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .animation(.easeIn, value: viewModel.shutterAngle)
                            .foregroundStyle(viewModel.controlType == .shutterAngle ? .white : .gray)
                            .onTapGesture { viewModel.controlType = .shutterAngle }
                            .frame(width: 60)
                        Text(String(format: "%+0.1f", viewModel.exposureBias))
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .animation(.easeIn, value: viewModel.exposureBias)
                            .foregroundStyle(viewModel.controlType == .exposure ? .white : .gray)
                            .onTapGesture { viewModel.controlType = .exposure }
                            .frame(width: 60)
                        Text("x" + String(format: "%.1f", viewModel.zoomFactor))
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .animation(.easeIn, value: viewModel.zoomFactor)
                            .foregroundStyle(viewModel.controlType == .zoom ? .white : .gray)
                            .onTapGesture { viewModel.controlType = .zoom }
                            .frame(width: 60)
                    }
                    .animation(.easeInOut, value: viewModel.controlType)
                    .contentTransition(.numericText())
                    ZStack {
                        HaebitApertureRing(
                            selection: $viewModel.frameRate,
                            entries: .constant([4, 6, 8, 10, 12]),
                            feedbackStyle: .constant(.medium),
                            isMute: .constant(true)
                        ) { value in
                            Text("\(value)")
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        }
                        .opacity(viewModel.controlType == .frameRate ? 1.0 : .zero)
                        .overlay {
                            HStack {
                                Color.clear.blur(radius: 10)
                            }
                        }
                        HaebitApertureRing(
                            selection: $viewModel.shutterAngle,
                            entries: .constant([360, 315, 270, 225, 180]),
                            feedbackStyle: .constant(.medium),
                            isMute: .constant(true)
                        ) { value in
                            Text("\(value)°")
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        }
                        .opacity(viewModel.controlType == .shutterAngle ? 1.0 : .zero)
                        HaebitApertureRing(
                            selection: $viewModel.exposureBias,
                            entries: .constant([-2.0, -1.7, -1.3, -1.0, -0.7, -0.3, 0, 0.3, 0.7, 1.0, 1.3, 1.7, 2.0]),
                            feedbackStyle: .constant(.medium),
                            isMute: .constant(true)
                        ) { value in
                            Text(String(format: "%+0.1f", value))
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        }
                        .opacity(viewModel.controlType == .exposure ? 1.0 : .zero)
                        OffsetSlider(offset: $viewModel.zoomOffset)
                            .opacity(viewModel.controlType == .zoom ? 1.0 : .zero)
                    }
                    .animation(.easeIn, value: viewModel.controlType)
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
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.focusLockPoint) { $1 != nil }
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.isFocusLocked) { $1 }
    }
}
