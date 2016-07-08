//
//  GBA.swift
//  GBADeltaCore
//
//  Created by Riley Testut on 6/3/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import Foundation

public extension GameType
{
    public static let gba = "com.rileytestut.delta.game.gba" as GameType
}

public struct GBA: DeltaCoreProtocol
{
    public static let core = GBA()
    
    public let bundleIdentifier: String = "com.rileytestut.GBADeltaCore"
    
    public let supportedGameTypes: Set<GameType> = [.gba]
    
    public let emulatorBridge: EmulatorBridging = GBAEmulatorBridge.shared
    
    public let emulatorConfiguration: EmulatorConfiguration = GBAEmulatorConfiguration()
    
    public let inputTransformer: InputTransforming = GBAInputTransformer()
    
    private init()
    {
    }
    
}
