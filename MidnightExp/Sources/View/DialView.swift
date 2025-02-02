//
//  DialView.swift
//  MidnightExp
//
//  Created by Seunghun on 1/27/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct DialView<ViewModel: DialControlViewModel>: View {
    let title: String
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .shadow(radius: 2)
            .rotationEffect(viewModel.orientation.angle)
            .animation(.easeInOut, value: viewModel.orientation)
    }
}
