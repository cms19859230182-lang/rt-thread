/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Forced include for every file of the ESP-IDF v6.1 esp-idf group on ESP32-S3.
 *
 * components/esp_system/include/esp_ipc_isr.h switches the whole
 * esp_ipc_isr_*() family on `#ifdef CONFIG_ESP_IPC_ISR_ENABLE`, whose Kconfig
 * default is `y if !ESP_SYSTEM_SINGLE_CORE_MODE`. This BSP is single core
 * (CONFIG_ESP_SYSTEM_SINGLE_CORE_MODE, CONFIG_FREERTOS_UNICORE) and never
 * defines the symbol, so the header is meant to fall into its `#else` branch
 * and turn esp_ipc_isr_stall_other_cpu() / release_other_cpu() / stall_pause() /
 * stall_abort() / stall_resume() into empty macros.
 *
 * The Xtensa implementations the enabled branch declares live in
 * components/esp_system/port/esp_ipc_isr.c and
 * components/esp_system/port/arch/xtensa/esp_ipc_isr_{handler,port,routines}.{c,S},
 * none of which this BSP builds: on one core esp_ipc_isr.c calls its callbacks
 * directly instead of raising an inter-processor interrupt, so there is nothing
 * for an inter-processor ISR to do. PR #11844's build relied on that too.
 *
 * components/esp_system/port/panic_handler.c and
 * components/esp_system/port/soc/esp32s3/system_internal.c nevertheless call
 * esp_ipc_isr_stall_abort() unconditionally, so the `#else` branch is the one
 * that has to be compiled. Rather than depend on which <sdkconfig.h> the many
 * include dirs resolve to, clear the symbol first and then pull the header in
 * from here - this file is force-included (-include) ahead of every other
 * header of the translation unit, so the outcome no longer depends on
 * include order.
 */

#pragma once

#undef CONFIG_ESP_IPC_ISR_ENABLE

#include <esp_ipc_isr.h>

/* The `#else` branch above defines the whole family as empty macros. If the
   enabled branch was taken anyway the declarations below would be the ones the
   callers see, so make them no-ops here instead of leaving them unresolved. */
#ifndef esp_ipc_isr_stall_abort
#define esp_ipc_isr_stall_other_cpu()
#define esp_ipc_isr_release_other_cpu()
#define esp_ipc_isr_stall_pause()
#define esp_ipc_isr_stall_abort()
#define esp_ipc_isr_stall_resume()
#endif
