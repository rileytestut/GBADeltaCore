//
//  GBARegistrationResponder.swift
//  GBADeltaCore
//
//  Created by Riley Testut on 7/8/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import Foundation

public class GBARegistrationResponder: NSObject
{
    public class func handleDeltaRegistrationRequest(_ notification: Notification)
    {
        guard let object = notification.object else { return }
        
        // unsafeBitCast needed for Swift Playground support
        let response = unsafeBitCast(object, to: Delta.RegistrationResponse.self)
        response.handler(GBA.core)
    }
}
