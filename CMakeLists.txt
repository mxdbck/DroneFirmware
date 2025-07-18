cmake_minimum_required(VERSION 3.13)

# Initialize the Pico SDK
# This must happen before the project() command
include(~/Dev/pico/pico-sdk/pico_sdk_init.cmake)
pico_sdk_init()

# Define your project name
project(DroneFirmware C CXX ASM) # Enable C, C++, and Assembly

# Set compiler standards for safety and modern C++
set(CMAKE_C_STANDARD 17) # Or 11/14 for C, but 17 is good for modern C
set(CMAKE_CXX_STANDARD 20) # Modern C++ for better abstractions and safety features
set(CMAKE_CXX_EXTENSIONS OFF) # Enforce strict standard compliance

# Output compile commands for static analysis tools (like clang-tidy)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Define the board (important for RP2350 specific configs)
# https://wiki.seeedstudio.com/xiao-rp2350-c-cpp-sdk/
set(PICO_BOARD seeed_xiao_rp2350)

# # Add FreeRTOS
# # This must happen after pico_sdk_init() and before adding executables
# include($ENV{FREERTOS_KERNEL_PATH}/FreeRTOS_Kernel_import.cmake) # This file links FreeRTOS
# # Configure FreeRTOS for RP2350. The relevant FreeRTOS port is usually in FreeRTOS-Kernel/portable/GCC/ARM_CM33.
# # The FreeRTOSConfig.h will be project-specific.

# target_compile_definitions(${PROJECT_NAME} PUBLIC
#     # FREERTOS
#     RP2040_PICO_BOARD=1 # Keep this for compatibility, or check RP2350 specific defines
#     # Add other FreeRTOS configuration defines if needed, e.g., for MPU, TrustZone
# )

# Add your source files
# Best practice: organize source files in subdirectories (e.g., `src`, `tasks`, `drivers`).
# For simplicity, let's start with a single `main.c` and a `tasks` directory.
add_subdirectory(src)
# add_subdirectory(tasks) # Example for FreeRTOS tasks

# Add FreeRTOS-Kernel as a library to your project
# The FreeRTOS_Kernel_import.cmake should handle linking the core kernel.
# You might need to explicitly link the correct port if auto-detection fails.
# Example: target_link_libraries(${PROJECT_NAME} FreeRTOS-Kernel-Cortex-M33)



# Set common compile options for safety and warnings
target_compile_options(${PROJECT_NAME}_main PRIVATE
    -Wall                     # Enable all warnings
    -Wextra                   # Enable extra warnings
    # -Werror                   # Treat warnings as errors (CRITICAL for safety)
    -Wconversion              # Warn about implicit conversions that might lose data
    -Wcast-align              # Warn about pointer cast alignment issues
    # -Wpadded                  # Warn about struct padding (can reveal memory inefficiencies)
    -Wshadow                  # Warn when a local variable shadows another variable
    # -Wundef                   # Warn when an undefined identifier is used in an #if directive
    -Wstrict-aliasing=2       # Aggressive strict aliasing checks
    -Wunreachable-code        # Warn about unreachable code
    -Wredundant-decls         # Warn about redundant declarations
    -Wdouble-promotion        # Warn about implicit conversions from float to double
    -Wformat-security         # Warn about format string vulnerabilities
    -Wmissing-declarations    # Warn about missing function declarations
    -Wpointer-arith           # Warn about pointer arithmetic that is not type-safe
    -Wreturn-type             # Warn about functions that do not return a value when expected
    -Wno-unknown-pragmas      # Suppress warnings for unknown pragmas
    # -flto                     # Enable Link-Time Optimization (LTO) for smaller and faster code
    # -fno-builtin              # Do not use builtin functions (can reveal issues with non-standard behavior)
    -ffunction-sections       # Place each function in its own section (for garbage collection)
    -fdata-sections           # Place each data item in its own section
    
    # Apply C-specific warnings only to C files (eliminates C++ warnings)
    $<$<COMPILE_LANGUAGE:C>:-Wmissing-prototypes>
    $<$<COMPILE_LANGUAGE:C>:-Wold-style-definition>
)

# Link necessary Pico SDK libraries
# `pico_stdlib` is essential. Add others as needed (e.g., `hardware_i2c`, `hardware_spi`, `hardware_pwm`, `hardware_dma`, `hardware_pio`).
target_link_libraries(${PROJECT_NAME}_main
    pico_stdlib
    pico_sync         # For inter-core communication (spinlocks, semaphores)
    pico_multicore    # For starting tasks on core1
    # FreeRTOS-Kernel is often pulled in via the include(FreeRTOS_Kernel_import.cmake) directive,
    # but depending on the FreeRTOS version and port, you might need to explicitly link the port library.
    # Example: FreeRTOS::FreeRTOS-Kernel-Cortex-M33 or similar target defined by FreeRTOS's CMake.
    # Check FreeRTOS-Kernel/CMakeLists.txt for specific target names.
)
