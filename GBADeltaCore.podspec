Pod::Spec.new do |spec|
  spec.name         = "GBADeltaCore"
  spec.version      = "0.1"
  spec.summary      = "Game Boy Advance plug-in for Delta emulator."
  spec.description  = "iOS framework that wraps VBA-M to allow playing Game Boy Advance games with Delta emulator."
  spec.homepage     = "https://github.com/rileytestut/GBADeltaCore"
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => "https://github.com/rileytestut/GBADeltaCore.git" }

  spec.author             = { "Riley Testut" => "riley@rileytestut.com" }
  spec.social_media_url   = "https://twitter.com/rileytestut"
  
  spec.source_files  = "GBADeltaCore/**/*.{h,m,mm,swift}", "visualboyadvance-m/src/*.h", "visualboyadvance-m/src/common/*.h", "visualboyadvance-m/src/sdl/*.h", "visualboyadvance-m/src/gba/*.h", "SFML/include/**/*.{h,hpp,inl}", "SFML/src/SFML/System/{Err,Time,Thread,String}.cpp", "SFML/src/SFML/System/Unix/ThreadImpl.{hpp,cpp}"
  spec.public_header_files = "GBADeltaCore/Types/GBATypes.h", "GBADeltaCore/Bridge/GBAEmulatorBridge.h", "GBADeltaCore/GBADeltaCore.h"
  spec.header_mappings_dir = ""
  spec.resource_bundles = {
    "GBADeltaCore" => ["GBADeltaCore/**/*.deltamapping", "GBADeltaCore/**/*.deltaskin", "visualboyadvance-m/src/vba-over.ini"]
  }
  
  spec.dependency 'DeltaCore'
  
  spec.xcconfig = {
    "HEADER_SEARCH_PATHS" => '"${PODS_CONFIGURATION_BUILD_DIR}" "$(PODS_ROOT)/Headers/Private/GBADeltaCore/SFML/include" "$(PODS_ROOT)/Headers/Private/GBADeltaCore/SFML/src"',
    "USER_HEADER_SEARCH_PATHS" => '"$(PODS_ROOT)/Headers/Private/GBADeltaCore/visualboyadvance-m/fex" "$(PODS_ROOT)/Headers/Private/GBADeltaCore/visualboyadvance-m/src"',
    "GCC_PREPROCESSOR_DEFINITIONS" => "STATIC_LIBRARY=1"
  }
  
end
