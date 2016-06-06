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
            case "dpad":
                
                let topRect = CGRect(x: item.frame.minX, y: item.frame.minY, width: item.frame.width, height: item.frame.height / 3.0)
                let bottomRect = CGRect(x: item.frame.minX, y: item.frame.maxY - item.frame.height / 3.0, width: item.frame.width, height: item.frame.height / 3.0)
                let leftRect = CGRect(x: item.frame.minX, y: item.frame.minY, width: item.frame.width / 3.0, height: item.frame.height)
                let rightRect = CGRect(x: item.frame.maxX - item.frame.width / 3.0, y: item.frame.minY, width: item.frame.width / 3.0, height: item.frame.height)
                
                if CGRectContainsPoint(topRect, point)
                {
                    inputs.append(GBAGameInput.Up)
                }
                
                if CGRectContainsPoint(bottomRect, point)
                {
                    inputs.append(GBAGameInput.Down)
                }
                
                if CGRectContainsPoint(leftRect, point)
                {
                    inputs.append(GBAGameInput.Left)
                }
                
                if CGRectContainsPoint(rightRect, point)
                {
                    inputs.append(GBAGameInput.Right)
                }
                
            case "a": inputs.append(GBAGameInput.A)
            case "b": inputs.append(GBAGameInput.B)
            case "l": inputs.append(GBAGameInput.L)
            case "r": inputs.append(GBAGameInput.R)
            case "start": inputs.append(GBAGameInput.Start)
            case "select": inputs.append(GBAGameInput.Select)
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