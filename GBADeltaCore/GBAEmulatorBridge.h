//
//  GBAEmulatorBridge.h
//  GBADeltaCore
//
//  Created by Riley Testut on 6/3/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DeltaCore/DeltaCore.h>

typedef NS_ENUM(NSInteger, GBAGameInput)
{
    GBAGameInputUp     = 1 << 6,
    GBAGameInputDown   = 1 << 7,
    GBAGameInputLeft   = 1 << 5,
    GBAGameInputRight  = 1 << 4,
    GBAGameInputA      = 1 << 0,
    GBAGameInputB      = 1 << 1,
    GBAGameInputL      = 1 << 9,
    GBAGameInputR      = 1 << 8,
    GBAGameInputStart  = 1 << 3,
    GBAGameInputSelect = 1 << 2,
};

typedef NS_ENUM(NSInteger, GBACheatType)
{
    GBACheatTypeActionReplay = 0,
    GBACheatTypeGameShark    = 1,
    GBACheatTypeCodeBreaker  = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface GBAEmulatorBridge : DLTAEmulatorBridge

// Inputs
- (void)activateInput:(GBAGameInput)gameInput;
- (void)deactivateInput:(GBAGameInput)gameInput;

// Cheats
- (BOOL)activateCheat:(NSString *)cheatCode type:(GBACheatType)type;
- (void)deactivateCheat:(NSString *)cheatCode;

@end


NS_ASSUME_NONNULL_END
