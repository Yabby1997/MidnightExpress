    //
//  ContentViewModel.swift
//  MidnightExpDev
//
//  Created by Seunghun on 12/26/24.
//  Copyright © 2024 seunghun. All rights reserved.
//

import Combine
import CoreMedia
import CoreMotion
import LightMeter
import Obscura
import UIKit

enum ControlType: CaseIterable, Hashable {
    case frameRate
    case shutterAngle
    case exposure
    case zoom
}

enum Level {
    case portrait(angle: Double)
    case portraitUpsideDown(angle: Double)
    case landscapeRight(angle: Double)
    case landscapeLeft(angle: Double)
    case floor(roll: Double, pitch: Double)
}

enum Orientation: Equatable {
    case portrait
    case portraitUpsideDown
    case landscapeRight
    case landscapeLeft
}

@MainActor
final class ContentViewModel: ObservableObject {
    let camera = ObscuraCamera()
    var previewLayer: CALayer { camera.previewLayer }
    
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    @Published var level: Level = .portrait(angle: .zero)
    @Published var orientation: Orientation = .portrait
    
    @Published var controlType: ControlType = .frameRate
    @Published var shutterAngle: Int = 180
    @Published var isCapturing: Bool = false
    @Published var shutterSpeed: Float = .zero
    @Published var iso: Float = .zero
    @Published var targetExposureValue: Float = .zero
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

    private func setLevel(_ level: Level) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.level = level
        }
    }
    
    private func setOrientation(_ orientation: Orientation) {
        DispatchQueue.main.async { [weak self] in
            guard let self, self.orientation != orientation else { return }
            self.orientation = orientation
        }
    }
    
    func setup() async {
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] data, error in
            guard let self, let data else { return }
            let roll = (data.attitude.roll * (180.0 / .pi)).normalizedDegrees
            let pitch = (data.attitude.pitch * (180.0 / .pi)).normalizedDegrees
            let rotation = ((atan2(data.gravity.x, data.gravity.y) - .pi) * (180.0 / .pi)).normalizedDegrees
            
            if 45 >= abs(roll), 45 >= abs(pitch) {
                setLevel(.floor(roll: roll, pitch: pitch))
            } else {
                if (-45..<45) ~= rotation {
                    setLevel(.portrait(angle: rotation))
                } else if (45..<135) ~= rotation {
                    setLevel(.landscapeRight(angle: rotation))
                } else if (-135 ..< -45) ~= rotation {
                    setLevel(.landscapeLeft(angle: rotation))
                } else {
                    setLevel(.portraitUpsideDown(angle: rotation))
                }
            }
            
            guard 45 < abs(roll) || 45 < abs(pitch) else { return }
            if (-45..<45) ~= rotation {
                setOrientation(.portrait)
            } else if (45..<135) ~= rotation {
                setOrientation(.landscapeRight)
            } else if (-135 ..< -45) ~= rotation {
                setOrientation(.landscapeLeft)
            } else {
                setOrientation(.portraitUpsideDown)
            }
        }
        
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
        
        camera.zoomFactor
            .map { Float($0) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$zoomFactor)
        
        Publishers.CombineLatest4($frameRate, $exposureBias, camera.exposureValue, camera.aperture)
            .sink { [weak self] frameRate, exposureBias, exposureValue, apertureValue in
                self?.setFrameRate(frameRate, exposureValue: exposureValue - exposureBias, apertureValue: apertureValue)
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
        let targetShutterSpeed = 1 / Float(frameRate) * Float(shutterAngle) / 360.0
        setFrameRateTask?.cancel()
        setFrameRateTask = Task {
            try camera.lockFrameRate(Int32(frameRate))
            try Task.checkCancellation()
            try await camera.lockExposure(
                shutterSpeed: .init(value: Int64(ceil(targetShutterSpeed * 1_000_000_000.0)), timescale: 1_000_000_000),
                iso: try LightMeterService.getIsoValue(ev: exposureValue, shutterSpeed: targetShutterSpeed, aperture: apertureValue)
            )
        }
    }
    
    func didTapToggle() {
        try? camera.switchCamera()
    }
    
    func didTapShutter() {
        Task {
            do {
                if isCapturing, let result = try await camera.stopRecordVideo(), let videoPath = result.videoPath {
                    let url = URL.homeDirectory.appending(path: videoPath)
                    try await PhotoLibrary.save(video: url)
                    try FileManager.default.removeItem(at: url)
                } else {
                    try camera.startRecordVideo(allowHapticsAndSystemSounds: true)
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

extension Double {
    fileprivate var normalizedDegrees: Double {
        let remainder = truncatingRemainder(dividingBy: 360)
        return remainder > 180 ? remainder - 360 : (remainder < -180 ? remainder + 360 : remainder)
    }
}
