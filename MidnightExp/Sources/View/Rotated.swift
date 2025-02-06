//
//  Rotated.swift
//  MidnightExp
//
//  Created by Seunghun on 2/7/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

private struct Rotated: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let size = subviews.first?.sizeThatFits(proposal) else { return .zero }
        return .init(width: size.height, height: size.width)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.first?.place(
            at: .init(x: bounds.midX, y: bounds.midY),
            anchor: .center,
            proposal: proposal
        )
    }
}

struct RotateClockwise: ViewModifier {
    func body(content: Content) -> some View {
        Rotated {
            content
                .rotationEffect(.degrees(90))
        }
    }
}

struct RotateAnticlockwise: ViewModifier {
    func body(content: Content) -> some View {
        Rotated {
            content
                .rotationEffect(.degrees(-90))
        }
    }
}

extension View {
    func rotateClockwise() -> some View {
        modifier(RotateClockwise())
    }
    
    func rotateAnticlockwise() -> some View {
        modifier(RotateAnticlockwise())
    }
}
