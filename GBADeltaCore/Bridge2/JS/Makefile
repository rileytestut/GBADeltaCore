SRC_DIR := ../../..
BUILD_DIR := build

CC = /Users/rileytestut/Developer/Tools/emsdk/upstream/emscripten/emcc
CXX = /Users/rileytestut/Developer/Tools/emsdk/upstream/emscripten/em++

CXXFLAGS = -O3 -std=c++11 -DC_CORE -DNO_PNG -DFINAL_VERSION -DPKGDATADIR -DSYSCONF_INSTALL_DIR -DNO_DEBUGGER -DBKPT_SUPPORT -DHAVE_ARPA_INET_H -D__linux__ -D__LITTLE_ENDIAN__ -I$(SRC_DIR)/visualboyadvance-m/src -I$(SRC_DIR)/visualboyadvance-m/dependencies/zlib -I../../../SFML/include -I../../../SFML/src -I$(SRC_DIR)/visualboyadvance-m/fex -fPIC #-D__APPLE__ -D__arm__ -D__arm64__ -D__MACH__ -D__APPLE_CPP__ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -isystem /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include

INCLUDE := -I../../../visualboyadvance-m/src -I../../../visualboyadvance-m/dependencies/zlib -I../../../SFML/include -I../../../SFML/src -I../../../visualboyadvance-m/fex #-I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include -I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1

SOURCES := \
	$(wildcard ../*.cpp) \
	$(wildcard ../../../visualboyadvance-m/fex/fex/*.cpp) \
	$(wildcard ../../../visualboyadvance-m/fex/7z_C/*.c) \
	$(wildcard ../../../visualboyadvance-m/src/apu/*.cpp) \
	$(wildcard ../../../visualboyadvance-m/src/common/*.c) \
	$(wildcard ../../../visualboyadvance-m/src/common/*.cpp) \
	$(wildcard ../../../visualboyadvance-m/src/gba/*.cpp) \
	$(wildcard ../../../visualboyadvance-m/src/gb/*.cpp) \
	$(wildcard ../../../visualboyadvance-m/src/Util.cpp) \
	$(wildcard ../../../SFML/src/SFML/Network/*.cpp) \
	$(wildcard ../../../SFML/src/SFML/Network/Unix/SocketImpl.cpp) \
	$(wildcard ../../../SFML/src/SFML/System/Err.cpp) \
	$(wildcard ../../../SFML/src/SFML/System/Time.cpp) \
	$(wildcard ../../../SFML/src/SFML/System/String.cpp) \
	$(wildcard ../../../SFML/src/SFML/System/Unix/ThreadImpl.cpp) \
	
SOURCES := $(filter-out %/ffmpeg.cpp %/SoundSDL.cpp %/ThreadLocalImpl.cpp %/ClockImpl.cpp %/MutexImpl.cpp %/SleepImpl.cpp %/Clock.cpp %/Sleep.cpp %/FileInputStream.cpp %/ThreadLocal.cpp %/Lock.cpp %/Mutex.cpp %/MemoryInputStream.cpp %/adler32.c %/memgzio.c, $(SOURCES) )

OBJ := $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SOURCES) )
	
ZLIB_SOURCES := \
	$(wildcard ../../../visualboyadvance-m/dependencies/zlib/*.c) \
	$(wildcard ../../../visualboyadvance-m/src/common/memgzio.c) \
	
ZLIB_OBJ := $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(ZLIB_SOURCES) )

EXPORTED_FUNCS = \
	"_main", \
    "_GBAFrameDuration", \
	"_GBAInitialize", \
	"_GBAStartEmulation", \
	"_GBAStopEmulation", \
	"_GBARunFrame", \
	"_GBAActivateInput", \
	"_GBADeactivateInput", \
	"_GBAResetInputs", \
	"_GBASaveSaveState", \
	"_GBALoadSaveState", \
	"_GBASaveGameSave", \
	"_GBALoadGameSave", \
	"_GBAAddCheatCode", \
	"_GBAResetCheats", \
	"_GBASetAudioCallback", \
	"_GBASetVideoCallback", \
	"_GBASetSaveCallback"
	#"GBASoundDriver"
	
ZLIB_EXPORTED_FUNCS = \
	"_memgzclose"

EXPORTED_RUNTIME_FUNCS = \
	"ccall", \
	"allocate", \
	"intArrayFromString", \
	"FS", \
	"writeFile", \
	"readFile", \
	"HEAPU8", \
	"addFunction", \
	"ALLOC_NORMAL", \
	"getValue", \
	"stat", \
	"printErr"
	#"GBASoundDriver"


#EMFLAGS = --memory-init-file 0 --post-js post.js --embed-file NstDatabase.xml -s WASM=0 -s EXPORTED_FUNCTIONS='[$(EXPORTED_FUNCS)]' -s EXTRA_EXPORTED_RUNTIME_METHODS='[$(EXPORTED_RUNTIME_FUNCS)]' -s RESERVED_FUNCTION_POINTERS=5

#-s ALLOW_TABLE_GROWTH

EMFLAGS = --memory-init-file 0 -s WASM=0 --post-js post.js -s EXPORTED_FUNCTIONS='[$(EXPORTED_FUNCS)]' -s EXPORTED_RUNTIME_METHODS='[$(EXPORTED_RUNTIME_FUNCS)]' -s ENVIRONMENT=web -s RESERVED_FUNCTION_POINTERS=5 -s ALLOW_MEMORY_GROWTH=1 -s FORCE_FILESYSTEM=1 -s ASSERTIONS=2 -s INITIAL_MEMORY=200MB -s TOTAL_STACK=20MB -s STACK_OVERFLOW_CHECK=1 -s EXPORT_ALL=1 -s DEMANGLE_SUPPORT=1 -lwebsocket.js #-s SAFE_HEAP_LOG=1

#ZLIB_FLAGS = -std=c99 -s WASM=0 -s EXPORTED_FUNCTIONS='[$(ZLIB_EXPORTED_FUNCS)]'

build: $(ZLIB_OBJ) $(OBJ)
	#emcc tests/sdl2glshader.c -s USE_SDL=2 -s LEGACY_GL_EMULATION=1 -o sdl2.html
	echo "Hello World! 1111"
	$(CXX) $(CXXFLAGS) $(EMFLAGS) $(OBJ) $(ZLIB_OBJ) -o vbam.html
	echo "Hello World! 2222"
	#$(CXX) vbam.o zlib.a vbam.js
	
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) $(EMFLAGS) $(INCLUDES) -fsanitize=undefined -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	mkdir -p $(@D)
	$(CC) $(CXXFLAGS) $(EMFLAGS) $(INCLUDES) -fsanitize=undefined -c $< -o $@

clean:
	-@rm -rvf vbam.js
