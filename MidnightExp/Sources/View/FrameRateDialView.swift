//
//  FrameRateDialView.swift
//  MidnightExp
//
//  Created by Seunghun on 1/27/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct FrameRateDialView: View {
    let value: Int
    @StateObject var viewModel: MidnightExpressViewModel
    
    var body: some View {
        Text("\(value)")
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
            .bottomLined(isVisible: viewModel.tutorialStage == .fps && value == 4)
            .shadow(radius: 2)
            .rotationEffect(viewModel.orientation.angle)
            .animation(.easeInOut, value: viewModel.orientation)
            .animation(.easeIn, value: viewModel.tutorialStage)
    }
}
