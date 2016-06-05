//
//  GBAEmulatorBridge.h
//  GBADeltaCore
//
//  Created by Riley Testut on 6/3/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DLTAEmulating;
@protocol DLTAAudioRendering;
@protocol DLTAVideoRendering;

NS_ASSUME_NONNULL_BEGIN

@interface GBAEmulatorBridge : NSObject

// State
@property (copy, nonatomic, nullable, readonly) NSURL *gameURL;

// Core
@property (weak, nonatomic, nullable) id<DLTAEmulating> emulatorCore;

// Audio
@property (weak, nonatomic, nullable) id<DLTAAudioRendering> audioRenderer;

// Video
@property (weak, nonatomic, nullable) id<DLTAVideoRendering> videoRenderer;

+ (instancetype)sharedBridge;

// Emulation
- (void)startWithGameURL:(NSURL *)URL;
- (void)stop;
- (void)pause;
- (void)resume;

@end


NS_ASSUME_NONNULL_END
