//
//  GBAEmulatorBridge.hpp
//  GBADeltaCore
//
//  Created by Riley Testut on 12/7/21.
//  Copyright © 2021 Riley Testut. All rights reserved.
//

#ifndef GBAEmulatorBridge_hpp
#define GBAEmulatorBridge_hpp

#include <stdio.h>
#include <stdbool.h>

#ifdef __EMSCRIPTEN__
#include <emscripten/emscripten.h>
#else
#define EMSCRIPTEN_KEEPALIVE /* Nothing */
#endif

#if defined(__cplusplus)
extern "C"
{
#endif
    typedef void (*BufferCallback)(const unsigned char *_Nonnull buffer, int size);
    typedef void (*VoidCallback)(void);

    double GBAFrameDuration();
    
    void EMSCRIPTEN_KEEPALIVE GBAInitialize();
    
    bool GBAStartEmulation(const char *_Nonnull gamePath);
    void GBAStopEmulation();
    void GBAPauseEmulation();
    void GBAResumeEmulation();
    
    void GBARunFrame(bool processVideo);
    
    void GBAActivateInput(int input, double value);
    void GBADeactivateInput(int input);
    void GBAResetInputs();
    
    void GBASaveSaveState(const char *_Nonnull saveStatePath);
    void GBALoadSaveState(const char *_Nonnull saveStatePath);
    
    void GBASaveGameSave(const char *_Nonnull gameSavePath);
    void GBALoadGameSave(const char *_Nonnull gameSavePath);
    
    bool GBAAddCheatCode(const char *_Nonnull cheatCode, const char *_Nonnull type);
    void GBAResetCheats();
    void GBAUpdateCheats();

    void GBASetAudioCallback(_Nullable BufferCallback callback);
    void GBASetVideoCallback(_Nullable BufferCallback callback);
    void GBASetSaveCallback(_Nullable VoidCallback callback);
    
#if defined(__cplusplus)
}
#endif

#endif /* GBAEmulatorBridge_hpp */
