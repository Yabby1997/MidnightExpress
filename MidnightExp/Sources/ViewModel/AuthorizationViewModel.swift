//
//  AuthorizationViewModel.swift
//  MidnightExp
//
//  Created by Seunghun on 2/15/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import Foundation

@MainActor
final class AuthorizationViewModel: ObservableObject {
    let authorizationManager: any MidnightExpressAuthorizationManageable
    let settingsOpener: any SettingsOpenable
    
    @Published private var cameraAuthStatus = AuthorizationStatus.authorizationNeeded
    @Published private var micAuthStatus = AuthorizationStatus.authorizationNeeded
    @Published private var photoLibraryAuthStatus = AuthorizationStatus.authorizationNeeded
    @Published var isCameraAuthorized = false
    @Published var isMicAuthorized = false
    @Published var isPhotoLibraryAuthorized = false
    @Published var canProceed: Bool = false
    
    init(
        authorizationManager: any MidnightExpressAuthorizationManageable = MidnightExpressAuthorizationManager.shared,
        settingsOpener: any SettingsOpenable = UIApplicationSettingsOpener.shared
    ) {
        self.authorizationManager = authorizationManager
        self.settingsOpener = settingsOpener
        bind()
    }
    
    private func bind() {
        authorizationManager.cameraAuthStatusPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$cameraAuthStatus)
        
        authorizationManager.cameraAuthStatusPublisher
            .map { $0.isAuthorized }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &$isCameraAuthorized)
        
        authorizationManager.micAuthStatusPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$micAuthStatus)
        
        authorizationManager.micAuthStatusPublisher
            .map { $0.isAuthorized }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &$isMicAuthorized)
        
        authorizationManager.photoLibraryAuthStatusPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$photoLibraryAuthStatus)
        
        authorizationManager.photoLibraryAuthStatusPublisher
            .map { $0.isAuthorized }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &$isPhotoLibraryAuthorized)
        
        $isCameraAuthorized.combineLatest($isMicAuthorized, $isPhotoLibraryAuthorized)
            .map { $0 && $1 && $2 }
            .debounce(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .assign(to: &$canProceed)
    }
    
    func onAppear() {
        authorizationManager.validate()
    }
    
    func didTapVideoAuthButton() {
        switch cameraAuthStatus {
        case .authorizationNeeded: authorizationManager.requestCameraAuthorization()
        case .notAuthorized: settingsOpener.open()
        default: break
        }
    }
    
    func didTapAudioAuthButton() {
        switch micAuthStatus {
        case .authorizationNeeded: authorizationManager.requestMicAuthorization()
        case .notAuthorized: settingsOpener.open()
        default: break
        }
    }
    
    func didTapPhotoAddAuthButton() {
        switch photoLibraryAuthStatus {
        case .authorizationNeeded: authorizationManager.requestPhotoLibraryAuthorization()
        case .notAuthorized: settingsOpener.open()
        default: break
        }
    }
}
