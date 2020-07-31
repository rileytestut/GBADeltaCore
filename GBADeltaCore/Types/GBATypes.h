//
//  GBATypes.h
//  GBADeltaCore
//
//  Created by Riley Testut on 1/30/20.
//  Copyright © 2020 Riley Testut. All rights reserved.
//

#import <DeltaCore/DeltaTypes.h>

// Extensible Enums
FOUNDATION_EXPORT GameType const GameTypeGBA NS_SWIFT_NAME(gba);

FOUNDATION_EXPORT CheatType const CheatTypeActionReplay;
FOUNDATION_EXPORT CheatType const CheatTypeGameShark;
FOUNDATION_EXPORT CheatType const CheatTypeCodeBreaker;

FOUNDATION_EXPORT NSNotificationName const GBADidActivateGyroNotification NS_REFINED_FOR_SWIFT;
FOUNDATION_EXPORT NSNotificationName const GBADidDeactivateGyroNotification NS_REFINED_FOR_SWIFT;
