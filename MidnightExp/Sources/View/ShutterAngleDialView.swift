//
//  ShutterAngleDialView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/24/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct ShutterAngleDialView: View {
    let value: Int
    @StateObject var viewModel: MidnightExpressViewModel
    
    var body: some View {
        Text("\(value)°")
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
            .foregroundStyle(value == 180 ? .yellow : .white)
            .bottomLined(isVisible: viewModel.tutorialStage == .shutterAngle && value == 360)
            .shadow(radius: 2)
            .rotationEffect(viewModel.orientation.angle)
            .animation(.easeInOut, value: viewModel.orientation)
            .animation(.easeIn, value: viewModel.tutorialStage)
    }
}
