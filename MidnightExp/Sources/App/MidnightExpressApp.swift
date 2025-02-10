//
//  MidnightExpressApp.swift
//  MidnightExpDev
//
//  Created by Seunghun on 12/18/24.
//

import SwiftUI

@main
struct MidnightExpressApp: App {
//    @AppStorage("isOnBoardingNeeded") var isOnboardingNeeded = true
    @State var isOnboardingNeeded = false

    var body: some Scene {
        WindowGroup {
            MidnightExpressView()
                .onTapGesture(count: 3) {
                    isOnboardingNeeded = true
                }
                .fullScreenCover(isPresented: $isOnboardingNeeded) {
                    OnboardingView()
                }
        }
    }
}
