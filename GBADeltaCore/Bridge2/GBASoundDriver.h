//
//  GBASoundDriver.h
//  GBADeltaCore
//
//  Created by Riley Testut on 6/3/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

#include <stdio.h>

#include "common/SoundDriver.h"
#include "GBAEmulatorBridge.hpp"

#include <string>

extern "C"
{
typedef void (*AudioCallback)(const unsigned char *_Nonnull buffer, int size);
}

class GBASoundDriver : public SoundDriver
{
public:
    GBASoundDriver();
    virtual ~GBASoundDriver();
    
    virtual bool init(long sampleRate);
    virtual void pause();
    virtual void reset();
    virtual void resume();
    virtual void write(uint16_t *finalWave, int length);
    
    void setAudioCallback(AudioCallback audioCallback);
    
    std::string description();
    
private:
    AudioCallback _audioCallback;
};
