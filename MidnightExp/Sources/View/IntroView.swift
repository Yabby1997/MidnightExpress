//
//  IntroView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/19/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

enum IntroStep {
    case step1
    case step2
    case step3
    
    var next: IntroStep? {
        switch self {
        case .step1: .step2
        case .step2: .step3
        case .step3: nil
        }
    }
    
    var prev: IntroStep? {
        switch self {
        case .step1: nil
        case .step2: .step1
        case .step3: .step2
        }
    }
}

struct IntroView: View {
    @State private var isLogDisplaying = true
    @State private var introStep = IntroStep.step1
    let proceed: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            Image(.logo)
                .resizable()
                .frame(width: isLogDisplaying ? 250 : 200, height: isLogDisplaying ? 250 : 200)
                .padding(.bottom, 24)
            if isLogDisplaying == false {
                Text("introWelcomeText")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 48)
                Spacer()
                ZStack {
                    Text("introWhatIsStepPrinting").opacity(introStep == .step1 ? 1.0 : .zero)
                    Text("introWhatIsStepPrinting2").opacity(introStep == .step2 ? 1.0 : .zero)
                    Text("introWhatIsStepPrinting3").opacity(introStep == .step3 ? 1.0 : .zero)
                }
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                Spacer()
                HStack {
                    Button {
                        if let prevStep = introStep.prev {
                            introStep = prevStep
                        }
                    } label: {
                        Text("introPrevButtonTitle")
                            .foregroundStyle(.white)
                            .font(.system(size: 18, weight: .bold, design: .serif))
                    }
                    .opacity(introStep != .step1 ? 1.0 : .zero)
                    Spacer()
                    Button {
                        if let nextStep = introStep.next {
                            introStep = nextStep
                        } else {
                            proceed()
                        }
                    } label: {
                        Text("introNextButtonTitle")
                            .foregroundStyle(.white)
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .bottomLined()
                    }
                }
            }
            Spacer()
        }
        .transition(.slide)
        .animation(.easeInOut, value: isLogDisplaying)
        .animation(.easeInOut, value: introStep)
        .padding(.horizontal, 12)
        .task {
            try? await Task.sleep(for: .seconds(2))
            isLogDisplaying = false
        }
    }
}
