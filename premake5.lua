-- SDL_mixer Premake5 Module for Cinix
-- This script builds SDL_mixer as a static or shared library that can be included in other projects

project "SDL_mixer"
    kind "StaticLib" -- Default to static, can be overridden in main project
    language "C"
    cdialect "C99"
    
    targetname "SDL_mixer"
    
    -- Use the workspace's output directories by default
    targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.name}")
    objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.name}")
    
    -- Setup directories
    local MIXER_DIR = _SCRIPT_DIR
    local MIXER_SRC_DIR = MIXER_DIR .. "/src"
    local MIXER_INCLUDE_DIR = MIXER_DIR .. "/include"
    
    -- Include directories
    includedirs {
        MIXER_INCLUDE_DIR,
        "%{IncludeDir.SDL3}" -- Assumes IncludeDir.SDL3 is defined in main premake file
    }
    
    -- Core source files
    files {
        MIXER_SRC_DIR .. "/*.c",
        MIXER_SRC_DIR .. "/codecs/*.c",
        MIXER_INCLUDE_DIR .. "/*.h"
    }
    
    -- Use minimal set of codecs by default
    defines {
        "MUSIC_WAV",
        "MUSIC_OGG",
        "SDL_MIXER_DYNAMIC_API=0"
    }
    
    -- Static library config
    filter "kind:StaticLib"
        defines {
            "SDL_MIXER_STATIC_LIB"
        }
    
    -- Shared library config
    filter "kind:SharedLib"
        defines {
            "DLL_EXPORT",
            "SDL_MIXER_BUILDING_LIBRARY"
        }
        
        links {
            "SDL3"
        }
        
        filter {"kind:SharedLib", "system:linux"}
            linkoptions { "-Wl,-rpath,$ORIGIN" }
    
    -- Windows specific
    filter "system:windows"
        defines {
            "_WINDOWS",
            "UNICODE", 
            "_UNICODE"
        }
        
        -- Link with Windows specific libraries if needed
        links {
            "winmm"
        }
    
    -- Linux specific
    filter "system:linux"
        buildoptions { "-fPIC" }
        defines { "_REENTRANT" }
        
        -- Link with Linux specific libraries
        links {
            "m"
        }
    
    -- Debug configuration
    filter "configurations:Debug"
        defines { "DEBUG" }
        symbols "On"
    
    -- Release configuration
    filter "configurations:Release"
        defines { "NDEBUG" }
        optimize "On"
    
    -- Reset filter
    filter {}
    
    -- Additional codec support can be enabled with filters
    filter "options:mixer_mp3=true"
        defines { "MUSIC_MP3" }
        files { MIXER_SRC_DIR .. "/codecs/mp3.c" }
    
    filter "options:mixer_flac=true"
        defines { "MUSIC_FLAC" }
        files { MIXER_SRC_DIR .. "/codecs/flac.c" }
    
    filter "options:mixer_mod=true"
        defines { "MUSIC_MOD" }
        files { MIXER_SRC_DIR .. "/codecs/modplug.c" }
    
    filter "options:mixer_midi=true"
        defines { "MUSIC_MIDI" }
        files { 
            MIXER_SRC_DIR .. "/codecs/timidity/*.c",
            MIXER_SRC_DIR .. "/codecs/native_midi/*.c"
        }
    
    -- Reset filter
    filter {}
