//
//  ContentViewModel.swift
//  MidnightExpDev
//
//  Created by Seunghun on 12/26/24.
//  Copyright © 2024 seunghun. All rights reserved.
//

import Combine
import CoreMedia
import LightMeter
import Obscura
import Photos
import UIKit

@MainActor
final class ContentViewModel: ObservableObject {
    let camera = ObscuraCamera()
    var previewLayer: CALayer { camera.previewLayer }
    let feedback = UIImpactFeedbackGenerator(style: .soft)
    
    @Published var isCapturing: Bool = false
    @Published var shutterSpeed: Float = .zero
    @Published var iso: Float = .zero
    @Published var aperture: Float = .zero
    @Published var exposureValue: Float = .zero
    
    var cancellable: AnyCancellable?

    func setup() async {
        do {
            try await camera.setup()
            try await camera.requestMicAuthorization()
        } catch {
            print("Error: \(error)")
        }
        
        camera.isCapturing
            .receive(on: DispatchQueue.main)
            .assign(to: &$isCapturing)
        
        Publishers.CombineLatest3(camera.iso, camera.shutterSpeed, camera.aperture)
            .compactMap { try? LightMeterService.getExposureValue(iso: $0, shutterSpeed: $1, aperture: $2) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$exposureValue)
        
        camera.iso
            .receive(on: DispatchQueue.main)
            .assign(to: &$iso)
        
        camera.shutterSpeed
            .receive(on: DispatchQueue.main)
            .assign(to: &$shutterSpeed)
        
        camera.aperture
            .receive(on: DispatchQueue.main)
            .assign(to: &$aperture)
    }
    
    func didTapShutter() {
        Task {
            do {
                if isCapturing {
                    try await camera.stopObscuraRecorder()
                } else {
                    guard let recorder = MidnightExpressRecorder(baseURL: URL.homeDirectory.appending(path: "Documents/Obscura/Videos"), delegate: self) else { return }
                    let iso = try LightMeterService.getIsoValue(ev: exposureValue, shutterSpeed: 1 / 6, aperture: aperture)
                    try camera.lockFrameRate(6)
                    try await camera.lockExposure(shutterSpeed: .init(value: 166666667, timescale: 1000000000), iso: iso)
                    try await camera.start(obscuraRecorder: recorder)
                    try AVAudioSession.sharedInstance().setAllowHapticsAndSystemSoundsDuringRecording(true)
                }
            } catch {
                print(error)
            }
        }
    }
}

extension ContentViewModel: MidnightExpressRecorderDelegate {
    nonisolated func didCaptureFrame(_ midnightExpressRecorder: MidnightExpressRecorder) {
        Task { @MainActor in
            feedback.impactOccurred()
        }
    }
    
    nonisolated func midnightExpressRecorder(_ midnightExpressRecorder: MidnightExpressRecorder, didSaveOutputAt url: URL) {
        Task { @MainActor in
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    print("Photo library access not granted")
                    return
                }
                PHPhotoLibrary.shared().performChanges{
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }
            }
        }
    }
}
