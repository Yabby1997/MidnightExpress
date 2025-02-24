//
//  FlipButton.swift
//  MidnightExp
//
//  Created by Seunghun on 2/2/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct FlipButton: View {
    @StateObject var viewModel: MidnightExpressViewModel
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: viewModel.didTapToggle) {
                Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30)
                    .foregroundStyle(.white)
                    .bottomLined(isVisible: viewModel.tutorialStage == .selfie)
                    .rotationEffect(viewModel.orientation.angle)
                    .animation(.easeInOut, value: viewModel.orientation)
                    .animation(.easeInOut, value: viewModel.tutorialStage)
            }
        }
    }
}
