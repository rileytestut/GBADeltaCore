//
//  GBASoundDriver.h
//  GBADeltaCore
//
//  Created by Riley Testut on 6/3/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

#include <stdio.h>

#include "common/SoundDriver.h"

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
};
