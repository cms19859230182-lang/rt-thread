/*
 * Link-compat shims for the ESP32-S3 BSP.
 *
 * The ESP32-C3 original also stubs out ceil()/floor() because the RISC-V
 * multilib setup pulls no libm; the Xtensa toolchain links real libm through
 * g++, so stubbing them here would silently mis-round IDF's math - they are
 * deliberately NOT stubbed in this BSP.
 *
 * _end/_edata: referenced by IDF heap/newlib sbrk glue but not emitted by the
 * esp32s3 sections.ld fragment (same situation as the C3 BSP handled here).
 *
 * opendir/readdir/closedir/select: newlib syscall entry points that would
 * otherwise resolve against the VFS component, which this BSP does not
 * compile (same rationale as ESP32-C3; kept because the xtensa newlib here is
 * the same fork-provided library).
 */
#include "rtconfig.h"

void _end(void)
{
    return;
}

void _edata(void)
{
    return;
}

#ifndef BSP_USING_BLE /* the BLE component brings VFS, which provides these */
void opendir(void)
{
    return;
}

void readdir(void)
{
    return;
}

void closedir(void)
{
    return;
}

void select(void)
{
    return;
}
#endif /* BSP_USING_BLE */

/*
 * Link-compat stubs for symbols the RT-Thread build has no other source for.
 *
 * The first group is all weak on purpose. ESP-IDF v6.1 *does* compile real
 * definitions for bootloader_sha256_* (bootloader_sha.c's app-build branch,
 * against <psa/crypto.h>) and esp_flash_encryption_enabled (flash_encrypt.c),
 * so these are only a fallback for a build that leaves those files out; a
 * strong definition here would be a duplicate-symbol link error. Prototypes per
 * components/bootloader_support/private_include/bootloader_sha.h.
 *
 * - task_wdt_timeout_abort_xtensa : esp_system/task_wdt.c compiles to nothing
 *   with CONFIG_ESP_TASK_WDT_INIT=0 (its xtensa abort path needs the real
 *   FreeRTOS snapshot API, absent in the RT-Thread wrapper), but
 *   esp_system/crosscore_int.c still references the symbol.
 * - uxTaskGetSnapshotAll : ESP-IDF v6.1 declares it in
 *   components/freertos/esp_additions/freertos_tasks_c_additions.h and
 *   implements it in the V11 kernel's tasks.c, which the FreeRTOS-Wrapper
 *   (V10.4.6) does not provide. components/esp_system/port/arch/xtensa/
 *   debug_helpers.c calls it unconditionally to walk the other cores' task
 *   backtraces; with a single core there is no other task list to walk, so
 *   report none rather than walking the wrapper's TCB (which is not the
 *   V11 layout the caller expects).
 * - _invalid_pc_placeholder : normally emitted by components/xtensa/
 *   xtensa_vectors.S, which this BSP does not build (libcpu/xtensa/esp32s3
 *   brings its own vectors). components/esp_system/port/panic_handler.c takes
 *   its address to patch a garbage PC so GDB does not fail to translate the
 *   frame; only the address matters.
 */
/*
 * Deliberately no FreeRTOS header here. The obvious way to spell
 * uxTaskGetSnapshotAll below is to include <freertos/task_snapshot.h> for
 * TaskSnapshot_t, but that header pulls in freertos/FreeRTOS.h and with it
 * newlib's sys/types.h -> sys/select.h, which declares the real
 * int select(...). That collides with the syscall stub above, in this very
 * file. The signature only crosses a translation-unit boundary, so matching
 * the ABI with plain integer/opaque-pointer types is enough.
 */
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

__attribute__((weak)) void *bootloader_sha256_start(void)
{
    return NULL;
}

__attribute__((weak)) void bootloader_sha256_data(void *handle, const void *data, size_t len)
{
    (void)handle;
    (void)data;
    (void)len;
}

__attribute__((weak)) void bootloader_sha256_finish(void *handle, uint8_t *digest)
{
    (void)handle;
    if (digest)
    {
        for (int i = 0; i < 32; i++)
        {
            digest[i] = 0;
        }
    }
}

__attribute__((weak)) bool esp_flash_encryption_enabled(void)
{
    return false;
}

void task_wdt_timeout_abort_xtensa(bool current_core)
{
    (void)current_core;
}

/* See the file header: the V11 kernel's task walk is not available, and this
   image runs on core 0 only, so there is no other core's task list to report.
   ABI of the V11 kernel's declaration:
       UBaseType_t uxTaskGetSnapshotAll(TaskSnapshot_t * const array,
                                        const UBaseType_t length,
                                        UBaseType_t * const pxTCBSize);
   so the third argument is the *TCB size* out-param, not a task count
   (debug_helpers.c passes NULL for it). */
__attribute__((weak)) unsigned int uxTaskGetSnapshotAll(void *pxTaskSnapshotArray,
                                                       unsigned int uxArraySize,
                                                       unsigned int *pxTCBSize)
{
    (void)pxTaskSnapshotArray;
    (void)uxArraySize;
    if (pxTCBSize)
    {
        *pxTCBSize = 0;
    }
    return 0;
}

/* GDB PC placeholder, see the file header. */
__attribute__((weak)) int _invalid_pc_placeholder;

/*
 * Debug aid while bringing the port up: esp_system_abort() is the common
 * funnel of abort()/ESP_ERROR_CHECK/assert and its panic path is silent
 * before the console exists. Linked via -Wl,--wrap=esp_system_abort (see
 * rtconfig.py): print the reason with the ROM printf, then halt.
 */
void __attribute__((noreturn)) __wrap_esp_system_abort(const char *details)
{
    extern int esp_rom_printf(const char *fmt, ...);
    esp_rom_printf("\nrt-s3: esp_system_abort: %s\n", details ? details : "(null)");
    for (;;)
    {
    }
}

/*
 * ESP32-S3 bring-up note (flash):
 * The fork's esp_flash_api.c esp_flash_init_main() fast path reads the chip id
 * out of the ROM legacy struct (rom_spiflash_legacy_data at 0x3fceffe4, struct
 * at 0x3fcef6a4). On this board the other fields (chip_size 8MB, sector 4KB,
 * status mask) survive, but device_id arrives 0, and the fork's live-RDID
 * fallback path (written around a C6 cache-suspend bug) ends in
 * ESP_ERR_NOT_FOUND at startup.c's assert. Until that fork bug is fixed
 * properly, this BSP bypasses default-chip init: the bootloader already mapped
 * the flash (partition table + app run through the cache), read-only access
 * needs no driver re-init, and v1 offers no flash write/OTA API.
 * -Wl,--wrap=esp_flash_init_default_chip routes startup.c's call here.
 */
typedef int esp_err_t;
esp_err_t __wrap_esp_flash_init_default_chip(void)
{
    return 0 /* ESP_OK */;
}
