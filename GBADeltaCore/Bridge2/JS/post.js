function _arrayBufferToString( buffer ) {
    var binary = '';
    var bytes = new Uint8Array( buffer );
    var len = bytes.byteLength;
    for (var i = 0; i < len; i++) {
        binary += String.fromCharCode( bytes[ i ] );
    }
    return binary;
}

function performStartUp()
{
    _GBAInitialize();
    
    var videoCallback = addFunction(function(offset, size) {
        var typedArray = HEAPU16.subarray(offset/2, offset/2 + size/2);
        
        
        var binary = '';
        var len = typedArray.length;
        for (var i = 0; i < len; i++) {
            binary += String.fromCharCode( typedArray[ i ] );
        }
        
        
//        var array = Array.from(typedArray);
//        var string = typedArray.map(function(i){return String.fromCharCode(i)}); //String.fromCharCode.apply(null, typedArray);
        window.webkit.messageHandlers.DLTAEmulatorBridge.postMessage({'type': 'video', 'data': binary});
    }, 'vii');
    
    _GBASetVideoCallback(videoCallback);
    
    var audioCallback = addFunction(function(offset, size) {
        var typedArray = HEAPU8.subarray(offset, offset + size);
        var binary = Array.from(typedArray);
        
//        var typedArray = HEAPU16.subarray(offset/2, offset/2 + size/2);
//
//        var binary = '';
//        var len = typedArray.length;
//        for (var i = 0; i < len; i++) {
//            binary += String.fromCharCode( typedArray[ i ] );
//        }
        
        window.webkit.messageHandlers.DLTAEmulatorBridge.postMessage({'type': 'audio', 'data': binary});
    }, 'vii');
    
    _GBASetAudioCallback(audioCallback);
    
    var saveCallback = addFunction(function() {
        window.webkit.messageHandlers.DLTAEmulatorBridge.postMessage({'type': 'save'});
    }, 'v');
    
    _GBASetSaveCallback(saveCallback);
    
    window.webkit.messageHandlers.DLTAEmulatorBridge.postMessage({'type': 'ready'});
}
