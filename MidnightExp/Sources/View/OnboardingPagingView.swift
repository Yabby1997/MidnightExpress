//
//  OnboardingPagingView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/15/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct OnboardingPagingView: View {
    @Binding var stage: OnboardingStage
    
    var body: some View {
        ZStack {
            Text("Intro")
                .opacity(stage == .intro ? 1 : 0)
            Text("Tutorial")
                .opacity(stage == .tutorial ? 1 : 0)
            Text("Authorization")
                .opacity(stage == .authorization ? 1 : 0)
            Text("Ready")
                .opacity(stage == .ready ? 1 : 0)
        }
        .animation(.easeInOut, value: stage)
    }
}
