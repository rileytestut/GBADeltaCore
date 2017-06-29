//
//  GBAInputTransformer.swift
//  GBADeltaCore
//
//  Created by Riley Testut on 7/8/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import Foundation

import DeltaCore

@objc public enum GBAGameInput: Int, Input
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

public struct GBAInputTransformer: InputTransforming
{
    public var gameInputType: Input.Type = GBAGameInput.self
    
    public func inputs(for controllerSkin: ControllerSkin, item: ControllerSkin.Item, point: CGPoint) -> [Input]
    {
        var inputs: [Input] = []
        
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
    
    public func inputs(for controller: MFiGameController, input: MFiGameController.Input) -> [Input]
    {
        var inputs: [GBAGameInput] = []
        
        switch input
        {
        case let .dPad(xAxis: xAxis, yAxis: yAxis): inputs.append(contentsOf: self.inputs(forXAxis: xAxis, YAxis: yAxis))
        case let .leftThumbstick(xAxis: xAxis, yAxis: yAxis): inputs.append(contentsOf: self.inputs(forXAxis: xAxis, YAxis: yAxis))
        case .rightThumbstick(xAxis: _, yAxis: _): break
        case .a: inputs.append(.a)
        case .b: inputs.append(.b)
        case .x: inputs.append(.select)
        case .y: inputs.append(.start)
        case .l: inputs.append(.l)
        case .r: inputs.append(.r)
        case .leftTrigger: inputs.append(.l)
        case .rightTrigger: inputs.append(.r)
        }
        
        return inputs
    }
}

private extension GBAInputTransformer
{
    func inputs(forXAxis xAxis: Float, YAxis yAxis: Float) -> [GBAGameInput]
    {
        var inputs: [GBAGameInput] = []
        
        if xAxis > 0.0
        {
            inputs.append(.right)
        }
        else if xAxis < 0.0
        {
            inputs.append(.left)
        }
        
        if yAxis > 0.0
        {
            inputs.append(.up)
        }
        else if yAxis < 0.0
        {
            inputs.append(.down)
        }
        
        return inputs
    }
}
