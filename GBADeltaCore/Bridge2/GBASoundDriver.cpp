//
//  DeltaSoundDriver.cpp
//  GBADeltaCore
//
//  Created by Riley Testut on 6/3/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

#import "GBASoundDriver.h"

#include <sstream>

#if __EMSCRIPTEN__

extern "C"
{
#include <emscripten/emscripten.h>
#include <emscripten/websocket.h>

EM_BOOL onopen(int eventType, const EmscriptenWebSocketOpenEvent *websocketEvent, void *userData) {
    puts("onopen");

    EMSCRIPTEN_RESULT result;
    result = emscripten_websocket_send_utf8_text(websocketEvent->socket, "hoge");
    if (result) {
        printf("Failed to emscripten_websocket_send_utf8_text(): %d\n", result);
    }
    return EM_TRUE;
}
EM_BOOL onerror(int eventType, const EmscriptenWebSocketErrorEvent *websocketEvent, void *userData) {
    puts("onerror");

    return EM_TRUE;
}
EM_BOOL onclose(int eventType, const EmscriptenWebSocketCloseEvent *websocketEvent, void *userData) {
    puts("onclose");

    return EM_TRUE;
}
EM_BOOL onmessage(int eventType, const EmscriptenWebSocketMessageEvent *websocketEvent, void *userData) {
    puts("onmessage");
    if (websocketEvent->isText) {
        // For only ascii chars.
        printf("message: %s\n", websocketEvent->data);
    }

    EMSCRIPTEN_RESULT result;
    result = emscripten_websocket_close(websocketEvent->socket, 1000, "no reason");
    if (result) {
        printf("Failed to emscripten_websocket_close(): %d\n", result);
    }
    return EM_TRUE;
}
}

#endif

GBASoundDriver::GBASoundDriver()
{
#if __EMSCRIPTEN__
#endif
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
    
    printf("[RSTLog] Sound Test 2: %p\n", finalWave);
    
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
