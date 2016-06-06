//
//  GBAEmulatorBridge.m
//  GBADeltaCore
//
//  Created by Riley Testut on 6/3/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

#import "GBAEmulatorBridge.h"
#import "GBASoundDriver.h"

// VBA-M
#include "../VBA-M/System.h"
#include "../VBA-M/gba/Sound.h"
#include "../VBA-M/gba/GBA.h"
#include "../VBA-M/Util.h"

#import <DeltaCore/DeltaCore.h>
#import <CoreImage/CoreImage.h>

#include <sys/time.h>

// Required vars, used by the emulator core
//
int  systemRedShift = 19;
int  systemGreenShift = 11;
int  systemBlueShift = 3;
int  systemColorDepth = 32;
int  systemVerbose;
int  systemSaveUpdateCounter;
int  systemFrameSkip;
u32  systemColorMap32[0x10000];
u16  systemColorMap16[0x10000];
u16  systemGbPalette[24];

int  emulating;
int  RGB_LOW_BITS_MASK;

@interface GBAEmulatorBridge ()

@property (copy, nonatomic, nonnull, readwrite) NSURL *gameURL;
@property (assign, nonatomic, readwrite) GBAEmulationState state;

@property (assign, nonatomic) GBAEmulationState previousState;

@property (assign, nonatomic, getter=isFrameReady) BOOL frameReady;

@property (strong, nonatomic, nonnull, readonly) CADisplayLink *displayLink;
@property (strong, nonatomic, nonnull, readonly) dispatch_queue_t renderQueue;
@property (strong, nonatomic, nonnull, readonly) dispatch_semaphore_t emulationStateSemaphore;

@property (strong, nonatomic, nonnull, readonly) NSMutableSet *activatedInputs;

@end

@implementation GBAEmulatorBridge

+ (instancetype)sharedBridge
{
    static GBAEmulatorBridge *_emulatorBridge = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _emulatorBridge = [[self alloc] init];
    });
    
    return _emulatorBridge;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _renderQueue = dispatch_queue_create("com.rileytestut.GBADeltaCore.renderQueue", DISPATCH_QUEUE_SERIAL);
        _emulationStateSemaphore = dispatch_semaphore_create(0);
        
        _activatedInputs = [NSMutableSet set];
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(didUpdateDisplayLink:)];
        _displayLink.frameInterval = 1;
        _displayLink.paused = YES;
        
        dispatch_queue_t emulationQueue = dispatch_queue_create("com.rileytestut.GBADeltaCore.emulationQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(emulationQueue, ^{
            [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
    }
    
    return self;
}

#pragma mark - Emulation -

- (void)startWithGameURL:(NSURL *)URL
{
    if (self.state != GBAEmulationStateStopped)
    {
        return;
    }
    
    self.state = GBAEmulationStateRunning;
    
    self.gameURL = URL;
    
    NSData *data = [NSData dataWithContentsOfURL:URL];
    
    if (!CPULoadRomData((const char*)data.bytes, data.length))
    {
        return;
    }
    
    utilUpdateSystemColorMaps(NO);
    
    char gameID[5];
    gameID[0] = rom[0xac];
    gameID[1] = rom[0xad];
    gameID[2] = rom[0xae];
    gameID[3] = rom[0xaf];
    gameID[4] = '\0';
    
    NSLog(@"VBA: GameID in ROM is: %s\n", gameID);
    
    soundInit();
    soundSetSampleRate(32768); // 44100 chirps
    
    soundReset();
    
    CPUInit(0, false);
    CPUReset();
    
    self.displayLink.paused = NO;
    
    dispatch_semaphore_wait(self.emulationStateSemaphore, DISPATCH_TIME_FOREVER);
}

- (void)stop
{
    if (self.state == GBAEmulationStateStopped)
    {
        return;
    }
    
    self.state = GBAEmulationStateStopped;
    
    GBASystem.emuCleanUp();
    soundShutdown();
    
    dispatch_semaphore_wait(self.emulationStateSemaphore, DISPATCH_TIME_FOREVER);
    
    self.displayLink.paused = YES;
}

- (void)pause
{
    if (self.state != GBAEmulationStateRunning)
    {
        return;
    }
    
    self.state = GBAEmulationStatePaused;
    
    dispatch_semaphore_wait(self.emulationStateSemaphore, DISPATCH_TIME_FOREVER);
}

- (void)resume
{
    if (self.state != GBAEmulationStatePaused)
    {
        return;
    }
    
    self.state = GBAEmulationStateRunning;
    
    dispatch_semaphore_wait(self.emulationStateSemaphore, DISPATCH_TIME_FOREVER);
}

#pragma mark - Render Loop -

- (void)didUpdateDisplayLink:(CADisplayLink *)displayLink
{
    self.frameReady = NO;
    
    while (![self isFrameReady] && self.state == GBAEmulationStateRunning)
    {
        GBASystem.emuMain(GBASystem.emuCount);
    }
    
    if (self.state == GBAEmulationStateRunning)
    {
        dispatch_async(self.renderQueue, ^{
            [self.emulatorCore didUpdate];
        });
    }
    
    if (self.previousState != self.state)
    {
        dispatch_semaphore_signal(self.emulationStateSemaphore);
    }
    
    self.previousState = self.state;
}

#pragma mark - Inputs -

- (void)activateInput:(GBAGameInput)gameInput
{
    [self.activatedInputs addObject:@(gameInput)];
}

- (void)deactivateInput:(GBAGameInput)gameInput
{
    [self.activatedInputs removeObject:@(gameInput)];
}

#pragma mark - Getters/Setters -

- (void)setState:(GBAEmulationState)state
{
    _state = state;
    
    switch (_state)
    {
        case GBAEmulationStateStopped:
            emulating = 0;
            break;
            
        case GBAEmulationStateRunning:
            emulating = 1;
            break;
            
        case GBAEmulationStatePaused:
            emulating = 0;
            break;
    }
}

@end

#pragma mark - VBA-M -

void systemMessage(int _iId, const char * _csFormat, ...)
{
    va_list args;
    va_start(args, _csFormat);
    
    NSLogv(@"%s", args);
    
    va_end(args);
}

void systemDrawScreen()
{
    for (int i = 0; i < 241 * 162 * 4; i++)
    {
        if ((i + 1) % 4 == 0)
        {
            pix[i] = 255;
        }
    }
    
    // Get rid of the first line and the last row
    dispatch_apply(160, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t y){
        memcpy([GBAEmulatorBridge sharedBridge].videoRenderer.videoBuffer + y * 240 * 4, pix + (y + 1) * (240 + 1) * 4, 240 * 4);
    });
    
    [[GBAEmulatorBridge sharedBridge] setFrameReady:YES];
}

bool systemReadJoypads()
{
    return true;
}

u32 systemReadJoypad(int joy)
{
    u32 joypad = 0;
    
    for (NSNumber *input in [GBAEmulatorBridge sharedBridge].activatedInputs.copy)
    {
        joypad |= [input unsignedIntegerValue];
    }
    
    return joypad;
}

void systemShowSpeed(int _iSpeed)
{
    
}

void system10Frames(int _iRate)
{
    
}

void systemFrame()
{
    
}

void systemSetTitle(const char * _csTitle)
{

}

void systemScreenCapture(int _iNum)
{

}

u32 systemGetClock()
{
    timeval time;
    
    gettimeofday(&time, NULL);
    
    double milliseconds = (time.tv_sec * 1000.0) + (time.tv_usec / 1000.0);
    return milliseconds;
}

SoundDriver *systemSoundInit()
{
    soundShutdown();
    
    auto driver = new GBASoundDriver;
    return driver;
}

void systemUpdateMotionSensor()
{
}

u8 systemGetSensorDarkness()
{
    return 0;
}

int systemGetSensorX()
{
    return 0;
}

int systemGetSensorY()
{
    return 0;
}

int systemGetSensorZ()
{
    return 0;
}

void systemCartridgeRumble(bool)
{
}

void systemGbPrint(u8 * _puiData,
                   int  _iLen,
                   int  _iPages,
                   int  _iFeed,
                   int  _iPalette,
                   int  _iContrast)
{
}

void systemScreenMessage(const char * _csMsg)
{
}

bool systemCanChangeSoundQuality()
{
    return true;
}

bool systemPauseOnFrame()
{
    return false;
}

void systemGbBorderOn()
{
}

void systemOnSoundShutdown()
{
}

void systemOnWriteDataToSoundBuffer(const u16 * finalWave, int length)
{
}

void debuggerMain()
{
}

void debuggerSignal(int, int)
{
}

void log(const char *defaultMsg, ...)
{
    static FILE *out = NULL;
    
    if(out == NULL) {
        out = fopen("trace.log","w");
    }
    
    va_list valist;
    
    va_start(valist, defaultMsg);
    vfprintf(out, defaultMsg, valist);
    va_end(valist);
}