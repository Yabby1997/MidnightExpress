//
//  TutorialStageView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/22/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct TutorialStageView: View {
    let instruction: String
    let actionLabel: String
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(instruction)
            Button {
                action()
            } label: {
                Text(actionLabel)
            }
        }
    }
}
