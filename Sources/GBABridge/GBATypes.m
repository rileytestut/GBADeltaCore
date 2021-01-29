//
//  GBADeltaCore.m
//  GBADeltaCore
//
//  Created by Riley Testut on 7/8/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

#import "GBATypes.h"

GameType const GameTypeGBA = @"com.rileytestut.delta.game.gba";

CheatType const CheatTypeActionReplay = @"ActionReplay";
CheatType const CheatTypeGameShark = @"GameShark";
CheatType const CheatTypeCodeBreaker = @"CodeBreaker";

NSNotificationName const GBADidActivateGyroNotification = @"GBADidActivateGyroNotification";
NSNotificationName const GBADidDeactivateGyroNotification = @"GBADidDeactivateGyroNotification";
