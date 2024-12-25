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
            VStack {
                Text("ISO :\(viewModel.iso)")
                Text("Shutter Speed: \(viewModel.shutterSpeed)")
                Spacer()
            }
            .font(.subheadline)
            .foregroundStyle(.white)
            .shadow(radius: 5)
            VStack {
                Spacer()
                Button {
                    viewModel.didTapShutter()
                } label: {
                    Text(viewModel.isCapturing ? "STOP" : "START")
                        .foregroundStyle(viewModel.isCapturing ? .red : .white)
                        .shadow(radius: 5)
                }
                Spacer().frame(height: 100)
            }
        }
        .task {
            await viewModel.setup()
        }
    }
}

#Preview {
    ContentView()
}
