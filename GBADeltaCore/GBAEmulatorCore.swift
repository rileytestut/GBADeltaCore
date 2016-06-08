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

extension GBAGameInput: InputType {}

private extension GBACheatType
{
    init?(_ type: CheatType)
    {
        switch type
        {
        case .actionReplay: self = .ActionReplay
        case .gameShark: self = .GameShark
        case .codeBreaker: self = .CodeBreaker
        default: return nil
        }
    }
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
    
    override public var audioBufferInfo: AudioManager.BufferInfo
    {
        let inputFormat = AVAudioFormat(commonFormat: .PCMFormatInt16, sampleRate: 32768, channels: 2, interleaved: true)
        
        let bufferInfo = AudioManager.BufferInfo(inputFormat: inputFormat, preferredSize: 2184)
        return bufferInfo
    }
    
    override public var videoBufferInfo: VideoManager.BufferInfo
    {
        let bufferInfo = VideoManager.BufferInfo(inputFormat: .BGRA8, inputDimensions: CGSize(width: 240, height: 160), outputDimensions: CGSize(width: 240, height: 160))
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
    
    override public var supportedCheatFormats: [CheatFormat]
    {
        let actionReplayFormat = CheatFormat(name: NSLocalizedString("Action Replay", comment: ""), format: "XXXXXXXX YYYYYYYY", type: .actionReplay)
        let gameSharkFormat = CheatFormat(name: NSLocalizedString("GameShark", comment: ""), format: "XXXXXXXX YYYYYYYY", type: .gameShark)
        let codeBreakerFormat = CheatFormat(name: NSLocalizedString("Code Breaker", comment: ""), format: "XXXXXXXX YYYY", type: .codeBreaker)
        return [actionReplayFormat, gameSharkFormat, codeBreakerFormat]
    }
    
    public override func startEmulation() -> Bool
    {
        guard super.startEmulation() else { return false }
        
        GBAEmulatorBridge.sharedBridge().emulatorCore = self
        GBAEmulatorBridge.sharedBridge().audioRenderer = self.audioManager
        GBAEmulatorBridge.sharedBridge().videoRenderer = self.videoManager
        
        GBAEmulatorBridge.sharedBridge().startWithGameURL(self.game.fileURL)
        
        return true
    }
    
    public override func stopEmulation() -> Bool
    {
        guard super.stopEmulation() else { return false }
        
        GBAEmulatorBridge.sharedBridge().stop()
        
        return true
    }
    
    public override func pauseEmulation() -> Bool
    {
        guard super.pauseEmulation() else { return false }
        
        GBAEmulatorBridge.sharedBridge().pause()
        
        return true
    }
    
    public override func resumeEmulation() -> Bool
    {
        guard super.resumeEmulation() else { return false }
        
        GBAEmulatorBridge.sharedBridge().resume()
        
        return true
    }
    
    //MARK: - EmulatorCore
    /// EmulatorCore
    public override func gameController(gameController: GameControllerProtocol, didActivateInput input: InputType)
    {
        guard let input = input as? GBAGameInput else { return }
        
        GBAEmulatorBridge.sharedBridge().activateInput(input)
    }
    
    public override func gameController(gameController: GameControllerProtocol, didDeactivateInput input: InputType)
    {
        guard let input = input as? GBAGameInput else { return }
        
        GBAEmulatorBridge.sharedBridge().deactivateInput(input)
    }
    
    //MARK: - Save States -
    /// Save States
    public override func saveSaveState(completion: (SaveStateType -> Void)) -> Bool
    {
        guard super.saveSaveState(completion) else { return false }
        
        NSFileManager.defaultManager().prepareTemporaryURL { URL in
            
            GBAEmulatorBridge.sharedBridge().saveSaveStateToURL(URL)
            
            let name = self.timestampDateFormatter.stringFromDate(NSDate())
            let saveState = SaveState(name: name, fileURL: URL)
            completion(saveState)
        }
        
        return true
    }
    
    public override func loadSaveState(saveState: SaveStateType) -> Bool
    {
        guard super.loadSaveState(saveState) else { return false }
        
        GBAEmulatorBridge.sharedBridge().loadSaveStateFromURL(saveState.fileURL)
        
        return true
    }
    
    //MARK: - Cheats -
    /// Cheats
    public override func activateCheat(cheat: CheatProtocol) throws
    {
        guard let type = GBACheatType(cheat.type) else { throw CheatError.invalid }
        
        if !GBAEmulatorBridge.sharedBridge().activateCheat(cheat.code, type: type)
        {
            throw CheatError.invalid
        }
    }
    
    public override func deactivateCheat(cheat: CheatProtocol)
    {
        GBAEmulatorBridge.sharedBridge().deactivateCheat(cheat.code)
    }
}