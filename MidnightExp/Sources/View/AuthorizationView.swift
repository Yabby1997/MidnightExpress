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
    
    var body: some View {
        VStack {
            Spacer()
            Text("권한 요청")
                .font(.system(size: 50, weight: .bold, design: .rounded))
            Text("미드나잇 익스프레스를 이용하기 위해선 다음과 같은 권한이 필요합니다. ")
                .font(.system(size: 14, weight: .bold, design: .rounded))
            Spacer()
            HStack {
                ZStack {
                    Circle()
                        .foregroundStyle(viewModel.isCameraAuthorized ? .green : .red)
                        .animation(.easeInOut, value: viewModel.isCameraAuthorized)
                    Image(systemName: "camera.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
                .frame(width: 60, height: 60)
                Text("영상을 촬영하기 위해 카메라 권한이 필요합니다.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 14, weight: .semibold))
            }
            .onTapGesture {
                viewModel.didTapVideoAuthButton()
            }
            HStack {
                ZStack {
                    Circle()
                        .foregroundStyle(viewModel.isMicAuthorized ? .green : .red)
                        .animation(.easeInOut, value: viewModel.isMicAuthorized)
                    Image(systemName: "microphone.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
                .frame(width: 60, height: 60)
                Text("촬영시 음성을 함께 녹음하기 위해 마이크 권한이 필요합니다.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 14, weight: .semibold))
            }
            .onTapGesture {
                viewModel.didTapAudioAuthButton()
            }
            HStack {
                ZStack {
                    Circle()
                        .foregroundStyle(viewModel.isPhotoLibraryAuthorized ? .green : .red)
                        .animation(.easeInOut, value: viewModel.isPhotoLibraryAuthorized)
                    Image(systemName: "photo.on.rectangle.angled.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
                .frame(width: 60, height: 60)
                Text("촬영한 영상을 사진첩에 저장하기위해 사진첩 쓰기 권한이 필요합니다.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 14, weight: .semibold))
            }
            .onTapGesture {
                viewModel.didTapPhotoAddAuthButton()
            }
            Spacer()
            Spacer()
        }
        .foregroundStyle(.white)
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
