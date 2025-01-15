//
//  PhotoLibrary.swift
//  MidnightExpDev
//
//  Created by Seunghun on 1/15/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import Foundation
import Photos

enum PhotoLibrary {
    enum Errors: Error {
        case notAuthorized
    }
    
    static func save(video url: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    continuation.resume(throwing: Errors.notAuthorized)
                    return
                }
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                } completionHandler: { _, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            }
        }
    }
}
