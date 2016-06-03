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
    
    override public var audioBufferInfo: AudioManager.BufferInfo
    {
        let inputFormat = AVAudioFormat(commonFormat: .PCMFormatInt16, sampleRate: 32768, channels: 2, interleaved: true)
        
        let bufferInfo = AudioManager.BufferInfo(inputFormat: inputFormat, preferredSize: 2132)
        return bufferInfo
    }
    
    override public var videoBufferInfo: VideoManager.BufferInfo
    {
        let bufferInfo = VideoManager.BufferInfo(inputFormat: .RGBA8, inputDimensions: CGSize(width: 240, height: 160), outputDimensions: CGSize(width: 240, height: 160))
        return bufferInfo
    }
    
    override public var preferredRenderingSize: CGSize
    {
        return CGSizeMake(240, 160)
    }
    
    override public var fastForwardRate: Float
    {
        return 4.0
    }
    
    //MARK: - EmulatorCore
    /// EmulatorCore
    public override func gameController(gameController: GameControllerProtocol, didActivateInput input: InputType)
    {
        
    }
    
    public override func gameController(gameController: GameControllerProtocol, didDeactivateInput input: InputType)
    {
        
    }
}