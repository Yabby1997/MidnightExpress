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
        }
        .onAppear(perform: viewModel.onAppear)
    }
}

#Preview {
    OnboardingView()
}
