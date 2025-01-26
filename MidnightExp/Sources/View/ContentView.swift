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
                Spacer()
                VStack(spacing: 12) {
                    Text(viewModel.isFocusUnlockable ? "AF-L" : "AF")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .animation(.easeIn, value: viewModel.isFocusUnlockable)
                        .foregroundStyle(viewModel.isFocusUnlockable ? .yellow : .gray)
                        .onTapGesture { viewModel.didTapUnlock() }
                        .rotationEffect(viewModel.orientation.angle)
                        .animation(.easeInOut, value: viewModel.orientation)
                    HStack(spacing: 20) {
                        Text("\(viewModel.frameRate)fps")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .animation(.easeIn, value: viewModel.frameRate)
                            .foregroundStyle(viewModel.controlType == .frameRate ? .white : .gray)
                            .onTapGesture { viewModel.controlType = .frameRate }
                            .frame(width: 60)
                            .rotationEffect(viewModel.orientation.angle)
                            .animation(.easeInOut, value: viewModel.orientation)
                        Text("\(viewModel.shutterAngle)°")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .animation(.easeIn, value: viewModel.shutterAngle)
                            .foregroundStyle(viewModel.controlType == .shutterAngle ? .white : .gray)
                            .onTapGesture { viewModel.controlType = .shutterAngle }
                            .frame(width: 60)
                            .rotationEffect(viewModel.orientation.angle)
                            .animation(.easeInOut, value: viewModel.orientation)
                        Text(String(format: "%+0.1f", viewModel.exposureBias))
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .animation(.easeIn, value: viewModel.exposureBias)
                            .foregroundStyle(viewModel.controlType == .exposure ? .white : .gray)
                            .onTapGesture { viewModel.controlType = .exposure }
                            .frame(width: 60)
                            .rotationEffect(viewModel.orientation.angle)
                            .animation(.easeInOut, value: viewModel.orientation)
                        Text("x" + String(format: "%.1f", viewModel.zoomFactor))
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .animation(.easeIn, value: viewModel.zoomFactor)
                            .foregroundStyle(viewModel.controlType == .zoom ? .white : .gray)
                            .onTapGesture { viewModel.controlType = .zoom }
                            .frame(width: 60)
                            .rotationEffect(viewModel.orientation.angle)
                            .animation(.easeInOut, value: viewModel.orientation)
                    }
                    .animation(.easeInOut, value: viewModel.controlType)
                    .contentTransition(.numericText())
                    DialControlView(viewModel: viewModel)
                    ZStack {
                        HStack {
                            Spacer()
                            Button(action: viewModel.didTapToggle) {
                                Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30)
                                    .foregroundStyle(.white)
                                    .rotationEffect(viewModel.orientation.angle)
                                    .animation(.easeInOut, value: viewModel.orientation)
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
                    .padding(.horizontal, 20)
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
