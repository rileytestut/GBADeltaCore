//
//  GBAEmulatorBridge.m
//  GBADeltaCore
//
//  Created by Riley Testut on 6/3/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

// Enable VBA-M logging for illegal write detection
#ifndef GBA_LOGGING
#define GBA_LOGGING
#endif

#import "GBAEmulatorBridge.h"
#import "GBASoundDriver.h"

#import <CoreMotion/CoreMotion.h>

// VBA-M
#include "System.h"
#include "gba/Sound.h"
#include "gba/GBA.h"
#include "gba/Globals.h"
#include "gba/Cheats.h"
#include "gba/RTC.h"
#include "Util.h"

#include <sys/time.h>

// DeltaCore
#import <GBADeltaCore/GBADeltaCore.h>
#import <DeltaCore/DeltaCore.h>
#import <DeltaCore/DeltaCore-Swift.h>

#if STATIC_LIBRARY
#import "GBADeltaCore-Swift.h"
#import "GBATypes.h"
#else
#import <GBADeltaCore/GBADeltaCore-Swift.h>
#endif

// Required vars, used by the emulator core
//
int  systemRedShift = 19;
int  systemGreenShift = 11;
int  systemBlueShift = 3;
int  systemColorDepth = 32;
int  systemVerbose;
int  systemSaveUpdateCounter = 0;
int  systemFrameSkip;
uint32_t  systemColorMap32[0x10000];
uint16_t  systemColorMap16[0x10000];
uint16_t  systemGbPalette[24];

int  emulating;
int  RGB_LOW_BITS_MASK;

@interface GBAEmulatorBridge ()

@property (nonatomic, copy, nullable, readwrite) NSURL *gameURL;

@property (assign, nonatomic, getter=isFrameReady) BOOL frameReady;

@property (nonatomic) uint32_t activatedInputs;

@property (strong, nonatomic, readonly) CMMotionManager *motionManager;

@end

@implementation GBAEmulatorBridge
@synthesize audioRenderer = _audioRenderer;
@synthesize videoRenderer = _videoRenderer;
@synthesize saveUpdateHandler = _saveUpdateHandler;

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
        _motionManager = [[CMMotionManager alloc] init];
    }
    
    return self;
}

#pragma mark - Emulation -

- (void)startWithGameURL:(NSURL *)URL
{
    self.gameURL = URL;
    
    NSData *data = [NSData dataWithContentsOfURL:URL];
    
    if (!CPULoadRomData((const char *)data.bytes, (int)data.length))
    {
        return;
    }
        
    utilUpdateSystemColorMaps(NO);
    utilGBAFindSave((int)data.length);
    
    // Update per-game settings after utilGBAFindSave determines defaults.
    [self updateGameSettings];
    
    soundInit();
    soundSetSampleRate(32768); // 44100 chirps
    
    soundReset();
    
    CPUInit(0, false);
    
    GBASystem.emuReset();
    
    // Enable illegal write logging (VERBOSE_ILLEGAL_WRITE = 4)
    systemVerbose = 4;
    
    emulating = 1;
}

- (void)stop
{
    GBASystem.emuCleanUp();
    soundShutdown();
    
    emulating = 0;
    
    [self deactivateGyroscope];
}

- (void)pause
{
    emulating = 0;
    
    [self deactivateGyroscope];
}

- (void)resume
{
    emulating = 1;
}

- (void)runFrameAndProcessVideo:(BOOL)processVideo
{
    self.frameReady = NO;
    
    while (![self isFrameReady])
    {
        GBASystem.emuMain(GBASystem.emuCount);
    }
}

- (nullable NSData *)readMemoryAtAddress:(NSInteger)address size:(NSInteger)size
{
    if (workRAM == NULL)
    {
        return nil;
    }
    
    void *bytes = NULL;
    if (address >= 0x8000)
    {
        bytes = (void *)(workRAM + address - 0x8000);
    }
    else
    {
        bytes = (void *)(internalRAM + address);
    }
    
    NSData *data = [NSData dataWithBytesNoCopy:bytes length:size freeWhenDone:NO];
    return data;
}

#pragma mark - Settings -

- (void)updateGameSettings
{
    NSString *gameID = [NSString stringWithFormat:@"%c%c%c%c", rom[0xac], rom[0xad], rom[0xae], rom[0xaf]];
    
    NSLog(@"VBA-M: GameID in ROM is: %@", gameID);
    
    // Set defaults
    // Use underscores to prevent shadowing of global variables
    BOOL _enableRTC       = NO;
    BOOL _enableMirroring = NO;
    BOOL _useBIOS         = NO;
    int  _cpuSaveType     = 0;
    int  _flashSize       = 0x10000;
    
    // Read in vba-over.ini and break it into an array of strings
    NSString *iniPath = [GBAEmulatorBridge.gbaResources pathForResource:@"vba-over" ofType:@"ini"];
    NSString *iniString = [NSString stringWithContentsOfFile:iniPath encoding:NSUTF8StringEncoding error:NULL];
    NSArray *settings = [iniString componentsSeparatedByString:@"\n"];
    
    BOOL matchFound = NO;
    NSMutableDictionary *overridesFound = [[NSMutableDictionary alloc] init];
    NSString *temp;
    
    // Check if vba-over.ini has per-game settings for our gameID
    for (NSString *s in settings)
    {
        temp = nil;
        
        if ([s hasPrefix:@"["])
        {
            NSScanner *scanner = [NSScanner scannerWithString:s];
            [scanner scanString:@"[" intoString:nil];
            [scanner scanUpToString:@"]" intoString:&temp];
            
            if ([temp caseInsensitiveCompare:gameID] == NSOrderedSame)
            {
                matchFound = YES;
            }
            
            continue;
        }
        
        else if (matchFound && [s hasPrefix:@"saveType="])
        {
            NSScanner *scanner = [NSScanner scannerWithString:s];
            [scanner scanString:@"saveType=" intoString:nil];
            [scanner scanUpToString:@"\n" intoString:&temp];
            _cpuSaveType = [temp intValue];
            [overridesFound setObject:temp forKey:@"CPU saveType"];
            
            continue;
        }
        
        else if (matchFound && [s hasPrefix:@"rtcEnabled="])
        {
            NSScanner *scanner = [NSScanner scannerWithString:s];
            [scanner scanString:@"rtcEnabled=" intoString:nil];
            [scanner scanUpToString:@"\n" intoString:&temp];
            _enableRTC = [temp boolValue];
            [overridesFound setObject:temp forKey:@"rtcEnabled"];
            
            continue;
        }
        
        else if (matchFound && [s hasPrefix:@"flashSize="])
        {
            NSScanner *scanner = [NSScanner scannerWithString:s];
            [scanner scanString:@"flashSize=" intoString:nil];
            [scanner scanUpToString:@"\n" intoString:&temp];
            _flashSize = [temp intValue];
            [overridesFound setObject:temp forKey:@"flashSize"];
            
            continue;
        }
        
        else if (matchFound && [s hasPrefix:@"mirroringEnabled="])
        {
            NSScanner *scanner = [NSScanner scannerWithString:s];
            [scanner scanString:@"mirroringEnabled=" intoString:nil];
            [scanner scanUpToString:@"\n" intoString:&temp];
            _enableMirroring = [temp boolValue];
            [overridesFound setObject:temp forKey:@"mirroringEnabled"];
            
            continue;
        }
        
        else if (matchFound && [s hasPrefix:@"useBios="])
        {
            NSScanner *scanner = [NSScanner scannerWithString:s];
            [scanner scanString:@"useBios=" intoString:nil];
            [scanner scanUpToString:@"\n" intoString:&temp];
            _useBIOS = [temp boolValue];
            [overridesFound setObject:temp forKey:@"useBios"];
            
            continue;
        }
        
        else if (matchFound)
            break;
    }
    
    // Some hacked games use the RealTimeClock even when the game they're based off of doesn't (ex: Pokemon Liquid Crystal), so we always have it enabled.
    rtcEnable(true);
    
    if (!matchFound)
    {
        // Only update remaining settings if we found a match.
        return;
    }
    
    NSLog(@"VBA: overrides found: %@", overridesFound);
    
    // Apply settings
    mirroringEnable = _enableMirroring;
    doMirroring(mirroringEnable);
    cpuSaveType = _cpuSaveType;
    
    // Delta doesn't use BIOS files.
    // useBios = _useBIOS;
    
    if (_flashSize == 0x10000 || _flashSize == 0x20000)
    {
        flashSetSize(_flashSize);
    }
    
}

#pragma mark - Inputs -

- (void)activateInput:(NSInteger)gameInput value:(double)value playerIndex:(NSInteger)playerIndex
{
    self.activatedInputs |= (uint32_t)gameInput;
}

- (void)deactivateInput:(NSInteger)gameInput playerIndex:(NSInteger)playerIndex
{
    self.activatedInputs &= ~((uint32_t)gameInput);
}

- (void)resetInputs
{
    self.activatedInputs = 0;
}

#pragma mark - Game Saves -

- (void)saveGameSaveToURL:(NSURL *)URL
{
    GBASystem.emuWriteBattery(URL.fileSystemRepresentation);
}

- (void)loadGameSaveFromURL:(NSURL *)URL
{
    GBASystem.emuReadBattery(URL.fileSystemRepresentation);
}

#pragma mark - Save States -

- (void)saveSaveStateToURL:(NSURL *)URL
{
    GBASystem.emuWriteState(URL.fileSystemRepresentation);
}

- (void)loadSaveStateFromURL:(NSURL *)URL
{
    GBASystem.emuReadState(URL.fileSystemRepresentation);
}

#pragma mark - Cheats -

- (BOOL)addCheatCode:(NSString *)cheatCode type:(NSString *)type
{
    NSArray<NSString *> *codes = [cheatCode componentsSeparatedByString:@"\n"];
    for (NSString *code in codes)
    {
        NSMutableCharacterSet *legalCharactersSet = [NSMutableCharacterSet hexadecimalCharacterSet];
        [legalCharactersSet addCharactersInString:@" "];
        
        if ([code rangeOfCharacterFromSet:[legalCharactersSet invertedSet]].location != NSNotFound)
        {
            return NO;
        }
        
        if ([type isEqualToString:CheatTypeActionReplay] || [type isEqualToString:CheatTypeGameShark])
        {
            NSString *sanitizedCode = [code stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if (sanitizedCode.length != 16)
            {
                return NO;
            }
            
            cheatsAddGSACode([sanitizedCode UTF8String], "code", true);
        }
        else if ([type isEqualToString:CheatTypeCodeBreaker])
        {
            if (code.length != 13)
            {
                return NO;
            }
            
            cheatsAddCBACode([code UTF8String], "code");
        }
    }
    
    return YES;
}

- (void)resetCheats
{
    cheatsDeleteAll(true);
}

- (void)updateCheats
{
    
}

#pragma mark - Gyroscope -

- (void)activateGyroscope
{
    if ([self.motionManager isGyroActive] || ![self.motionManager isGyroAvailable])
    {
        return;
    }
    
    [self.motionManager startGyroUpdates];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GBADidActivateGyroNotification object:self];
}

- (void)deactivateGyroscope
{
    if (![self.motionManager isGyroActive])
    {
        return;
    }
    
    [self.motionManager stopGyroUpdates];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GBADidDeactivateGyroNotification object:self];
}

#pragma mark - Getters/Setters -

- (NSTimeInterval)frameDuration
{
    return (1.0 / 60.0);
}

@end

#pragma mark - VBA-M -

void systemMessage(int _iId, const char * _csFormat, ...)
{
    NSLog(@"VBA-M: %s", _csFormat);
}

void systemDrawScreen()
{
    // Get rid of the first line and the last row
    for (int y = 0; y < 160; y++)
    {
        memcpy([GBAEmulatorBridge sharedBridge].videoRenderer.videoBuffer + y * 240 * 4, pix + (y + 1) * (240 + 1) * 4, 240 * 4);
    }
    
    [[GBAEmulatorBridge sharedBridge].videoRenderer processFrame];
    [[GBAEmulatorBridge sharedBridge] setFrameReady:YES];
}

bool systemReadJoypads()
{
    return true;
}

uint32_t systemReadJoypad(int joy)
{
    return [GBAEmulatorBridge sharedBridge].activatedInputs;
}

void systemShowSpeed(int _iSpeed)
{
    
}

void system10Frames(int _iRate)
{
    if (systemSaveUpdateCounter > 0)
    {
        systemSaveUpdateCounter--;
        
        if (systemSaveUpdateCounter <= SYSTEM_SAVE_NOT_UPDATED)
        {
            if (GBAEmulatorBridge.sharedBridge.saveUpdateHandler)
            {
                GBAEmulatorBridge.sharedBridge.saveUpdateHandler();
            }
            
            systemSaveUpdateCounter = SYSTEM_SAVE_NOT_UPDATED;
        }
    }
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

uint32_t systemGetClock()
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

uint8_t systemGetSensorDarkness()
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
    if (![GBAEmulatorBridge.sharedBridge.motionManager isGyroActive])
    {
        [GBAEmulatorBridge.sharedBridge activateGyroscope];
    }
    
    CMGyroData *gyroData = GBAEmulatorBridge.sharedBridge.motionManager.gyroData;
    
    int sensorZ = -gyroData.rotationRate.z * 25;
    return sensorZ;
}

void systemCartridgeRumble(bool)
{
}

void systemGbPrint(uint8_t * _puiData,
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

void systemOnWriteDataToSoundBuffer(const uint16_t * finalWave, int length)
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
        // Write to the app's temporary directory instead of current directory
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *logPath = [tmpDir stringByAppendingPathComponent:@"trace.log"];
        out = fopen([logPath UTF8String], "w");
        
        if (out == NULL) {
            // If we can't open the file, just continue without file logging
            NSLog(@"Warning: Could not open trace.log for writing");
        }
    }
    
    va_list valist;
    va_start(valist, defaultMsg);
    
    // Check if this is an illegal write message
    if (strstr(defaultMsg, "Illegal") != NULL && strstr(defaultMsg, "write") != NULL) {
        
        // Format the message to a string
        char buffer[512];
        va_list valistCopy;
        va_copy(valistCopy, valist);
        vsnprintf(buffer, sizeof(buffer), defaultMsg, valistCopy);
        va_end(valistCopy);
        
        // Strip trailing newline if present
        size_t len = strlen(buffer);
        if (len > 0 && buffer[len - 1] == '\n') {
            buffer[len - 1] = '\0';
        }
        
        // DEBUG: Always log the formatted buffer to see what we're matching against
        NSLog(@"DEBUG: Formatted illegal write: %s", buffer);
        
        // Detect the ROM writing the ASCII marker "ALTSTORE", regardless of
        // which address it writes to or which instruction performs the write.
        static const char markerToDetect[] = "ALTSTORE";
        enum { MarkerLength = sizeof(markerToDetect) - 1 };

        // Rolling buffer of the most recent illegal-write byte values.
        static char recentBytes[MarkerLength] = {0};

        unsigned int value = 0;
        int valueSize = 0;

        if (sscanf(buffer, "Illegal byte write: %x", &value) == 1) {
            valueSize = 1;
        } else if (sscanf(buffer, "Illegal halfword write: %x", &value) == 1) {
            valueSize = 2;
        } else if (sscanf(buffer, "Illegal word write: %x", &value) == 1) {
            valueSize = 4;
        }

        for (int i = 0; i < valueSize; i++) {
            // GBA is little-endian, so a halfword/word write's bytes arrive lowest-first.
            char byte = (char)((value >> (8 * i)) & 0xFF);

            memmove(recentBytes, recentBytes + 1, MarkerLength - 1);
            recentBytes[MarkerLength - 1] = byte;

            if (memcmp(recentBytes, markerToDetect, MarkerLength) == 0) {
                NSLog(@"Detected illegal write marker '%s' (last write: %s)", markerToDetect, buffer);

                // Post notification to communicate with the rest of the app
                [[NSNotificationCenter defaultCenter] postNotificationName:GBADidDetectIllegalWriteNotification
                                                                    object:GBAEmulatorBridge.sharedBridge
                                                                  userInfo:@{@"marker": [NSString stringWithUTF8String:markerToDetect],
                                                                             @"message": [NSString stringWithUTF8String:buffer]}];

                // Require the full marker to be written again before re-triggering.
                memset(recentBytes, 0, MarkerLength);
            }
        }
    }
    
    // Only write to file if it was successfully opened
    if (out != NULL) {
        vfprintf(out, defaultMsg, valist);
        fflush(out);  // Flush immediately so we don't lose data on crash
    }
    
    va_end(valist);
}
