//
//  GBAEmulatorConfiguration.swift
//  GBADeltaCore
//
//  Created by Riley Testut on 7/8/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import Foundation
import AVFoundation

import DeltaCore

public struct GBAEmulatorConfiguration: EmulatorConfiguration
{
    public let gameSaveFileExtension: String = "sav"
    
    public var audioBufferInfo: AudioManager.BufferInfo {
        let inputFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 32768, channels: 2, interleaved: true)
        
        let bufferInfo = AudioManager.BufferInfo(inputFormat: inputFormat, preferredSize: 2184)
        return bufferInfo
    }
    
    public var videoBufferInfo: VideoManager.BufferInfo {
        let bufferInfo = VideoManager.BufferInfo(format: .bgra8, dimensions: CGSize(width: 240, height: 160))
        return bufferInfo
    }
    
    public var supportedCheatFormats: [CheatFormat] {
        let actionReplayFormat = CheatFormat(name: NSLocalizedString("Action Replay", comment: ""), format: "XXXXXXXX YYYYYYYY", type: .actionReplay)
        let gameSharkFormat = CheatFormat(name: NSLocalizedString("GameShark", comment: ""), format: "XXXXXXXX YYYYYYYY", type: .gameShark)
        let codeBreakerFormat = CheatFormat(name: NSLocalizedString("Code Breaker", comment: ""), format: "XXXXXXXX YYYY", type: .codeBreaker)
        return [actionReplayFormat, gameSharkFormat, codeBreakerFormat]
    }
    
    public let supportedRates: ClosedRange<Double> = 1...3
}
