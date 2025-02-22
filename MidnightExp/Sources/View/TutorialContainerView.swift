//
//  TutorialContainerView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/22/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct TutorialContainerView: View {
    @Binding var stage: TutorialStage
    @Binding var orientation: Orientation
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                TutorialView(stage: $stage)
                Spacer()
            }
            .opacity(orientation == .portrait ? 1.0 : .zero)
            HStack {
                Spacer()
                TutorialView(stage: $stage)
                    .rotateClockwise()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
            .opacity(orientation == .landscapeRight ? 1.0 : .zero)
            VStack {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                TutorialView(stage: $stage)
                    .rotateClockwise()
                    .rotateClockwise()
                Spacer()
            }
            .opacity(orientation == .portraitUpsideDown ? 1.0 : .zero)
            HStack {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                TutorialView(stage: $stage)
                    .rotateClockwise()
                    .rotateClockwise()
                    .rotateClockwise()
                Spacer()
            }
            .opacity(orientation == .landscapeLeft ? 1.0 : .zero)
        }
        .font(.system(size: 14, weight: .bold))
        .foregroundStyle(.yellow)
        .shadow(radius: 2)
        .padding(.horizontal, 12)
        .animation(.easeInOut, value: stage)
        .animation(.easeInOut, value: orientation)
    }
}
