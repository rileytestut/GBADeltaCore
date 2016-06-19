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
    public override class func defaultControllerSkinForGameUTI(_ UTI: String) -> ControllerSkin?
    {
        let URL = Bundle(for: self).urlForResource("Default", withExtension: "deltaskin")
        let controllerSkin = ControllerSkin(URL: URL!)
        
        return controllerSkin
    }
    
    public override func inputsForItem(_ item: ControllerSkin.Item, point: CGPoint) -> [InputType]
    {
        var inputs: [InputType] = []
        
        for key in item.keys
        {
            switch key
            {
            case "dpad":
                
                let topRect = CGRect(x: item.frame.minX, y: item.frame.minY, width: item.frame.width, height: item.frame.height / 3.0)
                let bottomRect = CGRect(x: item.frame.minX, y: item.frame.maxY - item.frame.height / 3.0, width: item.frame.width, height: item.frame.height / 3.0)
                let leftRect = CGRect(x: item.frame.minX, y: item.frame.minY, width: item.frame.width / 3.0, height: item.frame.height)
                let rightRect = CGRect(x: item.frame.maxX - item.frame.width / 3.0, y: item.frame.minY, width: item.frame.width / 3.0, height: item.frame.height)
                
                if topRect.contains(point)
                {
                    inputs.append(GBAGameInput.up)
                }
                
                if bottomRect.contains(point)
                {
                    inputs.append(GBAGameInput.down)
                }
                
                if leftRect.contains(point)
                {
                    inputs.append(GBAGameInput.left)
                }
                
                if rightRect.contains(point)
                {
                    inputs.append(GBAGameInput.right)
                }
                
            case "a": inputs.append(GBAGameInput.a)
            case "b": inputs.append(GBAGameInput.b)
            case "l": inputs.append(GBAGameInput.l)
            case "r": inputs.append(GBAGameInput.r)
            case "start": inputs.append(GBAGameInput.start)
            case "select": inputs.append(GBAGameInput.select)
            case "menu": inputs.append(ControllerInput.menu)
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
