# This specifies the executable from files in this subdirectory
add_executable(${PROJECT_NAME}_main main.c)

# Enable USB output, disable UART output (optional)
pico_enable_stdio_usb(${PROJECT_NAME}_main 1)
pico_enable_stdio_uart(${PROJECT_NAME}_main 0)

# Add extra outputs (UF2, HEX, BIN)
pico_add_extra_outputs(${PROJECT_NAME}_main)