//
//  OnboardingView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/10/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            VideoView(playerLayer: viewModel.playerLayer)
                .ignoresSafeArea()
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            OnboardingPagingView(stage: $viewModel.stage)
            VStack {
                Spacer()
                Button(action: viewModel.didTapNext) {
                    Text("Next")
                }
            }
        }
        .onAppear(perform: viewModel.onAppear)
    }
}

#Preview {
    OnboardingView()
}
