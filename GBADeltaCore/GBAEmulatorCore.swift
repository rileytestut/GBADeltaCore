//
//  GBAEmulatorCore.swift
//  GBADeltaCore
//
//  Created by Riley Testut on 6/3/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import Foundation
import AVFoundation

import DeltaCore

@objc public enum GBAGameInput: Int, InputType
{
    case up = 64
    case down = 128
    case left = 32
    case right = 16
    case a = 1
    case b = 2
    case l = 512
    case r = 256
    case start = 8
    case select = 4
}

public class GBAEmulatorCore: EmulatorCore
{
    public required init(game: GameType)
    {
        super.init(game: game)
    }
    
    //MARK: - DynamicObject
    /// DynamicObject
    public override class func isDynamicSubclass() -> Bool
    {
        return true
    }
    
    public override class func dynamicIdentifier() -> String?
    {
        return kUTTypeGBAGame as String
    }
    
    //MARK: - Overrides -
    /** Overrides **/
    
    override public var bridge: DLTAEmulatorBridge
    {
        return GBAEmulatorBridge.shared()
    }
    
    public override var gameInputType: InputType.Type
    {
        return GBAGameInput.self
    }
    
    public override var gameSaveURL: URL
    {
        do
        {
            var gameSaveURL = self.game.fileURL
            try gameSaveURL.deletePathExtension()
            try gameSaveURL.appendPathComponent("sav")
            return gameSaveURL
        }
        catch let error as NSError
        {
            print(error)
            return self.game.fileURL
        }
    }
    
    override public var audioBufferInfo: AudioManager.BufferInfo
    {
        let inputFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 32768, channels: 2, interleaved: true)
        
        let bufferInfo = AudioManager.BufferInfo(inputFormat: inputFormat, preferredSize: 2184)
        return bufferInfo
    }
    
    override public var videoBufferInfo: VideoManager.BufferInfo
    {        
        let bufferInfo = VideoManager.BufferInfo(inputFormat: .bgra8, inputDimensions: CGSize(width: 240, height: 160), outputDimensions: CGSize(width: 240, height: 160))
        return bufferInfo
    }
    
    override public var supportedCheatFormats: [CheatFormat]
    {
        let actionReplayFormat = CheatFormat(name: NSLocalizedString("Action Replay", comment: ""), format: "XXXXXXXX YYYYYYYY", type: .actionReplay)
        let gameSharkFormat = CheatFormat(name: NSLocalizedString("GameShark", comment: ""), format: "XXXXXXXX YYYYYYYY", type: .gameShark)
        let codeBreakerFormat = CheatFormat(name: NSLocalizedString("Code Breaker", comment: ""), format: "XXXXXXXX YYYY", type: .codeBreaker)
        return [actionReplayFormat, gameSharkFormat, codeBreakerFormat]
    }
    
    override public var supportedRates: ClosedRange<Double>
    {
        return 1...3
    }
}
