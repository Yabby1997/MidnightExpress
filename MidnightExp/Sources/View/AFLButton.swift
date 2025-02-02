//
//  AFLButton.swift
//  MidnightExp
//
//  Created by Seunghun on 2/2/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct AFLButton: View {
    @StateObject var viewModel: ContentViewModel
    
    var body: some View {
        HStack {
            Button(action: viewModel.didTapUnlock) {
                Text(viewModel.isFocusUnlockable ? "AF-L" : "AF")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .frame(width: 60, height: 60)
                    .animation(.easeIn, value: viewModel.isFocusUnlockable)
                    .foregroundStyle(viewModel.isFocusUnlockable ? .yellow : .gray)
                    .rotationEffect(viewModel.orientation.angle)
                    .animation(.easeInOut, value: viewModel.orientation)
            }
            Spacer()
        }
    }
}
