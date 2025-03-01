//
//  LockIndicatorView.swift
//  MidnightExp
//
//  Created by Seunghun on 12/28/24.
//  Copyright © 2024 seunghun. All rights reserved.
//

import SwiftUI

struct LockIindicatorView: View {
    @StateObject var viewModel: MidnightExpressViewModel
    
    var body: some View {
        if let point = viewModel.focusLockPoint {
            Rectangle()
                .foregroundStyle(.clear)
                .border(viewModel.isFocusLocked ? .green : viewModel.isFocusLocking ? .red : .yellow, width: 2)
                .frame(width: 60, height: 60)
                .position(point)
                .opacity(viewModel.isFrontFacing ? .zero : 1.0)
        }
    }
}
