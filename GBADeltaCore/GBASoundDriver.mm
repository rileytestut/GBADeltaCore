//
//  DeltaSoundDriver.cpp
//  GBADeltaCore
//
//  Created by Riley Testut on 6/3/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

#import "GBASoundDriver.h"
#import "GBAEmulatorBridge.h"

#import <DeltaCore/DeltaCore.h>

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
    [[GBAEmulatorBridge sharedBridge].audioRenderer.ringBuffer writeToRingBuffer:^int32_t(void * _Nonnull ringBuffer, int32_t availableBytes) {
        memcpy(ringBuffer, finalWave, MIN(length, availableBytes));
        return MIN(length, availableBytes);
    }];
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

