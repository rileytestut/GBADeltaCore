//
//  DeltaCoreObjC.h
//
//  Created by Riley Testut on 11/15/21.
//  Copyright © 2021 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface DLTARingBuffer: NSObject
- (NSInteger)writeBuffer:(void *)buffer size:(NSInteger)size;
- (NSInteger)readIntoBuffer:(void *)buffer preferredSize:(NSInteger)size;
- (nullable instancetype)initWithPreferredBufferSize:(NSInteger)size;
@end

@protocol DLTAAudioRendering <NSObject>
@property (nonatomic, readonly) DLTARingBuffer *audioBuffer;
@end

@protocol DLTAVideoRendering <NSObject>
@property (nonatomic, nullable, readonly) uint8_t *videoBuffer;
@property (nonatomic, readonly) CGRect viewport;
- (void)prepare;
- (void)processFrame;
@end

@protocol DLTAEmulatorBridging <NSObject>
@property (nonatomic, copy, nullable, readonly) NSURL *gameURL;
@property (nonatomic, strong, nullable) id<DLTAAudioRendering> audioRenderer;
@property (nonatomic, strong, nullable) id<DLTAVideoRendering> videoRenderer;
@property (nonatomic, copy, nullable) void (^saveUpdateHandler)(void);
@end

@interface DLTAEmulatorCore: NSObject
@property (nonatomic, class, readonly) NSNotificationName emulationDidQuitNotification;
@end

@interface NSCharacterSet (DeltaCoreObjC)
@property (nonatomic, class, readonly) NSMutableCharacterSet *hexadecimalCharacterSet;
@end

NS_ASSUME_NONNULL_END
