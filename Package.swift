// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GBADeltaCore",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GBADeltaCore",
//            type: .dynamic,
            targets: ["GBADeltaCore"]),
//        
//        .library(name: "SFML", type: .dynamic, targets: ["SFML"]),
//        
//        .library(name: "VBA-M", type: .dynamic, targets: ["VBA-M"]),
//        
//        .library(name: "GBABridge", targets: ["GBABridge"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "DeltaCore", path: "../DeltaCore")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GBADeltaCore",
            dependencies: ["DeltaCore", "GBABridge", "VBA-M"],
            resources: [
                .copy("Resources/Controller Skin/Standard.deltaskin"),
                .copy("Resources/Standard.deltamapping"),
            ]
        ),
        .target(
            name: "GBABridge",
            dependencies: ["DeltaCore", "VBA-M"],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("../VBA-M/visualboyadvance-m/src"),
                .unsafeFlags(["-fmodules", "-fcxx-modules"])
            ]
        ),
        .target(
            name: "VBA-M",
            exclude: [
                "visualboyadvance-m/src/common/ffmpeg.cpp",
                "visualboyadvance-m/src/common/SoundSDL.cpp",
                "visualboyadvance-m/src/gba/debugger-expr.l",
                "visualboyadvance-m/src/gba/debugger-expr.y",
                "visualboyadvance-m/src/gba/debugger-expr.c",
                "visualboyadvance-m/src/gba/debugger-expr-lex.c",
                
                "SFML/src/SFML/Network/Win32",
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
//        .target(
//            name: "SFML",
//            exclude: [
//                "src/SFML/Network/Win32",
//            ],
//            sources: [
//                "src/SFML/Network",
//                "src/SFML/System/Err.cpp",
//                "src/SFML/System/Time.cpp",
//                "src/SFML/System/Thread.cpp",
//                "src/SFML/System/String.cpp",
//                "src/SFML/System/Unix/ThreadImpl.cpp"
//            ],
//            publicHeadersPath: "",
//            cSettings: [
//                .headerSearchPath("include"),
//                .headerSearchPath("src")
//            ]
//        ),
    ]
)
