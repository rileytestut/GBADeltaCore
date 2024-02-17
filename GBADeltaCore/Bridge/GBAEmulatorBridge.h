//
//  GBAEmulatorBridge.h
//  GBADeltaCore
//
//  Created by Riley Testut on 6/3/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Spatial/Spatial.h>

@protocol DLTAEmulatorBridging;

@interface GBARotation : NSObject

@property (nonatomic) SPRotation3D rotation;
@property (nonatomic) SPVector3D rotationRate;

- (nonnull instancetype)initWithRotation:(SPRotation3D)rotation rate:(SPVector3D)rate;

@end

NS_ASSUME_NONNULL_BEGIN

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything" // Silence "Cannot find protocol definition" warning due to forward declaration.
@interface GBAEmulatorBridge : NSObject <DLTAEmulatorBridging>
#pragma clang diagnostic pop

@property (class, nonatomic, readonly) GBAEmulatorBridge *sharedBridge;

@property (copy, nonatomic, nullable) NSURL *coreDirectoryURL;
@property (strong, nonatomic, nullable) NSBundle *coreResourcesBundle;

@property (strong, atomic, nullable) GBARotation *controllerRotation; // For the first time ever, we _do_ want atomic!

@end

NS_ASSUME_NONNULL_END
