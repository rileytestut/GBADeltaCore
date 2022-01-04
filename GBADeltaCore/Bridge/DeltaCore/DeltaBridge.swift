//
//  File.swift
//  
//
//  Created by Riley Testut on 12/6/21.
//

import Foundation
import GBABridgeJS

import Foundation
import WebKit
import DeltaCore

extension RunLoop
{
    func run(until condition: () -> Bool)
    {
        while !condition()
        {
            self.run(mode: RunLoop.Mode.default, before: .distantFuture)
        }
    }
}

extension WKWebView
{
    @discardableResult func evaluateJavaScriptSynchronously(_ javaScriptString: String) throws -> Any?
    {
        var finished = false
        
        var finishedResult: Any?
        var finishedError: Error?
        
        func evaluate()
        {
            self.evaluateJavaScript(javaScriptString) { (result, error) in
                finishedResult = result
                finishedError = error
                
                finished = true
            }
            
            RunLoop.current.run(until: { finished })
        }
        
        if Thread.isMainThread
        {
            evaluate()
        }
        else
        {
            DispatchQueue.main.sync {
                evaluate()
            }
        }
        
        if let error = finishedError
        {
            throw error
        }
        
        return finishedResult
    }
}

class JSEmulatorBridge: NSObject, EmulatorBridging
{
    private(set) var gameURL: URL?
    
    var audioRenderer: AudioRendering?
    var videoRenderer: VideoRendering?
    
    var saveUpdateHandler: (() -> Void)?
    
    private let prefix: String
    private let webView: WKWebView
    
    var frameDuration: TimeInterval {
        do
        {
            let frameDuration = try self.webView.evaluateJavaScriptSynchronously("_\(self.prefix)FrameDuration()") as! TimeInterval
            return frameDuration
        }
        catch
        {
            print("Error retrieving frame duration.", error)
            return (1.0 / 60.0)
        }
    }
    
    init(prefix: String)
    {
        self.prefix = prefix
        self.webView = WKWebView(frame: .zero)
        
        super.init()
    }
    
    func start(withGameURL gameURL: URL)
    {
        do
        {
            let path = gameURL.lastPathComponent
            try self.importFile(at: gameURL, to: path)
            
            let script = "Module.ccall('\(self.prefix)StartEmulation', null, ['string'], ['\(path)'])"
            let result = try self.webView.evaluateJavaScriptSynchronously(script) as! Bool
            
            guard result else {
                print("Error launching game at", gameURL)
                return
            }
            
            self.gameURL = gameURL
        }
        catch
        {
            print("Error starting game (JS):", error)
        }
    }
    
    func pause()
    {
    }
    
    func resume()
    {
    }
    
    func stop()
    {
        do
        {
            try self.webView.evaluateJavaScriptSynchronously("_\(self.prefix)StopEmulation()")
        }
        catch
        {
            print("Error stopping game (JS):", error)
        }
    }
    
    func runFrame(processVideo: Bool)
    {
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript("_\(self.prefix)RunFrame()") { (result, error) in
                if let error = error
                {
                    print("Error running frame:", error)
                }
            }
        }
    }
    
    func activateInput(_ input: Int, value: Double)
    {
        do
        {
            try self.webView.evaluateJavaScriptSynchronously("_\(self.prefix)ActivateInput(\(input))")
        }
        catch
        {
            print("Error activating input: \(input).", error)
        }
    }
    
    func deactivateInput(_ input: Int)
    {
        do
        {
            try self.webView.evaluateJavaScriptSynchronously("_\(self.prefix)DeactivateInput(\(input))")
        }
        catch
        {
            print("Error deactivating input: \(input).", error)
        }
    }
    
    func resetInputs()
    {
    }
    
    func saveSaveState(to fileURL: URL)
    {
        do
        {
            let script = "Module.ccall('\(self.prefix)SaveSaveState', null, ['string'], ['\(fileURL.lastPathComponent)'])"
            try self.webView.evaluateJavaScriptSynchronously(script)
            
            try self.exportFile(at: fileURL.lastPathComponent, to: fileURL)
        }
        catch
        {
            print("Error saving save state:", error)
        }
    }
    
    func loadSaveState(from fileURL: URL)
    {
        do
        {
            try self.importFile(at: fileURL, to: fileURL.lastPathComponent)

            let script = "Module.ccall('\(self.prefix)LoadSaveState', null, ['string'], ['\(fileURL.lastPathComponent)'])"
            try self.webView.evaluateJavaScriptSynchronously(script)
        }
        catch
        {
            print("Error loading save state:", error)
        }
    }
    
    func saveGameSave(to fileURL: URL)
    {
        do
        {
            let script = "Module.ccall('\(self.prefix)SaveGameSave', null, ['string'], ['\(fileURL.lastPathComponent)'])"
            try self.webView.evaluateJavaScriptSynchronously(script)

            try self.exportFile(at: fileURL.lastPathComponent, to: fileURL)
        }
        catch
        {
            print("Error saving game save:", error)
        }
    }
    
    func loadGameSave(from fileURL: URL)
    {
        do
        {
            try self.importFile(at: fileURL, to: fileURL.lastPathComponent)

            let script = "Module.ccall('\(self.prefix)LoadGameSave', null, ['string'], ['\(fileURL.lastPathComponent)'])"
            try self.webView.evaluateJavaScriptSynchronously(script)
        }
        catch
        {
            print("Error loading game save:", error)
        }
    }
    
    func addCheatCode(_ cheatCode: String, type: String) -> Bool
    {
        do
        {
            let script = "Module.ccall('\(self.prefix)AddCheatCode', null, ['string'], ['\(cheatCode)'])"
            try self.webView.evaluateJavaScriptSynchronously(script)
            
            return true
        }
        catch
        {
            print("Error adding cheat code: \(cheatCode).", error)
            
            return false
        }
    }
    
    func resetCheats()
    {
        do
        {
            try self.webView.evaluateJavaScriptSynchronously("_\(self.prefix)ResetCheats()")
        }
        catch
        {
            print("Error resetting cheats:", error)
        }
    }
    
    func updateCheats()
    {
    }
}

private extension JSEmulatorBridge
{
    func importFile(at fileURL: URL, to path: String) throws
    {
        let data = try Data(contentsOf: fileURL)
        let bytes = data.map { $0 }
        
        let script = """
        var data = Uint8Array.from(\(bytes));
        FS.writeFile('\(path)', data);
        """
        
        try self.webView.evaluateJavaScriptSynchronously(script)
    }
    
    func exportFile(at path: String, to fileURL: URL) throws
    {
        let script = """
        var bytes = FS.readFile('\(path)');
        Array.from(bytes);
        """
        
        let bytes = try self.webView.evaluateJavaScriptSynchronously(script) as! [UInt8]
        
        let data = Data(bytes)
        try data.write(to: fileURL)
    }
}
