// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GBADeltaCore",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "GBADeltaCore",
            targets: ["GBADeltaCore", "GBABridge", "VBA-M"]
        )
    ],
    dependencies: [
        .package(name: "DeltaCore", url: "https://github.com/rileytestut/DeltaCore.git", .branch("visionOS"))
    ],
    targets: [
        .target(
            name: "GBADeltaCore",
            dependencies: ["DeltaCore", "GBABridge", "VBA-M"],
            path: "GBADeltaCore",
            exclude: [
                "GBADeltaCore.h",
                "Info.plist",
                
                "Bridge",
                "Types",
                
                "Controller Skin/info.json",
                "Controller Skin/iphone_portrait.pdf",
                "Controller Skin/iphone_landscape.pdf",
                "Controller Skin/iphone_edgetoedge_portrait.pdf",
                "Controller Skin/iphone_edgetoedge_landscape.pdf"
            ],
            sources: ["GBA.swift"],
            resources: [
                .copy("Controller Skin/Standard.deltaskin"),
                .copy("Standard.deltamapping"),
                .copy("vba-over.ini")
            ]
        ),
        .target(
            name: "GBABridge",
            dependencies: ["DeltaCore", "VBA-M"],
            path: "GBADeltaCore/Bridge",
            publicHeadersPath: "",
            cSettings: [
                .headerSearchPath("../../visualboyadvance-m/src"),
            ],
            linkerSettings: [
                .linkedFramework("CoreMotion")
            ]
        ),
        .target(
            name: "VBA-M",
            path: "",
            exclude: [
                "GBADeltaCore",
                "GBADeltaCore.podspec",
                
                "visualboyadvance-m/src/vba-over.ini",
                
                "visualboyadvance-m/src/common/ffmpeg.cpp",
                "visualboyadvance-m/src/common/SoundSDL.cpp",
                "visualboyadvance-m/src/gba/debugger-expr.l",
                "visualboyadvance-m/src/gba/debugger-expr.y",
                "visualboyadvance-m/src/gba/debugger-expr-lex.c",

                "visualboyadvance-m/dependencies",

                "SFML/src/SFML/Network/Win32",
                "SFML/src/SFML/Graphics",
                "SFML/src/SFML/Window",
                "SFML/src/SFML/Audio",
                "SFML/src/SFML/System/Android",
                "SFML/src/SFML/System/Win32",
                "SFML/src/SFML/Network/CMakeLists.txt",

                "SFML/include",
                
                "visualboyadvance-m/fex/changes.txt",
                "visualboyadvance-m/fex/CMakeLists.txt",
                "visualboyadvance-m/fex/fex.txt",
                "visualboyadvance-m/fex/internals.txt",
                "visualboyadvance-m/fex/license.txt",
                "visualboyadvance-m/fex/readme.txt",
                "visualboyadvance-m/fex/File_Extractor2010.sln",
                "visualboyadvance-m/fex/File_Extractor2010.vcxproj",
                "visualboyadvance-m/fex/File_Extractor2010.vcxproj.filters",
                "visualboyadvance-m/fex/File_Extractor2010.vcxproj.user",
                "visualboyadvance-m/fex/File_Extractor2013.vcxproj",
                "visualboyadvance-m/fex/File_Extractor2013.vcxproj.filters",
                "visualboyadvance-m/fex/7z_C/7zC.txt",
                "visualboyadvance-m/fex/7z_C/lzma.txt",

                "visualboyadvance-m/src/libretro",
                "visualboyadvance-m/src/filters",
                "visualboyadvance-m/src/debian",
                "visualboyadvance-m/po",
                "visualboyadvance-m/data",
                "visualboyadvance-m/project",
                "visualboyadvance-m/src/wx",
                "visualboyadvance-m/src/art",
                "visualboyadvance-m/src/sdl",
                "visualboyadvance-m/tools",
                "visualboyadvance-m/cmake",
                "visualboyadvance-m/doc",

                "visualboyadvance-m/src/version.h.in",

                "visualboyadvance-m/installer.nsi",
                "visualboyadvance-m/todo.md",
                "visualboyadvance-m/CMakeLists.txt",
                "visualboyadvance-m/CHANGELOG.md",
                "visualboyadvance-m/installdeps",
                "visualboyadvance-m/README.md",

                "SFML/src/SFML/System/Unix/ThreadImpl.hpp",
                "SFML/src/SFML/System/Unix/ThreadLocalImpl.hpp",
                "SFML/src/SFML/System/Unix/ThreadLocalImpl.cpp",
                "SFML/src/SFML/System/Unix/ClockImpl.hpp",
                "SFML/src/SFML/System/Unix/ClockImpl.cpp",
                "SFML/src/SFML/System/Unix/MutexImpl.hpp",
                "SFML/src/SFML/System/Unix/MutexImpl.cpp",
                "SFML/src/SFML/System/Unix/SleepImpl.hpp",
                "SFML/src/SFML/System/Unix/SleepImpl.cpp",

                "SFML/src/SFML/System/Clock.cpp",
                "SFML/src/SFML/System/Sleep.cpp",
                "SFML/src/SFML/System/FileInputStream.cpp",
                "SFML/src/SFML/System/CMakeLists.txt",
                "SFML/src/SFML/System/ThreadLocal.cpp",
                "SFML/src/SFML/System/Lock.cpp",
                "SFML/src/SFML/System/Mutex.cpp",
                "SFML/src/SFML/System/MemoryInputStream.cpp",

                "SFML/src/SFML/CMakeLists.txt",
                "SFML/src/SFML/Main",
                "SFML/src/SFML/System/Unix/SleepImpl.cpp",
                "SFML/src/SFML/Android.mk",
            ],
            sources: [
                "visualboyadvance-m/fex",
                "visualboyadvance-m/src/apu",
                "visualboyadvance-m/src/common",
                "visualboyadvance-m/src/gba",
                "visualboyadvance-m/src/gb",
                "visualboyadvance-m/src/Util.cpp",

                "SFML/src/SFML/Network",
                "SFML/src/SFML/System/Err.cpp",
                "SFML/src/SFML/System/Time.cpp",
                "SFML/src/SFML/System/Thread.cpp",
                "SFML/src/SFML/System/String.cpp",
                "SFML/src/SFML/System/Unix/ThreadImpl.cpp"
            ],
            cSettings: [
                .headerSearchPath("visualboyadvance-m/fex"),
                .headerSearchPath("SFML/include"),
                .headerSearchPath("SFML/src"),

                .define("C_CORE"),
                .define("NO_PNG"),
                .define("FINAL_VERSION"),
                .define("PKGDATADIR"),
                .define("SYSCONF_INSTALL_DIR"),
                .define("NO_DEBUGGER"),
                .define("BKPT_SUPPORT"),
                .define("HAVE_ARPA_INET_H"),
            ]
        )
    ]
)
