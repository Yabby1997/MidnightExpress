//
//  VideoView.swift
//  MidnightExp
//
//  Created by Seunghun on 2/10/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import AVFoundation
import SwiftUI

struct VideoView: UIViewRepresentable {
    private final class _VideoView: UIView {
        private let playerLayer: AVPlayerLayer
        
        init(playerLayer: AVPlayerLayer) {
            self.playerLayer = playerLayer
            super.init(frame: .zero)
            setupLayer()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            playerLayer.frame = layer.bounds
        }
        
        private func setupLayer() {
            playerLayer.videoGravity = .resizeAspectFill
            layer.addSublayer(playerLayer)
        }
    }
    
    private let playerLayer: AVPlayerLayer

    init(playerLayer: AVPlayerLayer) {
        self.playerLayer = playerLayer
    }
    
    func makeUIView(context: Context) -> some UIView {
        _VideoView(playerLayer: playerLayer)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
