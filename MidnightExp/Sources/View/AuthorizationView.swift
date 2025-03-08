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
    
    fileprivate func authButton(systemName: String, isAuthorized: Bool, text: String, action: @escaping () -> Void) -> some View {
        HStack {
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
        }
        .onTapGesture(perform: action)
    }
    
    var body: some View {
        VStack {
            Text("권한 요청")
                .font(.system(size: 40, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 24)
            Text("MidnightExpress는 다음과 같은 권한을 필요로합니다.")
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 82)
            VStack(alignment: .leading, spacing: 40) {
                authButton(
                    systemName: "camera.fill",
                    isAuthorized: viewModel.isCameraAuthorized,
                    text: "영상촬영을 위해 카메라 접근 권한이 필요합니다.",
                    action: viewModel.didTapVideoAuthButton
                )
                authButton(
                    systemName: "microphone.fill",
                    isAuthorized: viewModel.isMicAuthorized,
                    text: "음성녹음을 위해 마이크 접근 권한이 필요합니다.",
                    action: viewModel.didTapAudioAuthButton
                )
                authButton(
                    systemName: "photo.on.rectangle.angled.fill",
                    isAuthorized: viewModel.isPhotoLibraryAuthorized,
                    text: "결과물을 저장하기 위해 사진첩 쓰기 권한이 필요합니다.",
                    action: viewModel.didTapPhotoAddAuthButton
                )
            }
        }
        .padding(.horizontal, 12)
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
