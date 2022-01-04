//
//  NESEmulatorBridge.cpp
//  NESDeltaCore
//
//  Created by Riley Testut on 6/1/18.
//  Copyright © 2018 Riley Testut. All rights reserved.
//

#include "GBAEmulatorBridge.hpp"
#include "GBASoundDriver.h"

// VBA-M
#include "System.h"
#include "gba/Sound.h"
#include "gba/GBA.h"
#include "gba/Cheats.h"
#include "gba/RTC.h"
#include "Util.h"

#include <sys/time.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#pragma clang diagnostic pop

// C++
#include <iostream>
#include <fstream>

VoidCallback saveCallback = NULL;
BufferCallback audioCallback = NULL;
BufferCallback videoCallback = NULL;

uint8_t videoBuffer[240 * 160 * 4];

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

// Delta variables
bool frameReady = false;
uint32_t activatedInputs = 0;

#pragma mark - Initialization/Deallocation -

void GBAInitialize(const char *databasePath)
{
}

#pragma mark - Emulation -

bool GBAStartEmulation(const char *gameFilepath)
{
    if (!CPULoadRom(gameFilepath))
    {
        return;
    }
        
    utilUpdateSystemColorMaps(false);
    utilGBAFindSave((int)data.length());
    
    // Update per-game settings after utilGBAFindSave determines defaults.
//    [self updateGameSettings];
    
    soundInit();
    soundSetSampleRate(32768); // 44100 chirps
    
    soundReset();
    
    CPUInit(0, false);
    
    GBASystem.emuReset();
    
    emulating = 1;
    
    return true;
}

void GBAStopEmulation()
{
    GBASystem.emuCleanUp();
    soundShutdown();
    
    emulating = 0;
}

void GBAPauseEmulation()
{
    emulating = 0;
}

void GBAResumeEmulation()
{
    emulating = 1;
}

#pragma mark - Game Loop -

void GBARunFrame()
{
    frameReady = false;
    
    while (!frameReady)
    {
        GBASystem.emuMain(GBASystem.emuCount);
    }
}

#pragma mark - Inputs -

void GBAActivateInput(int input, double value)
{
    activatedInputs |= (uint32_t)input;
}

void GBADeactivateInput(int input)
{
    activatedInputs &= ~((uint32_t)input);
}

void GBAResetInputs()
{
    activatedInputs = 0;
}

#pragma mark - Game Saves -

void GBASaveGameSave(const char *gameSavePath)
{
    GBASystem.emuWriteBattery(gameSavePath);
}

void GBALoadGameSave(const char *gameSavePath)
{
    GBASystem.emuReadBattery(gameSavePath);
}

#pragma mark - Save States -

void GBASaveSaveState(const char *saveStateFilepath)
{
    GBASystem.emuWriteState(saveStateFilepath);
}

void GBALoadSaveState(const char *saveStateFilepath)
{
    GBASystem.emuReadState(saveStateFilepath);
}

#pragma mark - Cheats -

bool GBAAddCheatCode(const char *cheatCode, const char *type)
{
    if (std::string(type) == "ActionReplay" || std::string(type) == "GameShark")
    {
        cheatsAddGSACode(cheatCode, "code", true);
        return true;
    }
    else if (std::string(type) == "CodeBreaker")
    {
        cheatsAddCBACode(cheatCode, "code");
        return true;
    }
    
    return false;
}

void GBAResetCheats()
{
    cheatsDeleteAll(true);
}

void GBAUpdateCheats()
{
}

#pragma mark - Getters/Setters -

double GBAFrameDuration()
{
    return (1.0 / 60.0);
}

#pragma mark - VBA-M -

void systemMessage(int _iId, const char * _csFormat, ...)
{
    printf("VBA-M: %s", _csFormat);
}

void systemDrawScreen()
{
    // Get rid of the first line and the last row
    for (int y = 0; y < 160; y++)
    {
        memcpy(videoBuffer + y * 240 * 4, pix + (y + 1) * (240 + 1) * 4, 240 * 4);
    }
    
    videoCallback(videoBuffer, 240 * 160 * 4);
    frameReady = true;
}

bool systemReadJoypads()
{
    return true;
}

uint32_t systemReadJoypad(int joy)
{
    return activatedInputs;
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
            if (saveCallback)
            {
                saveCallback();
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
    driver->setAudioCallback(audioCallback);
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
    return 0;
//    if (![GBAEmulatorBridge.sharedBridge.motionManager isGyroActive])
//    {
//        [GBAEmulatorBridge.sharedBridge activateGyroscope];
//    }
//
//    CMGyroData *gyroData = GBAEmulatorBridge.sharedBridge.motionManager.gyroData;
//
//    int sensorZ = -gyroData.rotationRate.z * 25;
//    return sensorZ;
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
        out = fopen("trace.log","w");
    }
    
    va_list valist;
    
    va_start(valist, defaultMsg);
    vfprintf(out, defaultMsg, valist);
    va_end(valist);
}


#pragma mark - Callbacks -

void GBASetAudioCallback(BufferCallback callback)
{
    audioCallback = callback;
}

void GBASetVideoCallback(BufferCallback callback)
{
    videoCallback = callback;
}

void GBASetSaveCallback(VoidCallback callback)
{
    saveCallback = callback;
}
