//
//  ShutterButton.swift
//  MidnightExp
//
//  Created by Seunghun on 2/2/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct ShutterButton: View {
    @StateObject var viewModel: MidnightExpressViewModel
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: viewModel.didTapShutter) {
                Circle()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(viewModel.isCapturing ? .red : .white)
            }
            Spacer()
        }
    }
}
