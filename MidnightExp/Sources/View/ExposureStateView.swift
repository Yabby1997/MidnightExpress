//
//  ExposureStateView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/6/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct ExposureStateView: View {
    @Binding var exposureState: ExposureState
    
    var body: some View {
        if exposureState == .correctExposure {
            EmptyView()
        } else {
            Text(exposureState == .overExposure ? "Over Exposed" : "Under Exposed")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .padding(4)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(Color.red)
                }
        }
    }
}
