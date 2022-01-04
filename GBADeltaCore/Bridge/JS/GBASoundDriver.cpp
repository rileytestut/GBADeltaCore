//
//  DeltaSoundDriver.cpp
//  GBADeltaCore
//
//  Created by Riley Testut on 6/3/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

#import "GBASoundDriver.h"

GBASoundDriver::GBASoundDriver()
{
}

GBASoundDriver::~GBASoundDriver()
{
}

bool GBASoundDriver::init(long sampleRate)
{
    return true;
}

void GBASoundDriver::write(uint16_t *finalWave, int length)
{
    if (this->_audioCallback == NULL)
    {
        return;
    }
    
    _audioCallback((unsigned char *)finalWave, length);
}

void GBASoundDriver::pause()
{
}

void GBASoundDriver::resume()
{
}

void GBASoundDriver::reset()
{
}

void GBASoundDriver::setAudioCallback(AudioCallback audioCallback)
{
    _audioCallback = audioCallback;
}

