//
//  AuthorizationView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/15/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import SwiftUI

struct AuthorizationView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var viewModel = AuthorizationViewModel()
    var proceed: () -> Void
    
    fileprivate func authButton(systemName: String, isAuthorized: Bool, text: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .foregroundStyle(isAuthorized ? .green : .red)
                    .animation(.easeInOut, value: isAuthorized)
                Image(systemName: systemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
            .frame(width: 60, height: 60)
            Text(text)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .onTapGesture(perform: action)
        .sensoryFeedback(.impact(weight: .heavy), trigger: isAuthorized) { $1 }
    }
    
    var body: some View {
        VStack {
            Text("authorizationViewTitle")
                .font(.system(size: 40, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 24)
            Text("authorizationViewSubtitle")
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 82)
            VStack(alignment: .leading, spacing: 40) {
                authButton(
                    systemName: "camera.fill",
                    isAuthorized: viewModel.isCameraAuthorized,
                    text: "authorizationViewCameraText",
                    action: viewModel.didTapVideoAuthButton
                )
                authButton(
                    systemName: "microphone.fill",
                    isAuthorized: viewModel.isMicAuthorized,
                    text: "authorizationViewMicText",
                    action: viewModel.didTapAudioAuthButton
                )
                authButton(
                    systemName: "photo.on.rectangle.angled.fill",
                    isAuthorized: viewModel.isPhotoLibraryAuthorized,
                    text: "authorizationViewPhotoLibraryText",
                    action: viewModel.didTapPhotoAddAuthButton
                )
            }
        }
        .padding(.horizontal, 20)
        .onAppear(perform: viewModel.onAppear)
        .onChange(of: scenePhase) { oldValue, newValue in
            guard newValue == .active else { return }
            viewModel.onAppear()
        }
        .onChange(of: viewModel.canProceed) { _, newValue in
            guard newValue else { return }
            proceed()
        }
    }
}
