//
//  MidnightExpressAuthorizationManageable.swift
//  MidnightExp
//
//  Created by Seunghun on 2/15/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import AVFoundation
@preconcurrency import Combine
import Photos

enum AuthorizationStatus {
    case authorizationNeeded
    case authorized
    case notAuthorized
    var isAuthorized: Bool { self == .authorized }
}

@MainActor
protocol MidnightExpressAuthorizationManageable {
    var cameraAuthStatusPublisher: AnyPublisher<AuthorizationStatus, Never> { get }
    var micAuthStatusPublisher: AnyPublisher<AuthorizationStatus, Never> { get }
    var photoLibraryAuthStatusPublisher: AnyPublisher<AuthorizationStatus, Never> { get }
    
    func validate()
    func requestCameraAuthorization()
    func requestMicAuthorization()
    func requestPhotoLibraryAuthorization()
}

final class MidnightExpressAuthorizationManager: MidnightExpressAuthorizationManageable {
    private var cameraAuthStatus = CurrentValueSubject<AuthorizationStatus, Never>(.authorizationNeeded)
    private var audioAuthStatus = CurrentValueSubject<AuthorizationStatus, Never>(.authorizationNeeded)
    private var photoLibraryAuthStatus = CurrentValueSubject<AuthorizationStatus, Never>(.authorizationNeeded)
    
    let cameraAuthStatusPublisher: AnyPublisher<AuthorizationStatus, Never>
    let micAuthStatusPublisher: AnyPublisher<AuthorizationStatus, Never>
    let photoLibraryAuthStatusPublisher: AnyPublisher<AuthorizationStatus, Never>
    
    static var shared = MidnightExpressAuthorizationManager()
    
    private init() {
        cameraAuthStatusPublisher = cameraAuthStatus.eraseToAnyPublisher()
        micAuthStatusPublisher = audioAuthStatus.eraseToAnyPublisher()
        photoLibraryAuthStatusPublisher = photoLibraryAuthStatus.eraseToAnyPublisher()
    }
    
    func validate() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: cameraAuthStatus.send(.authorizationNeeded)
        case .authorized: cameraAuthStatus.send(.authorized)
        default: cameraAuthStatus.send(.notAuthorized)
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined: audioAuthStatus.send(.authorizationNeeded)
        case .authorized: audioAuthStatus.send(.authorized)
        default: audioAuthStatus.send(.notAuthorized)
        }
        
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
        case .notDetermined: photoLibraryAuthStatus.send(.authorizationNeeded)
        case .limited, .authorized: photoLibraryAuthStatus.send(.authorized)
        default: photoLibraryAuthStatus.send(.notAuthorized)
        }
    }
    
    func requestCameraAuthorization() {
        Task {
            await AVCaptureDevice.requestAccess(for: .video)
            validate()
        }
    }
    
    func requestMicAuthorization() {
        Task {
            await AVCaptureDevice.requestAccess(for: .audio)
            validate()
        }
    }
    
    func requestPhotoLibraryAuthorization() {
        Task {
            await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            validate()
        }
    }
}
