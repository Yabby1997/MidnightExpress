//
//  BottomLined.swift
//  MidnightExp
//
//  Created by Seunghun on 2/24/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct BottomLined: ViewModifier {
    let isVisible: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            if isVisible {
                content
                    .shadow(radius: 12)
                    .background(
                        GeometryReader { geometry in
                            ZStack {
                                Rectangle()
                                    .frame(minWidth: 12)
                                    .frame(height: 8)
                                    .foregroundStyle(.yellow)
                                    .offset(y: geometry.size.height / 2.0 + 4)
                            }
                        }
                    )
            } else {
                content
            }
        }
    }
}

extension View {
    func bottomLined(isVisible: Bool = true) -> some View {
        modifier(BottomLined(isVisible: isVisible))
    }
}

#Preview {
    Text("Hello Good bye Hello Good bye")
        .bottomLined()
}
