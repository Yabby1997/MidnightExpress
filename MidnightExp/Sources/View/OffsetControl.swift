//
//  OffsetSlider.swift
//  MidnightExp
//
//  Created by Seunghun on 12/29/24.
//  Copyright © 2024 seunghun. All rights reserved.
//

import SwiftUI

struct OffsetSlider: View {
    @Binding var offset: Float
    
    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 6)
                .shadow(radius: 5)
                .frame(width: 20, height: 40)
                .offset(x: (proxy.size.width - 20) / 2.0 + CGFloat(offset) * (proxy.size.width - 20) / 2.0)
                .gesture(
                    DragGesture()
                        .onChanged { offset = max(min(Float($0.translation.width / (proxy.size.width / 2.0)), 1.0), -1.0) }
                        .onEnded { _ in withAnimation { offset = .zero } }
                )
        }
        .frame(height: 40)
    }
}

#Preview {
    @Previewable @State var offset: Float = 0.0
    VStack {
        Text("Offset: \(String(format: "%.2f", offset))")
            .font(.headline)
            .padding()
        OffsetSlider(offset: $offset)
    }
    .padding(.horizontal, 100)
}
