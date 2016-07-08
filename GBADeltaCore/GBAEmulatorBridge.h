//
//  GBAEmulatorBridge.h
//  GBADeltaCore
//
//  Created by Riley Testut on 6/3/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DeltaCore/DeltaCore.h>
#import <DeltaCore/DeltaCore-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface GBAEmulatorBridge : NSObject <DLTAEmulatorBridging>

@property (class, nonatomic, readonly) GBAEmulatorBridge *sharedBridge;

@end

NS_ASSUME_NONNULL_END
