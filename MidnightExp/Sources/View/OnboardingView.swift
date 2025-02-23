//
//  OnboardingView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/10/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var viewModel = OnboardingViewModel()
    @Binding var stage: OnboardingStage
    
    var body: some View {
        ZStack {
            VideoView(playerLayer: viewModel.playerLayer)
                .ignoresSafeArea()
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            ZStack {
                IntroView { stage = .authorization }
                    .opacity(stage == .intro ? 1 : 0)
                AuthorizationView { stage = .ready }
                    .opacity(stage == .authorization ? 1 : 0)
            }
            .animation(.easeInOut, value: stage)
        }
        .onAppear(perform: viewModel.onAppear)
        .onChange(of: scenePhase) { _, _ in
            viewModel.onChangeScenePhase()
        }
    }
}
