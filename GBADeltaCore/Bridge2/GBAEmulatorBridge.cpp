//
//  NESEmulatorBridge.cpp
//  NESDeltaCore
//
//  Created by Riley Testut on 6/1/18.
//  Copyright © 2018 Riley Testut. All rights reserved.
//

#include "GBAEmulatorBridge.hpp"


// VBA-M
#include "System.h"
#include "gba/Sound.h"
#include "gba/GBA.h"
#include "gba/Cheats.h"
#include "gba/RTC.h"
#include "Util.h"

#include "GBASoundDriver.h"

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

uint8_t videoBuffer[4 * 241 * 162];

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

int  emulating = 0;
int  RGB_LOW_BITS_MASK;

// Delta variables
bool frameReady = false;
uint32_t activatedInputs = 0;

bool processVideo = true;

#pragma mark - Initialization/Deallocation -

#if __EMSCRIPTEN__

#define USE_WEBSOCKETS 0

#include <emscripten.h>
#include <emscripten/websocket.h>

EMSCRIPTEN_WEBSOCKET_T audioSocket;
EMSCRIPTEN_WEBSOCKET_T videoSocket;

EM_JS(void, startMyEmulation, (), {
    performStartUp();
});

EM_BOOL onopen(int eventType, const EmscriptenWebSocketOpenEvent *websocketEvent, void *userData) {
    printf("[RSTLog] On Open: %s\n", userData);

//    EMSCRIPTEN_RESULT result;
//    result = emscripten_websocket_send_utf8_text(websocketEvent->socket, "hoge");
//    if (result) {
//        printf("Failed to emscripten_websocket_send_utf8_text(): %d\n", result);
//    }
    return EM_TRUE;
}
EM_BOOL onerror(int eventType, const EmscriptenWebSocketErrorEvent *websocketEvent, void *userData) {
    printf("[RSTLog] On Error: %s\n", userData);

    return EM_TRUE;
}
EM_BOOL onclose(int eventType, const EmscriptenWebSocketCloseEvent *websocketEvent, void *userData) {
    printf("[RSTLog] On Close: %s\n", userData);

    return EM_TRUE;
}
EM_BOOL onmessage(int eventType, const EmscriptenWebSocketMessageEvent *websocketEvent, void *userData) {
    printf("[RSTLog] On Message: %s\n", userData);
//    if (websocketEvent->isText) {
//        // For only ascii chars.
//        printf("message: %s\n", websocketEvent->data);
//    }
//
//    EMSCRIPTEN_RESULT result;
//    result = emscripten_websocket_close(websocketEvent->socket, 1000, "no reason");
//    if (result) {
//        printf("Failed to emscripten_websocket_close(): %d\n", result);
//    }
    return EM_TRUE;
}

int main(int argc, char **argv)
{
    printf("HELLO FUCKING WORLD!!!\n");
    
    startMyEmulation();
    
#if USE_WEBSOCKETS
    
    EmscriptenWebSocketCreateAttributes ws_attrs = {
            "ws://localhost:8080/audio",
            NULL,
            EM_TRUE
        };
    
    void *audioUserInfo = (void *)"audio";
    audioSocket = emscripten_websocket_new(&ws_attrs);
    emscripten_websocket_set_onopen_callback(audioSocket, audioUserInfo, onopen);
    emscripten_websocket_set_onerror_callback(audioSocket, audioUserInfo, onerror);
    emscripten_websocket_set_onclose_callback(audioSocket, audioUserInfo, onclose);
    emscripten_websocket_set_onmessage_callback(audioSocket, audioUserInfo, onmessage);
    
    EmscriptenWebSocketCreateAttributes ws_attrs2 = {
            "ws://localhost:8080/video",
            NULL,
            EM_TRUE
        };
    
    void *videoUserInfo = (void *)"video";
    videoSocket = emscripten_websocket_new(&ws_attrs2);
    emscripten_websocket_set_onopen_callback(videoSocket, videoUserInfo, onopen);
    emscripten_websocket_set_onerror_callback(videoSocket, videoUserInfo, onerror);
    emscripten_websocket_set_onclose_callback(videoSocket, videoUserInfo, onclose);
    emscripten_websocket_set_onmessage_callback(videoSocket, videoUserInfo, onmessage);
    
#endif
}

#endif

void GBAInitialize()
{
    printf("Initializing...!!!\n");
}

#pragma mark - Emulation -

bool GBAStartEmulation(const char *gameFilepath)
{
    std::ifstream stream(gameFilepath);
    std::string data((std::istreambuf_iterator<char>(stream)), std::istreambuf_iterator<char>());
    
    if (data.size() == 0)
    {
        printf("WTF :((\n");
    }
    
    if (!CPULoadRomData((const char *)data.data(), (int)data.length()))
    {
        return false;
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

#include <chrono>
using namespace std::chrono;

void GBARunFrame(bool process)
{
//    auto start = high_resolution_clock::now();
    
    frameReady = false;
    processVideo = process;
    
    while (!frameReady)
    {
        GBASystem.emuMain(GBASystem.emuCount);
    }
    
//    auto stop = high_resolution_clock::now();
    
//    auto duration = duration_cast<milliseconds>(stop - start);
      
    // To get the value of duration use the count()
    // member function on the duration object
//    std::cout << "Frame Duration:" << duration.count() << std::endl;
}

#pragma mark - Inputs -

void GBAActivateInput(int input, double value)
{
    printf("Activating Input: %d\n", input);
    activatedInputs |= (uint32_t)input;
}

void GBADeactivateInput(int input)
{
    printf("Deactivating Input: %d\n", input);
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
//    GBASystem.emuWriteState(saveStateFilepath, NULL);
}

void GBALoadSaveState(const char *saveStateFilepath)
{
//    GBASystem.emuReadState(saveStateFilepath, NULL);
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
    if (processVideo)
    {
        // Get rid of the first line and the last row
        for (int y = 0; y < 160; y++)
        {
            memcpy(videoBuffer + y * 240 * 4, pix + (y + 1) * (240 + 1) * 4, 240 * 4);
        }
        
    #if USE_WEBSOCKETS
        emscripten_websocket_send_binary(videoSocket, (void *)videoBuffer, 240 * 160 * 4);
    #else
        videoCallback(videoBuffer, 240 * 160 * 4);
    #endif
    }
    
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
    
    printf("[RSTLog] Sound Test 1: %p\n", audioCallback);
    
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
#if USE_WEBSOCKETS
    emscripten_websocket_send_binary(audioSocket, (void *)finalWave, (uint32_t)length);
#else
    if (audioCallback)
    {
        audioCallback((uint8_t *)finalWave, length);
    }
#endif
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
