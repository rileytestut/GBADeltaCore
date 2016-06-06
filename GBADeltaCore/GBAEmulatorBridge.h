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

typedef NS_ENUM(NSInteger, GBAEmulationState)
{
    GBAEmulationStateStopped = 0,
    GBAEmulationStateRunning = 1,
    GBAEmulationStatePaused  = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface GBAEmulatorBridge : NSObject

// State
@property (copy, nonatomic, nullable, readonly) NSURL *gameURL;
@property (assign, nonatomic, readonly) GBAEmulationState state;

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

// Inputs
- (void)activateInput:(GBAGameInput)gameInput;
- (void)deactivateInput:(GBAGameInput)gameInput;

// Save States
- (void)saveSaveStateToURL:(NSURL *)URL;
- (void)loadSaveStateFromURL:(NSURL *)URL;

@end


NS_ASSUME_NONNULL_END
