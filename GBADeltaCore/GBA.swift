//
//  GBA.swift
//  GBADeltaCore
//
//  Created by Riley Testut on 6/3/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import Foundation
import AVFoundation

import DeltaCore

public extension GameType
{
    public static let gba = GameType("com.rileytestut.delta.game.gba")
}

public struct GBA: DeltaCoreProtocol
{
    public static let core = GBA()
    
    public let gameType = GameType.gba
    
    public let bundleIdentifier: String = "com.rileytestut.GBADeltaCore"
    
    public let gameSaveFileExtension: String = "sav"
    
    public let frameDuration = (1.0 / 60.0)
    
    public let supportedRates: ClosedRange<Double> = 1...3
    
    public let supportedCheatFormats: [CheatFormat] = {
        let actionReplayFormat = CheatFormat(name: NSLocalizedString("Action Replay", comment: ""), format: "XXXXXXXX YYYYYYYY", type: .actionReplay)
        let gameSharkFormat = CheatFormat(name: NSLocalizedString("GameShark", comment: ""), format: "XXXXXXXX YYYYYYYY", type: .gameShark)
        let codeBreakerFormat = CheatFormat(name: NSLocalizedString("Code Breaker", comment: ""), format: "XXXXXXXX YYYY", type: .codeBreaker)
        return [actionReplayFormat, gameSharkFormat, codeBreakerFormat]
    }()
    
    public let audioFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 32768, channels: 2, interleaved: true)
    
    public let videoFormat = VideoFormat(pixelFormat: .bgra8, dimensions: CGSize(width: 240, height: 160))
    
    public let emulatorBridge: EmulatorBridging = GBAEmulatorBridge.shared
    
    public let inputTransformer: InputTransforming = GBAInputTransformer()
    
    private init()
    {
    }
    
}
