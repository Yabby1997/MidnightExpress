    //
//  MidnightExpressViewModel.swift
//  MidnightExpDev
//
//  Created by Seunghun on 12/26/24.
//  Copyright © 2024 seunghun. All rights reserved.
//

@preconcurrency import Combine
import CoreMotion
import LightMeter
import Obscura
import UIKit

enum ExposureState: Equatable {
    case correctExposure
    case overExposure
    case underExposure
}

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
    case sky(roll: Double, pitch: Double)
    
    var isSurface: Bool {
        if case .floor = self { return true }
        if case .sky = self { return true }
        return false
    }
}

enum Orientation: Equatable {
    case portrait
    case portraitUpsideDown
    case landscapeRight
    case landscapeLeft
    
    var isLandscape: Bool {
        self == .landscapeLeft || self == .landscapeRight
    }
}

@MainActor
final class MidnightExpressViewModel: ObservableObject {
    let camera = ObscuraCamera()
    var previewLayer: CALayer { camera.previewLayer }
    
    @Settings(key: SettingsKey.onboardingStage.rawValue, defaultValue: OnboardingStage.intro)
    var onboardingStage: OnboardingStage
    
    @Settings(key: SettingsKey.tutorialStage.rawValue, defaultValue: TutorialStage.fps)
    var tutorialStage: TutorialStage
    
    @Published var level: Level = .portrait(angle: .zero)
    @Published var orientation: Orientation = .portrait
    @Published var exposureState: ExposureState = .correctExposure
    
    @Published var controlType: ControlType = .frameRate
    @Published var shutterAngle: Int = 180
    @Published var isCapturing: Bool = false
    @Published var shutterSpeed: Float = .zero
    @Published var iso: Float = .zero
    @Published var targetExposureValue: Float = .zero
    @Published var exposureValue: Float = .zero
    @Published var exposureBias: Float = .zero
    @Published var frameRate: Int = 8
    @Published var exposureOffset: Float = .zero
    @Published var isFocusLocking = false
    @Published var isFocusLocked = false
    @Published var focusLockPoint: CGPoint?
    @Published var isFrontFacing = false
    @Published var zoomFactor: Float = 1
    @Published var zoomOffset: Float = .zero
    var isFocusUnlockable: Bool { (isFocusLocking || isFocusLocked) && isFrontFacing == false }
    
    private var cancellables: Set<AnyCancellable> = []
    private var sessionCancellables: Set<AnyCancellable> = []
    private var tutorialCancellables: Set<AnyCancellable> = []
    private var setFrameRateTask: Task<Void, Error>?
    private var setExposureBiasTask: Task<Void, Error>?
    
    init() {
        bind()
    }
    
    private func bind() {
        $onboardingStage
            .filter { $0 == .ready }
            .sink { [weak self] _ in
                Task { await self?.setupSession() }
                self?.setupTutorialIfNeeded()
            }
            .store(in: &cancellables)
    }
    
    private func setupSession() async {
        sessionCancellables = []
        
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
            .filter { $0 }
            .map { _ in false }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isFocusLocking)
        
        Publishers.CombineLatest3(
            camera.focusLockPoint,
            $isFocusLocking,
            camera.isFocusLocked
        )
        .debounce(for: .seconds(1.5), scheduler: DispatchQueue.main)
        .filter { !$1 && !$2 }
        .map { _ in nil }
        .receive(on: DispatchQueue.main)
        .assign(to: &$focusLockPoint)
        
        Publishers.CombineLatest(
            camera.focusLockPoint,
            camera.isFocusLocked
        )
        .debounce(for: .seconds(1.5), scheduler: DispatchQueue.main)
        .filter { $1 }
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
        
        Publishers.CombineLatest3($tutorialStage, camera.exposureOffset.removeDuplicates(), $exposureBias)
            .filter { $0.0.hasReached(.done) }
            .map { $1 - $2 }
            .map { offset in
                if abs(offset) < 2 {
                    return .correctExposure
                } else if offset < 0 {
                    return .underExposure
                } else {
                    return .overExposure
                }
            }
            .removeDuplicates()
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .assign(to: &$exposureState)
        
        camera.zoomFactor
            .map { Float($0) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$zoomFactor)
        
        Publishers.CombineLatest4($frameRate, $exposureBias, camera.exposureValue, camera.aperture)
            .sink { [weak self] frameRate, exposureBias, exposureValue, apertureValue in
                self?.setFrameRate(frameRate, exposureValue: exposureValue - exposureBias, apertureValue: apertureValue)
            }
            .store(in: &sessionCancellables)
        
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
        .store(in: &sessionCancellables)
        
        MotionManager.shared.motionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] motion in
                self?.updateLevel(motion)
                self?.updateOrientationIfNeeded(motion)
            }
            .store(in: &sessionCancellables)
    }
    
    private func setupTutorialIfNeeded() {
        tutorialCancellables = []
        
        guard tutorialStage != .done else { return }
        
        Publishers.CombineLatest($tutorialStage, $frameRate)
            .filter { $0 == .fps && $1 == 4 }
            .first()
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                tutorialStage = .shutterAngle
            }
            .store(in: &tutorialCancellables)
        
        Publishers.CombineLatest($tutorialStage, $shutterAngle)
            .filter { $0 == .shutterAngle && $1 == 360 }
            .first()
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                tutorialStage = .exposureBias
            }
            .store(in: &tutorialCancellables)
        
        Publishers.CombineLatest($tutorialStage, $exposureBias)
            .filter { $0 == .exposureBias && $1 == -2.0 }
            .first()
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                tutorialStage = .exposure
            }
            .store(in: &tutorialCancellables)
        
        $tutorialStage.filter { $0 == .exposure }
            .first()
            .delay(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                exposureState = .underExposure
            }
            .store(in: &tutorialCancellables)
    
        $tutorialStage.filter { $0 == .exposure }
            .first()
            .delay(for: .seconds(3.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                frameRate = 8
                shutterAngle = 180
                exposureBias = .zero
            }
            .store(in: &tutorialCancellables)
        
            $tutorialStage.filter { $0 == .exposure }
                .first()
                .delay(for: .seconds(4), scheduler: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let self else { return }
                    exposureState = .correctExposure
                }
                .store(in: &tutorialCancellables)
        
        $tutorialStage.filter { $0 == .exposure }
            .first()
            .delay(for: .seconds(5.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                tutorialStage = .zoom
            }
            .store(in: &tutorialCancellables)
        
        Publishers.CombineLatest($tutorialStage, $zoomFactor)
            .filter { $0 == .zoom && $1 >= 2 }
            .first()
            .delay(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                tutorialStage = .focus
            }
            .store(in: &tutorialCancellables)
        
        Publishers.CombineLatest($tutorialStage, $focusLockPoint)
            .filter { $0 == .focus && $1 != nil }
            .first()
            .delay(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                tutorialStage = .selfie
            }
            .store(in: &tutorialCancellables)
        
        Publishers.CombineLatest($tutorialStage, camera.isFrontFacing)
            .filter { $0 == .selfie && $1 == true }
            .first()
            .delay(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                tutorialStage = .record
            }
            .store(in: &tutorialCancellables)
        
        Publishers.CombineLatest($tutorialStage, $isCapturing)
            .filter { $0 == .record && $1 == true }
            .first()
            .sink { [weak self] _ in
                guard let self else { return }
                tutorialStage = .done
            }
            .store(in: &tutorialCancellables)
        
        
        $tutorialStage.filter { $0 == .record }
            .first()
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                tutorialStage = .done
            }
            .store(in: &tutorialCancellables)
    }
    
    private func updateLevel(_ motion: Motion) {
        let level: Level
        if 45 >= abs(motion.roll), 45 >= abs(motion.pitch) {
            level = .floor(roll: motion.roll, pitch: motion.pitch)
        } else if 135 < abs(motion.roll), 45 >= abs(motion.pitch) {
            level = .sky(roll: motion.roll, pitch: motion.pitch)
        } else {
            if (-45..<45) ~= motion.rotation {
                level = .portrait(angle: motion.rotation)
            } else if (45..<135) ~= motion.rotation {
                level = .landscapeRight(angle: motion.rotation)
            } else if (-135 ..< -45) ~= motion.rotation {
                level = .landscapeLeft(angle: motion.rotation)
            } else {
                level = .portraitUpsideDown(angle: motion.rotation)
            }
        }
        self.level = level
    }
    
    private func updateOrientationIfNeeded(_ motion: Motion) {
        guard isCapturing == false, level.isSurface == false else { return }
        let orientation: Orientation
        if (-45..<45) ~= motion.rotation {
            orientation = .portrait
        } else if (45..<135) ~= motion.rotation {
            orientation = .landscapeRight
        } else if (-135 ..< -45) ~= motion.rotation {
            orientation = .landscapeLeft
        } else {
            orientation = .portraitUpsideDown
        }
        self.orientation = orientation
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
        guard tutorialStage.hasReached(.selfie) else { return }
        try? camera.switchCamera()
    }
    
    func didTapShutter() {
        guard tutorialStage.hasReached(.record) else { return }
        Task {
            do {
                if isCapturing, let result = try await camera.stopRecordVideo(), let videoPath = result.videoPath {
                    let url = URL.homeDirectory.appending(path: videoPath)
                    try await PhotoLibrary.save(video: url)
                    try FileManager.default.removeItem(at: url)
                } else {
                    try camera.startRecordVideo(
                        orientation: orientation.obscuraCameraOrientation,
                        allowHapticsAndSystemSounds: true
                    )
                }
            } catch {
                print(error)
            }
        }
    }
    
    func didTapScreen(on position: CGPoint) {
        guard tutorialStage.hasReached(.focus) else { return }
        Task {
            do {
                isFocusLocking = false
                try camera.adjustFocus(on: position)
            }
        }
    }
    
    func didDoubleTapScreen(on position: CGPoint) {
        guard tutorialStage.hasReached(.focus) else { return }
        Task {
            do {
                try camera.lockFocus(on: position)
                isFocusLocking = true
            }
        }
    }
    
    func didTapUnlock() {
        Task {
            isFocusLocking = false
            try camera.unlockFocus()
        }
    }
}

extension Orientation {
    var obscuraCameraOrientation: ObscuraCamera.Orientation {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        }
    }
}
