//
//  GBAEmulatorBridge.swift
//  GBADeltaCore
//
//  Created by Riley Testut on 12/3/21.
//  Copyright © 2021 Riley Testut. All rights reserved.
//

import Foundation
import DeltaCore

#if !SWIFT_PACKAGE
import GBABridge
#endif

class GBAEmulatorBridge: AdaptableDeltaBridge
{
    public static let shared = GBAEmulatorBridge()
    
    public override var adapter: EmulatorBridging {
#if SWIFT_PACKAGE
        let scriptURL = Bundle.module.url(forResource: "vbam", withExtension: "html")!
        
        let adapter = JSCoreAdapter(prefix: "GBA", fileURL: scriptURL)
        adapter.emulatorCore = self.emulatorCore
        return adapter
#else
        return NativeCoreAdapter(
            frameDuration: GBAFrameDuration,
            start: GBAStartEmulation,
            stop: GBAStopEmulation,
            pause: GBAPauseEmulation,
            resume: GBAResumeEmulation,
            runFrame: GBARunFrame,
            activateInput: GBAActivateInput,
            deactivateInput: GBADeactivateInput,
            resetInputs: GBAResetInputs,
            saveSaveState: GBASaveSaveState,
            loadSaveState: GBALoadSaveState,
            saveGameSave: GBASaveGameSave,
            loadGameSave: GBALoadGameSave,
            addCheatCode: GBAAddCheatCode,
            resetCheats: GBAResetCheats,
            updateCheats: GBAUpdateCheats,
            setAudioCallback: GBASetAudioCallback,
            setVideoCallback: GBASetVideoCallback,
            setSaveCallback: GBASetSaveCallback)
#endif
    }
}

//class GBADeltaBridge2: NSObject, EmulatorBridging
//{
//    var gameURL: URL?
//
//    var audioRenderer: AudioRendering?
//    var videoRenderer: VideoRendering?
//
//    var saveUpdateHandler: (() -> Void)?
//
//    #if SWIFT_PACKAGE
//
//    var frameDuration: TimeInterval { fatalError() }
//
//    func start(withGameURL gameURL: URL)
//    {
//        fatalError()
//    }
//
//    func stop() { fatalError() }
//    func pause() {}
//    func resume() {}
//
//    func runFrame(processVideo: Bool) { fatalError() }
//
//    func activateInput(_ input: Int, value: Double) { fatalError() }
//    func deactivateInput(_ input: Int) { fatalError() }
//    func resetInputs() { fatalError() }
//
//    func saveSaveState(to url: URL) { fatalError() }
//    func loadSaveState(from url: URL) { fatalError() }
//
//    func saveGameSave(to url: URL) { fatalError() }
//    func loadGameSave(from url: URL) { fatalError() }
//
//    func addCheatCode(_ cheatCode: String, type: String) -> Bool
//    {
//        fatalError()
//    }
//
//    func resetCheats() { fatalError() }
//    func updateCheats() {}
//
//    #else
//
//    var frameDuration: TimeInterval { GBAFrameDuration() }
//
//    func start(withGameURL gameURL: URL)
//    {
//        let result = gameURL.withUnsafeFileSystemRepresentation({ GBAStartEmulation($0!) })
//        print("Start game result:", result)
//        self.gameURL = gameURL
//    }
//
//    func stop() { GBAStopEmulation() }
//    func pause() {}
//    func resume() {}
//
//    func runFrame(processVideo: Bool) { GBARunFrame() }
//
//    func activateInput(_ input: Int, value: Double) { GBAActivateInput(Int32(input), value) }
//    func deactivateInput(_ input: Int) { GBADeactivateInput(Int32(input)) }
//    func resetInputs() { GBAResetInputs() }
//
//    func saveSaveState(to url: URL) { url.withUnsafeFileSystemRepresentation { GBASaveSaveState($0!) } }
//    func loadSaveState(from url: URL) { url.withUnsafeFileSystemRepresentation { GBALoadSaveState($0!) } }
//
//    func saveGameSave(to url: URL) { url.withUnsafeFileSystemRepresentation { GBASaveGameSave($0!) } }
//    func loadGameSave(from url: URL) { url.withUnsafeFileSystemRepresentation { GBALoadGameSave($0!) } }
//
//    func addCheatCode(_ cheatCode: String, type: String) -> Bool
//    {
//        cheatCode.withCString { cheatCode in
//            type.withCString { type in
//                GBAAddCheatCode(cheatCode, type)
//            }
//        }
//    }
//
//    func resetCheats() { GBAResetCheats() }
//    func updateCheats() {}
//
//    #endif
//}

//public class GBAEmulatorBridge: EmulatorBridge
//{
//    public static let shared = GBAEmulatorBridge()
//
//    private init()
//    {
//        super.init(bridge: GBADeltaBridge())
//
//        #if !SWIFT_PACKAGE
//        GBASetAudioCallback { (buffer, size) in
//            GBAEmulatorBridge.shared.audioRenderer?.audioBuffer.write(buffer, size: Int(size))
//        }
//
//        GBASetVideoCallback { (buffer, size) in
//            memcpy(UnsafeMutableRawPointer(GBAEmulatorBridge.shared.videoRenderer?.videoBuffer), buffer, Int(size))
//            GBAEmulatorBridge.shared.videoRenderer?.processFrame()
//        }
//
//        GBASetSaveCallback {
//            GBAEmulatorBridge.shared.saveUpdateHandler?()
//        }
//        #endif
//    }
//
//    public override func addCheatCode(_ cheatCode: String, type: String) -> Bool
//    {
//        // Parse cheat code
//        return true
//    }
//}
