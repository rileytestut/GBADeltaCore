//
//  GBADeltaCore.h
//  GBADeltaCore
//
//  Created by Riley Testut on 6/2/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DeltaCore/DeltaCore.h>

//! Project version number for GBADeltaCore.
FOUNDATION_EXPORT double GBADeltaCoreVersionNumber;

//! Project version string for GBADeltaCore.
FOUNDATION_EXPORT const unsigned char GBADeltaCoreVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <GBADeltaCore/PublicHeader.h>
#import <GBADeltaCore/GBAEmulatorBridge.h>

// Extensible Enums
FOUNDATION_EXPORT CheatType const CheatTypeActionReplay;
FOUNDATION_EXPORT CheatType const CheatTypeGameShark;
FOUNDATION_EXPORT CheatType const CheatTypeCodeBreaker;

FOUNDATION_EXPORT NSNotificationName const GBADidActivateGyroNotification NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT NSNotificationName const GBADidDeactivateGyroNotification NS_REFINED_FOR_SWIFT;
