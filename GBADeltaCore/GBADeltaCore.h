//
//  GBADeltaCore.h
//  GBADeltaCore
//
//  Created by Riley Testut on 6/2/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for GBADeltaCore.
FOUNDATION_EXPORT double GBADeltaCoreVersionNumber;

//! Project version string for GBADeltaCore.
FOUNDATION_EXPORT const unsigned char GBADeltaCoreVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <GBADeltaCore/PublicHeader.h>
#if !STATIC_LIBRARY
#import <GBADeltaCore/GBAEmulatorBridge.h>
#import <GBADeltaCore/GBATypes.h>
#endif
