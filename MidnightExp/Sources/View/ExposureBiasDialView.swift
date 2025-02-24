//
//  ExposureBiasDialView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/24/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct ExposureBiasDialView: View {
    let value: Float
    @StateObject var viewModel: MidnightExpressViewModel
    
    var body: some View {
        Text(String(format: "%+0.1f", value))
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
            .bottomLined(isVisible: viewModel.tutorialStage == .exposureBias && value == -2.0)
            .shadow(radius: 2)
            .rotationEffect(viewModel.orientation.angle)
            .animation(.easeInOut, value: viewModel.orientation)
            .animation(.easeIn, value: viewModel.tutorialStage)
    }
}
