//
//  TutorialStageView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/27/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct TutorialStageView: View {
    let tutorial: LocalizedStringKey
    let instruction: LocalizedStringKey?
    
    var body: some View {
        VStack(spacing: 12) {
            Text(tutorial)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
            if let instruction {
                Text(instruction)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.yellow)
            }
        }
        .multilineTextAlignment(.center)
        .shadow(color: .black, radius: 14)
    }
}

#Preview {
    TutorialStageView(
        tutorial: "프레임레이트가 작아질수록 단절된 영상을,\n커질수록 연속적인 영상을 촬영할 수 있어요.",
        instruction: "프레임레이트를 4로 조절해 차이를 느껴보세요."
    )
}
