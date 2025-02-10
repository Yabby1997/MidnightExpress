//
//  OnboardingViewModel.swift
//  MidnightExp
//
//  Created by Seunghun on 2/11/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import AVFoundation
import Combine
import Foundation

final class OnboardingViewModel: ObservableObject {
    private let player = AVPlayer()
    let playerLayer: AVPlayerLayer
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.playerLayer = AVPlayerLayer()
        playerLayer.player = player
        bind()
    }
    
    private func bind() {
        NotificationCenter.default.publisher(for: AVPlayerItem.didPlayToEndTimeNotification)
            .compactMap { $0.object as? AVPlayerItem }
            .filter { [weak self] item in self?.player.currentItem == item }
            .sink { [weak self] _ in
                self?.resetPlayer()
            }
            .store(in: &cancellables)
    }
    
    private func resetPlayer() {
        player.seek(to: .zero)
        player.play()
    }
    
    func onAppear() {
        guard let path = Bundle.main.path(forResource: "onboarding", ofType: "mov") else { return }
        player.replaceCurrentItem(with: AVPlayerItem(url: URL(fileURLWithPath: path)))
        player.volume = .zero
        player.play()
    }
}
