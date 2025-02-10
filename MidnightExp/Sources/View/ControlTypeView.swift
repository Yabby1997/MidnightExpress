//
//  ControlTypeView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/2/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct ControlTypeView: View {
    @StateObject var viewModel: MidnightExpressViewModel
    
    var body: some View {
        HStack(spacing: 22) {
            Text("\(viewModel.frameRate)fps")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .animation(.easeIn, value: viewModel.frameRate)
                .foregroundStyle(viewModel.controlType == .frameRate ? .white : .gray)
                .onTapGesture { viewModel.controlType = .frameRate }
                .rotationEffect(viewModel.orientation.angle)
                .animation(.easeInOut, value: viewModel.orientation)
                .frame(width: 60)
            Text("\(viewModel.shutterAngle)°")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .animation(.easeIn, value: viewModel.shutterAngle)
                .foregroundStyle(viewModel.controlType == .shutterAngle ? .white : .gray)
                .onTapGesture { viewModel.controlType = .shutterAngle }
                .rotationEffect(viewModel.orientation.angle)
                .animation(.easeInOut, value: viewModel.orientation)
                .frame(width: 60)
            Text(String(format: "%+0.1f", viewModel.exposureBias))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .animation(.easeIn, value: viewModel.exposureBias)
                .foregroundStyle(viewModel.controlType == .exposure ? .white : .gray)
                .onTapGesture { viewModel.controlType = .exposure }
                .rotationEffect(viewModel.orientation.angle)
                .animation(.easeInOut, value: viewModel.orientation)
                .frame(width: 60)
            Text("x" + String(format: "%.1f", viewModel.zoomFactor))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .animation(.easeIn, value: viewModel.zoomFactor)
                .foregroundStyle(viewModel.controlType == .zoom ? .white : .gray)
                .onTapGesture { viewModel.controlType = .zoom }
                .rotationEffect(viewModel.orientation.angle)
                .animation(.easeInOut, value: viewModel.orientation)
                .frame(width: 60)
        }
        .animation(.easeInOut, value: viewModel.controlType)
        .contentTransition(.numericText())
        .frame(height: 60)
    }
}
