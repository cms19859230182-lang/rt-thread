/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * ESP32-S3 linker script memory layout for the RT-Thread BSP.
 *
 * Generated from the ESP-IDF v6.1 templates
 *   components/esp_system/ld/esp32s3/memory.ld.in
 *   components/esp_system/ld/ld.common
 * with the configuration this BSP builds with (ESP32-S3, app build type "app",
 * flash sections on, no secure boot / flash encryption, no ULP coprocessor, no
 * PSRAM, newlib rather than picolibc).  The result is pre-resolved on purpose:
 * it is handed straight to the linker with -T, so it must not contain any
 * #if / #include / object-like macro, exactly like the ESP32-C3/C6 scripts.
 *
 * Do not edit by hand - regenerate when the ESP-IDF version changes.
 */

/* CONFIG_* supplied by the generator */

/* CONFIG_* supplied by the generator */

MEMORY
{

 iram0_0_seg (RX) : org = (0x40370000 + 0x4000), len = (((0x403CB700 - (0x40378000 - 0x3FC88000)) - 0x3FC88000) + 0x8000 - 0x4000)

 iram0_2_seg (RX) : org = 0x42000020, len = 0x800000-0x20

 dram0_0_seg (RW) : org = (0x3FC88000), len = ((0x403CB700 - (0x40378000 - 0x3FC88000)) - 0x3FC88000)

 drom0_0_seg (R) : org = 0x3C000020, len = 0x2000000-0x20

 rtc_iram_seg(RWX) : org = 0x600fe000, len = 0x2000 - (0 + (24) + 0)

 rtc_reserved_seg(RW) : org = 0x600fe000 + 0x2000 - (0 + (24) + 0), len = (0 + (24) + 0)

 rtc_slow_seg(RW) : org = 0x50000000 , len = 0x2000

 extern_ram_seg(RWX) : org = 0x3c000020 , len = 0x2000000-0x20
}

_diram_i_start = 0x40378000;

_heap_start = _heap_low_start;

_heap_end = 0x40000000;

REGION_ALIAS("rtc_data_seg", rtc_iram_seg );

REGION_ALIAS("rtc_data_location", rtc_slow_seg );

REGION_ALIAS("default_code_seg", iram0_2_seg);

REGION_ALIAS("default_rodata_seg", drom0_0_seg);

 ASSERT(_flash_rodata_dummy_start == ORIGIN(default_rodata_seg),
 ".flash_rodata_dummy section must be placed at the beginning of the rodata segment.")

