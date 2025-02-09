//
//  DebugView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/8/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct DebugView: View {
    @StateObject var viewModel: ContentViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("ISO :\(viewModel.iso)")
                Text("Shutter Speed: \(viewModel.shutterSpeed)")
                Text("EV: \(viewModel.exposureValue)")
                Text("Offset: \(viewModel.exposureOffset)")
                Spacer()
            }
            .font(.system(size: 10, weight: .semibold, design: .monospaced))
            .foregroundStyle(.yellow)
            .shadow(radius: 5)
            Spacer()
        }
        .padding(4)
    }
}
