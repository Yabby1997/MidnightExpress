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
                .onTapGesture(coordinateSpace: .local, perform: viewModel.didTapScreen)
                .ignoresSafeArea()
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
            VStack {
                Spacer()
                Text(viewModel.exposureState.text)
                    .font(.headline)
                    .foregroundStyle(viewModel.exposureState.color)
                    .animation(.easeIn(duration: 0.1), value: viewModel.exposureState)
                    .shadow(radius: 5)
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
        }
        .task {
            await viewModel.setup()
        }
    }
}

extension ExposureState {
    var text: String {
        switch self {
        case .correct: return "Correct"
        case .over: return "Over"
        case .under: return "Under"
        }
    }
    
    var color: Color {
        switch self {
        case .correct: return .green
        case .over, .under: return .red
        }
    }
}
