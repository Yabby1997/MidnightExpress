//
//  MidnightExpressRecorder.swift
//  MidnightExpDev
//
//  Created by Seunghun on 12/26/24.
//  Copyright © 2024 seunghun. All rights reserved.
//

import AVFoundation
import Foundation
import Obscura

protocol MidnightExpressRecorderDelegate: AnyObject {
    func didCaptureFrame(_ midnightExpressRecorder: MidnightExpressRecorder)
    func midnightExpressRecorder(_ midnightExpressRecorder: MidnightExpressRecorder, didSaveOutputAt url: URL)
}

final class MidnightExpressRecorder: NSObject {
    private weak var delegate: MidnightExpressRecorderDelegate?
    private var isRecording = false
    private var startTime: CMTime?
    private var assetWriter: AVAssetWriter
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?
    private var startContinuation: CheckedContinuation<Void, Never>?
    
    init?(baseURL: URL, delegate: MidnightExpressRecorderDelegate) {
        let outputURL = baseURL.appending(path: UUID().uuidString + ".mov")
        guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mov) else { return nil }
        self.assetWriter = assetWriter
        self.delegate = delegate
    }
    
    private func startRecordingIfNeeded(using sampleBuffer: CMSampleBuffer) {
        guard isRecording == false, videoInput != nil, audioInput != nil else { return }
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        startContinuation?.resume()
        isRecording = true
    }
    
    private func setupVideoInputIfNeeded(using sampleBuffer: CMSampleBuffer) {
        guard videoInput == nil, let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
        let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
        let assetWriterVideoInput = AVAssetWriterInput(
            mediaType: .video,
            outputSettings: [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: Int(dimensions.width),
                AVVideoHeightKey: Int(dimensions.height)
            ]
        )
        assetWriterVideoInput.expectsMediaDataInRealTime = true
        guard assetWriter.canAdd(assetWriterVideoInput) else { return }
        assetWriter.add(assetWriterVideoInput)
        
        self.videoInput = assetWriterVideoInput
    }
    
    private func writeVideoIfPossible(sampleBuffer: CMSampleBuffer) {
        guard assetWriter.status == .writing, let videoInput, videoInput.isReadyForMoreMediaData else { return }
        videoInput.append(sampleBuffer)
        delegate?.didCaptureFrame(self)
    }
    
    private func setupAudioInputIfNeeded(using sampleBuffer: CMSampleBuffer) {
        guard audioInput == nil, let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer),
              let audioStreamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription) else { return }
        let assetWriterAudioInput = AVAssetWriterInput(
            mediaType: .audio,
            outputSettings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVNumberOfChannelsKey: Int(audioStreamBasicDescription.pointee.mChannelsPerFrame),
                AVSampleRateKey: audioStreamBasicDescription.pointee.mSampleRate,
                AVEncoderBitRateKey: 128000
            ]
        )
        assetWriterAudioInput.expectsMediaDataInRealTime = true
        guard assetWriter.canAdd(assetWriterAudioInput) else { return }
        assetWriter.add(assetWriterAudioInput)
        
        self.audioInput = assetWriterAudioInput
    }
    
    private func writeAudioIfPossible(sampleBuffer: CMSampleBuffer) {
        guard assetWriter.status == .writing, let audioInput, audioInput.isReadyForMoreMediaData else { return }
        audioInput.append(sampleBuffer)
    }
}

extension MidnightExpressRecorder: ObscuraRecordable {
    func prepareForStart() async {
        guard isRecording == false else { return }
        await withCheckedContinuation { startContinuation = $0 }
    }
    
    func prepareForStop() async {
        guard isRecording else { return }
        videoInput?.markAsFinished()
        audioInput?.markAsFinished()
        await withCheckedContinuation { continuation in
            assetWriter.finishWriting { continuation.resume() }
        }
        delegate?.midnightExpressRecorder(self, didSaveOutputAt: assetWriter.outputURL)
    }
    
    func record(video sampleBuffer: CMSampleBuffer) {
        startRecordingIfNeeded(using: sampleBuffer)
        setupVideoInputIfNeeded(using: sampleBuffer)
        writeVideoIfPossible(sampleBuffer: sampleBuffer)
    }

    func record(audio sampleBuffer: CMSampleBuffer) {
        startRecordingIfNeeded(using: sampleBuffer)
        setupAudioInputIfNeeded(using: sampleBuffer)
        writeAudioIfPossible(sampleBuffer: sampleBuffer)
    }
}
