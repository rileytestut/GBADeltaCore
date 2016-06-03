//
//  GBAControllerSkin.swift
//  GBADeltaCore
//
//  Created by Riley Testut on 6/3/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import Foundation

import DeltaCore

public class GBAControllerSkin: ControllerSkin
{
    //MARK: - Overrides -
    /** Overrides **/
    
    //MARK: - ControllerSkin
    /// ControllerSkin
    public override class func defaultControllerSkinForGameUTI(UTI: String) -> ControllerSkin?
    {
        let URL = NSBundle(forClass: self).URLForResource("Default", withExtension: "deltaskin")
        let controllerSkin = ControllerSkin(URL: URL!)
        
        return controllerSkin
    }
    
    public override func inputsForItem(item: ControllerSkin.Item, point: CGPoint) -> [InputType]
    {
        var inputs: [InputType] = []
        
        for key in item.keys
        {
            switch key
            {
            case "menu": inputs.append(ControllerInput.Menu)
            default: break
            }
        }
        
        return inputs
    }
    
    //MARK: - DynamicObject
    /// DynamicObject
    public override class func isDynamicSubclass() -> Bool
    {
        return true
    }
    
    public override class func dynamicIdentifier() -> String?
    {
        return kUTTypeGBAGame as String;
    }
}