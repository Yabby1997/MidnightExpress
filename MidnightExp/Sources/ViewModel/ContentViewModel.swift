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
    @Published var exposureValue: Float = .zero
    @Published var exposureBias: Float = .zero
    @Published var frameRate: Int = 12
    @Published var exposureOffset: Float = .zero
    @Published var isFocusLocked = false
    @Published var focusLockPoint: CGPoint?
    @Published var isFrontFacing = false
    @Published var zoomFactor: Float = 1
    @Published var zoomOffset: Float = .zero
    var isFocusUnlockable: Bool { (isFocusLocked || focusLockPoint != nil) && isFrontFacing == false }
    
    private var cancellables: Set<AnyCancellable> = []
    private var setFrameRateTask: Task<Void, Error>?
    private var setExposureBiasTask: Task<Void, Error>?

    func setup() async {
        do {
            try await camera.setup()
            try await camera.requestMicAuthorization()
        } catch {
            print("Error: \(error)")
        }
        
        camera.iso
            .receive(on: DispatchQueue.main)
            .assign(to: &$iso)
        
        camera.shutterSpeed
            .receive(on: DispatchQueue.main)
            .assign(to: &$shutterSpeed)
        
        camera.isCapturing
            .receive(on: DispatchQueue.main)
            .assign(to: &$isCapturing)
        
        camera.focusLockPoint
            .receive(on: DispatchQueue.main)
            .assign(to: &$focusLockPoint)
        
        camera.isFocusLocked
            .receive(on: DispatchQueue.main)
            .assign(to: &$isFocusLocked)
        
        camera.isFocusLocked
            .debounce(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .filter { $0 }
            .map { _ in nil }
            .receive(on: DispatchQueue.main)
            .assign(to: &$focusLockPoint)
        
        camera.isFrontFacing
            .receive(on: DispatchQueue.main)
            .assign(to: &$isFrontFacing)
        
        camera.exposureValue
            .receive(on: DispatchQueue.main)
            .assign(to: &$exposureValue)
        
        camera.exposureOffset
            .receive(on: DispatchQueue.main)
            .assign(to: &$exposureOffset)
        
        camera.exposureBias
            .receive(on: DispatchQueue.main)
            .assign(to: &$exposureBias)
        
        camera.zoomFactor
            .map { Float($0) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$zoomFactor)
        
        Publishers.CombineLatest3($frameRate, camera.exposureValue, camera.aperture)
            .sink { [weak self] frameRate, exposureValue, apertureValue in
                self?.setFrameRate(frameRate, exposureValue: exposureValue, apertureValue: apertureValue)
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            Timer.publish(every: 0.01, on: .main, in: .default).autoconnect(),
            $zoomOffset
        )
        .map { $0.1 }
        .filter { $0 != .zero }
        .compactMap { [weak self] offset -> CGFloat? in
            guard let self else { return nil }
            return min(5, CGFloat(zoomFactor + offset / 100))
            
        }
        .sink { [weak self] zoomFactor in
            try? self?.camera.zoom(factor: zoomFactor, animated: false)
        }
        .store(in: &cancellables)
    }
    
    private func setFrameRate(_ frameRate: Int, exposureValue: Float, apertureValue: Float) {
        setFrameRateTask?.cancel()
        setFrameRateTask = Task {
            try camera.lockFrameRate(Int32(frameRate))
            try Task.checkCancellation()
            try await camera.lockExposure(
                shutterSpeed: .init(
                    value: Int64(ceil(1.0 / Double(frameRate) * 1_000_000_000.0)),
                    timescale: 1_000_000_000
                ),
                iso: try LightMeterService.getIsoValue(
                    ev: exposureValue,
                    shutterSpeed: 1 / Float(frameRate),
                    aperture: apertureValue
                )
            )
        }
    }
    
    func didChangeExposureBiasSlider(value: Float) {
        setExposureBiasTask?.cancel()
        setExposureBiasTask = Task {
            try Task.checkCancellation()
            try await camera.setExposure(bias: value)
        }
    }
    
    func didTapToggle() {
        try? camera.switchCamera()
    }
    
    func didTapShutter() {
        Task {
            do {
                if isCapturing {
                    try await camera.stopObscuraRecorder()
                } else {
                    guard let recorder = MidnightExpressRecorder(baseURL: URL.homeDirectory.appending(path: "Documents/Obscura/Videos"), delegate: self) else { return }
                    try await camera.start(obscuraRecorder: recorder)
                    try AVAudioSession.sharedInstance().setAllowHapticsAndSystemSoundsDuringRecording(true)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func didTapScreen(on position: CGPoint) {
        Task {
            do {
                try camera.lockFocus(on: position)
            }
        }
    }
    
    func didTapUnlock() {
        Task {
            try camera.unlockFocus()
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
