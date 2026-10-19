/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * ESP32-S3 linker script sections for the RT-Thread BSP.
 *
 * Generated from the ESP-IDF v6.1 templates
 *   components/esp_system/ld/esp32s3/sections.ld.in
 *   components/esp_system/ld/ld.common
 *   components/esp_system/ld/ld.debug.sections
 *   components/esp_system/ld/ld.discard.sections
 * with the configuration this BSP builds with (see idf_port/ld/memory.ld).
 * Pre-resolved on purpose: it is handed straight to the linker with -T.
 *
 * The single hand-written addition is the RT-Thread system heap below, which
 * mirrors the block the ESP32-C3 BSP adds to its own sections.ld.  The fork's
 * esp_system/startup.c calls
 *     rt_system_heap_init(&__heap_start__, &__heap_end__);
 * and ESP-IDF's generated script exposes no such symbols (it publishes
 * _heap_low_start / _heap_end for heap_caps instead).  The block is carved out
 * of DRAM between .noinit and .bss so the linker can account for it.
 *
 * Do not edit by hand - regenerate when the ESP-IDF version changes.
 */

/* CONFIG_* supplied by the generator */

ENTRY(call_start_cpu0);

SECTIONS
{

 .rtc.text :
 {

 . = ALIGN(4);
 _rtc_fast_start = ABSOLUTE(.);

 . = ALIGN(4);
 _rtc_text_start = ABSOLUTE(.);

 HIDDEN(_rtc_code_start = .);

 *(.rtc.entry.literal .rtc.entry.text)

 arrays[rtc_text]
 mapping[rtc_text]
 mutable[rtc_text]

 /* Same missing-mapping story as the other sections: the Xtensa RTC wake stubs
    and the generated .rtc.text.<n> level sections would otherwise be orphans. */
 *(.rtc.literal .rtc.text .rtc.text.*)

 *rtc_wake_stub*.*(.literal .text .literal.* .text.*)
 *(.rtc_text_end_test)

 HIDDEN(_rtc_code_end = .);

 . = ((_rtc_code_end - _rtc_code_start) == 0) ?
 ALIGN(0) : 0 + ALIGN(4);

 _rtc_text_end = ABSOLUTE(.);
 } > rtc_iram_seg

 .rtc.force_fast :
 {

 . = ALIGN(4);
 _rtc_force_fast_start = ABSOLUTE(.);

 arrays[rtc_force_fast]
 mapping[rtc_force_fast]
 mutable[rtc_force_fast]

 *(.rtc.force_fast .rtc.force_fast.*)

 . = ALIGN(4);
 _rtc_force_fast_end = ABSOLUTE(.);
 } > rtc_data_seg

 .rtc.data :
 {
 _rtc_data_start = ABSOLUTE(.);

 arrays[rtc_data]
 mapping[rtc_data]
 mutable[rtc_data]

 *rtc_wake_stub*.*(.data .rodata .data.* .rodata.*)

 _rtc_data_end = ABSOLUTE(.);
 } > rtc_data_location

 .rtc.bss (NOLOAD) :
 {
 _rtc_bss_start = ABSOLUTE(.);

 *rtc_wake_stub*.*(.bss .bss.*)
 *rtc_wake_stub*.*(COMMON)

 arrays[rtc_bss]
 mapping[rtc_bss]
 mutable[rtc_bss]

 _rtc_bss_end = ABSOLUTE(.);
 } > rtc_data_location

 .rtc_noinit (NOLOAD):
 {

 . = ALIGN(4);
 _rtc_noinit_start = ABSOLUTE(.);

 arrays[rtc_noinit]
 mapping[rtc_noinit]
 mutable[rtc_noinit]

 *(.rtc_noinit .rtc_noinit.*)

 . = ALIGN(4);
 _rtc_noinit_end = ABSOLUTE(.);
 } > rtc_data_location

 .rtc.force_slow :
 {

 . = ALIGN(4);
 _rtc_force_slow_start = ABSOLUTE(.);

 *(.rtc.force_slow .rtc.force_slow.*)

 . = ALIGN(4);
 _rtc_force_slow_end = ABSOLUTE(.);
 } > rtc_slow_seg

 .rtc_reserved (NOLOAD):
 {

 . = ALIGN(4);
 _rtc_reserved_start = ABSOLUTE(.);

 *(.rtc_timer_data_in_rtc_mem .rtc_timer_data_in_rtc_mem.*)
 KEEP(*(.bootloader_data_rtc_mem .bootloader_data_rtc_mem.*))

 _rtc_reserved_end = ABSOLUTE(.);
 } > rtc_reserved_seg

 _rtc_reserved_length = _rtc_reserved_end - _rtc_reserved_start;
 ASSERT((_rtc_reserved_length <= LENGTH(rtc_reserved_seg)),
 "RTC reserved segment data does not fit.")

 _rtc_slow_length = (ORIGIN(rtc_slow_seg) == ORIGIN(rtc_data_location))
 ? (_rtc_force_slow_end - _rtc_data_start)
 : (_rtc_force_slow_end - _rtc_force_slow_start);

 _rtc_fast_length = (ORIGIN(rtc_slow_seg) == ORIGIN(rtc_data_location))
 ? (_rtc_force_fast_end - _rtc_fast_start)
 : (_rtc_noinit_end - _rtc_fast_start);

 ASSERT((_rtc_slow_length <= LENGTH(rtc_slow_seg)),
 "RTC_SLOW segment data does not fit.")

 ASSERT((_rtc_fast_length <= LENGTH(rtc_data_seg)),
 "RTC_FAST segment data does not fit.")

 .iram0.vectors :
 {
 _iram_start = ABSOLUTE(.);

 _vector_table = ABSOLUTE(.);
 . = 0x0;
 KEEP(*(.WindowVectors.text));
 . = 0x180;
 KEEP(*(.Level2InterruptVector.text));
 . = 0x1c0;
 KEEP(*(.Level3InterruptVector.text));
 . = 0x200;
 KEEP(*(.Level4InterruptVector.text));
 . = 0x240;
 KEEP(*(.Level5InterruptVector.text));
 . = 0x280;
 KEEP(*(.DebugExceptionVector.text));
 . = 0x2c0;
 KEEP(*(.NMIExceptionVector.text));
 . = 0x300;
 KEEP(*(.KernelExceptionVector.text));
 . = 0x340;
 KEEP(*(.UserExceptionVector.text));
 . = 0x3C0;
 KEEP(*(.DoubleExceptionVector.text));
 . = 0x400;
 KEEP(*(._invalid_pc_placeholder.text));

 *(.*Vector.literal)
 } > iram0_0_seg

 .iram0.text :
 {

 _iram_text_start = ABSOLUTE(.);

 /* ESP-IDF v6.1 leaves the input-section patterns of this section to the
   arrays[]/mapping[]/mutable[] mappings emitted by SECTION_MAPPINGS(), but
   no released esp_system/ld file ever gives those mappings any content for
   esp32s3 (esp32s3/sections.ld.in does not include ld.iram.sections /
   ld.dram.sections, and ld.common only defines the macro). Without them the
   input sections become orphans and the linker drops them into whatever
   region fits first - .bss landed in the 24 byte rtc_reserved_seg. The
   patterns are spelled out here so the placement is explicit. */

    *(.iram1 .iram1.*) *(.iram .iram.*)

 arrays[iram0_text]
 mapping[iram0_text]
 mutable[iram0_text]

 } > iram0_0_seg

 .dram0.dummy (NOLOAD):
 {
 . = ORIGIN(dram0_0_seg) + ((_iram_end > _diram_i_start) ? (_iram_end - _diram_i_start) : 0);
 } > dram0_0_seg

 .dram0.data :
 {
 _data_start = ABSOLUTE(.);
 *(.gnu.linkonce.d.*)
 *(.data1)
 *(.sdata)
 *(.sdata.*)
 *(.gnu.linkonce.s.*)
 *(.gnu.linkonce.s2.*)
 *(.jcr)

 /* Same story as .iram0.text: without these the .data* inputs have no home and
    become orphan output sections. That is worse than a wasted hole here - the
    linker put them in the DROM (flash) region in front of .flash.rodata, so
    every writable libc global (_impure_data, __global_locale_ptr, environ,
    __sglue ...) would live in read-only mapped flash and silently lose its
    writes. */
 *(.data .data.*)

 /* .dram1.<n> holds DRAM_ATTR writable data that must live in internal RAM.
    Collecting it here also prevents orphan output sections that broke DROM
    contiguity required by esptool's 64KB flash mapping. */
 *(.dram1 .dram1.*)

 arrays[dram0_data]
 mapping[dram0_data]
 mutable[dram0_data]

 _data_end = ABSOLUTE(.);
 } > dram0_0_seg

 .noinit (NOLOAD):
 {

 . = ALIGN(4);
 _noinit_start = ABSOLUTE(.);

 *(.noinit .noinit.*)

 . = ALIGN(4);
 _noinit_end = ABSOLUTE(.);
 } > dram0_0_seg

 /* RT-Thread system heap, carved out of DRAM before .bss. See the file
  * header: this mirrors the block the ESP32-C3 BSP applies to its
  * sections.ld. The size is NOT the C3 value any more: ESP-IDF v6.1's
  * esp32s3 layout gives dram0_0_seg 0x53700 bytes (org 0x3FC88000, end
  * 0x3FCDB700 - the 2nd stage bootloader owns everything above it), and the
  * v6.1 S3 image needs 345216 bytes of static DRAM there, i.e. 3456 over
  * budget. The heap is the one part of dram0_0_seg that is pure headroom, so
  * it is what absorbs the difference: 76800 - 8192 = 68608 bytes, which leaves
  * ~6.8 KB of slack. Re-tune once there is hardware to run the app on. */
 .heap (NOLOAD) :
 {
 . = ALIGN(8);
 __HEAPSIZE__ = 68608;
 __heap_start__ = .;
 . += __HEAPSIZE__;
 __heap_end__ = .;
 } > dram0_0_seg

 .dram0.bss (NOLOAD) :
 {

 . = ALIGN(8);
 _bss_start = ABSOLUTE(.);

 /* ESP-IDF v6.1 leaves the input-section patterns of this section to the
   arrays[]/mapping[]/mutable[] mappings emitted by SECTION_MAPPINGS(), but
   no released esp_system/ld file ever gives those mappings any content for
   esp32s3 (esp32s3/sections.ld.in does not include ld.iram.sections /
   ld.dram.sections, and ld.common only defines the macro). Without them the
   input sections become orphans and the linker drops them into whatever
   region fits first - .bss landed in the 24 byte rtc_reserved_seg. The
   patterns are spelled out here so the placement is explicit. */

    *(.bss .bss.*)
    *(.dynsbss)
    *(.sbss)
    *(.sbss.*)
    *(.gnu.linkonce.sb.*)
    *(.scommon)
    *(.sbss2)
    *(.sbss2.*)
    *(.gnu.linkonce.sb2.*)
    *(.dynbss)
    *(.share.mem)
    *(.gnu.linkonce.b.*)

 arrays[dram0_bss]
 mapping[dram0_bss]
 mutable[dram0_bss]

 . = ALIGN(16);
 _bss_end = ABSOLUTE(.);
 } > dram0_0_seg

 ASSERT(((_bss_end - ORIGIN(dram0_0_seg)) <= LENGTH(dram0_0_seg)),
 "DRAM segment data does not fit.")

 .flash.text :
 {
 _stext = .;

 _instruction_reserved_start = ABSOLUTE(.);
 _text_start = ABSOLUTE(.);

 arrays[flash_text]
 mapping[flash_text]
 mutable[flash_text]

 /* Xtensa puts every function body in .text and each function's constant pool in
    the sibling .literal section; both have to land in the same output section
    so the linker can resolve the .literal -> .text+offset relocation. v6.1 leaves
    this list to the (never filled) flash_text mappings, and the orphans ended up
    as separate .text / .literal output sections inside iram0_0_seg instead. */
 *(.literal .text .literal.* .text.*)

 *(.stub)
 *(.gnu.warning)
 *(.gnu.linkonce.literal.* .gnu.linkonce.t.*.literal .gnu.linkonce.t.*)
 *(.irom0.text)

 . += 16;

 _text_end = ABSOLUTE(.);

 _instruction_reserved_end = ABSOLUTE(.);
 _etext = .;

 _flash_cache_start = ABSOLUTE(0);
 } > default_code_seg

 .flash_rodata_dummy (NOLOAD):
 {
 _flash_rodata_dummy_start = ABSOLUTE(.);

 . = ALIGN(ALIGNOF(.flash.text)) + SIZEOF(.flash.text);

 . = ALIGN(0x8000) + 0x20;
 } > default_rodata_seg

 .flash.appdesc : ALIGN(0x10)
 {

 _rodata_reserved_start = ABSOLUTE(.);
 _rodata_start = ABSOLUTE(.);

 *(.rodata_desc .rodata_desc.*)

 *(.rodata_custom_desc .rodata_custom_desc.*)

 . = ALIGN(ALIGNOF(.flash.rodata));
 } > default_rodata_seg
 ASSERT((ADDR(.flash.rodata) == ADDR(.flash.appdesc) + SIZEOF(.flash.appdesc)), "The gap between .flash.appdesc and .flash.rodata must not exist to produce the final bin image.")

 .flash.rodata : ALIGN(0x10)
 {
 _flash_rodata_start = ABSOLUTE(.);

 /* ESP-IDF v6.1 hands the input-section list of this section to
    SECTION_MAPPINGS(flash_rodata), but nothing ever fills those mappings in for
    esp32s3 (see the note on .iram0.text above), so the plain .rodata* inputs have
    to be named explicitly - otherwise they become orphan output sections that
    the linker drops between .flash.appdesc and .flash.rodata, which both wastes
    DROM and breaks the ASSERT_SECTIONS_GAP below (esptool needs the flash
    segments contiguous). */
 *(.rodata .rodata.*)

 /* RT-Thread finsh tables: MSH_CMD_EXPORT / MSH_CMD_EXPORT_ALIAS put one
    entry per command in FSymTab, and MS_VARI_ADAPT / MSH_CMD_EXPORT_VAR put
    variables in VSymTab. The shell walks the range between these symbols, so
    without these two lines msh would start with no commands at all. */
 . = ALIGN(8);
 __fsymtab_start = .;
 KEEP(*(FSymTab));
 __fsymtab_end = .;
 . = ALIGN(8);
 __vsymtab_start = .;
 KEEP(*(VSymTab));
 __vsymtab_end = .;
 . = ALIGN(8);
 /* RT-Thread component init table. INIT_*_EXPORT puts a function pointer in
    a .rti_fn.<level> section and the level markers ("0", "0.end", "1.end",
    "6.end") are emitted by src/components.c itself, so all that is needed
    here is to collect the entries in name order between those markers.
    Without this line every EXPORT is placed by an implicit rule out of order
    and the ranges the kernel walks come out empty: nothing registers (the
    "uart" serial device included), even though its code is linked in. */
 KEEP(*(SORT(.rti_fn*)));
 . = ALIGN(8);

 arrays[flash_rodata]
 mapping[flash_rodata]
 mutable[flash_rodata]

 /* components/esp_libc/src/esp_libc_clock.lf maps the clock descriptors that
    ESP_LIBC_CLOCK_DESC() registers into flash_rodata with
        esp_libc_clock_desc -> flash_rodata KEEP() SORT(name) SURROUND(esp_libc_clock_array)
    and esp_libc/src/time.c reads _esp_libc_clock_array_start from there. That
    linker fragment has no equivalent in a plain linker script, so spell the
    bracketing out here. In GNU ld the sort function belongs *inside* the input
    section list, hence KEEP(*(SORT_BY_NAME(...))) rather than two statements. */
 _esp_libc_clock_array_start = ABSOLUTE(.);
 KEEP(*(SORT_BY_NAME(.esp_libc_clock_desc)))
 _esp_libc_clock_array_end = ABSOLUTE(.);

 *(.irom1.text)
 *(.gnu.linkonce.r.*)
 *(.rodata1)

 . = ALIGN(4);
 __XT_EXCEPTION_TABLE_ = ABSOLUTE(.);
 *(.xt_except_table)
 *(.gcc_except_table .gcc_except_table.*)
 *(.gnu.linkonce.e.*)

 . = ALIGN(4);
 __XT_EXCEPTION_DESCS_ = ABSOLUTE(.);
 *(.xt_except_desc)
 *(.gnu.linkonce.h.*)
 __XT_EXCEPTION_DESCS_END__ = ABSOLUTE(.);
 *(.xt_except_desc_end)

 . = ALIGN(4);
 __preinit_array_start = ABSOLUTE(.);

 . = ALIGN(4);
 __bothinit_array_start = ABSOLUTE(.);
 KEEP (*(.preinit_array))
 __preinit_array_end = ABSOLUTE(.);

 . = ALIGN(4);
 __init_array_start = ABSOLUTE(.);
 KEEP (*(SORT_BY_INIT_PRIORITY(EXCLUDE_FILE (*crtend.* *crtbegin.*) .ctors.*)))
 KEEP (*(EXCLUDE_FILE (*crtend.* *crtbegin.*) .ctors))
 __init_array_end = ABSOLUTE(.);
 __bothinit_array_end = ABSOLUTE(.);

 . = ALIGN(4);
 soc_reserved_memory_region_start = ABSOLUTE(.);
 KEEP (*(.reserved_memory_address))
 soc_reserved_memory_region_end = ABSOLUTE(.);

 . = ALIGN(4);
 _esp_sys_init_fn_start = ABSOLUTE(.);
 KEEP (*(SORT_BY_INIT_PRIORITY(.esp_sys_init_fn.*)))
 _esp_sys_init_fn_end = ABSOLUTE(.);

 _rodata_end = ABSOLUTE(.);

 _lit4_start = ABSOLUTE(.);
 *(*.lit4)
 *(.lit4.*)
 *(.gnu.linkonce.lit4.*)
 _lit4_end = ABSOLUTE(.);
 . = ALIGN(ALIGNOF(.flash.tdata));
 } > default_rodata_seg
 ASSERT((ADDR(.flash.tdata) == ADDR(.flash.rodata) + SIZEOF(.flash.rodata)), "The gap between .flash.rodata and .flash.tdata must not exist to produce the final bin image.")

/* ld.common only emits the .eh_frame output section when
   EH_FRAME_LINKING_ENABLED, i.e. when CONFIG_COMPILER_CXX_EXCEPTIONS or
   CONFIG_ESP_SYSTEM_USE_EH_FRAME is set.  sdkconfig_s3.h leaves both off for
   this console-only BSP (CONFIG_ESP_SYSTEM_USE_EH_FRAME sits behind
   BSP_USING_WIFI/BLE, exactly as in the ESP32-C3 block of ../../../sdkconfig.h),
   so EH_FRAME_LINKING_ENABLED is 0, SECTION_AFTER_FLASH_RODATA is
   .flash.tdata (which is what the ASSERT above already assumes), and there is
   no .eh_frame section in between.  Nothing here builds with -funwind-tables,
   so no .eh_frame input sections are produced either. */

 .flash.tdata :
 {

 _thread_local_data_start = ABSOLUTE(.);
 *(.tdata .tdata.* .gnu.linkonce.td.*)
 _thread_local_data_end = ABSOLUTE(.);

 _thread_local_bss_start = ABSOLUTE(.);
 *(.tbss .tbss.* .gnu.linkonce.tb.*)
 *(.tcommon .tcommon.*)
 _thread_local_bss_end = ABSOLUTE(.);
 } > default_rodata_seg
 _tls_section_alignment = ALIGNOF(.flash.tdata);

 ASSERT(_thread_local_data_end == _thread_local_bss_start,
 "tdata and tbss must be contiguous.")

 .flash.rodata_noload (NOLOAD) :
 {

 _rodata_reserved_end = ABSOLUTE(.);

 arrays[rodata_noload]
 mapping[rodata_noload]
 mutable[rodata_noload]
 } > default_rodata_seg

 .ext_ram.dummy (NOLOAD):
 {
 . = ORIGIN(extern_ram_seg);
 . = . + (_rodata_reserved_end - _flash_rodata_dummy_start);
 . = ALIGN (0x8000);
 } > extern_ram_seg

 .iram0.text_end (NOLOAD) :
 {

 . += 0;
 . = ALIGN(0);

 *(.iram_end_test)

 _iram_text_end = ABSOLUTE(.);
 } > iram0_0_seg

 .iram0.data :
 {

 . = ALIGN(4);
 _iram_data_start = ABSOLUTE(.);

 /* ESP-IDF v6.1 leaves the input-section patterns of this section to the
   arrays[]/mapping[]/mutable[] mappings emitted by SECTION_MAPPINGS(), but
   no released esp_system/ld file ever gives those mappings any content for
   esp32s3 (esp32s3/sections.ld.in does not include ld.iram.sections /
   ld.dram.sections, and ld.common only defines the macro). Without them the
   input sections become orphans and the linker drops them into whatever
   region fits first - .bss landed in the 24 byte rtc_reserved_seg. The
   patterns are spelled out here so the placement is explicit. */

    *(.iram.data .iram.data.*)

 arrays[iram0_data]
 mapping[iram0_data]
 mutable[iram0_data]

 . = ALIGN(4);
 _iram_data_end = ABSOLUTE(.);
 } > iram0_0_seg

 .iram0.bss (NOLOAD) :
 {

 . = ALIGN(4);
 _iram_bss_start = ABSOLUTE(.);

 /* ESP-IDF v6.1 leaves the input-section patterns of this section to the
   arrays[]/mapping[]/mutable[] mappings emitted by SECTION_MAPPINGS(), but
   no released esp_system/ld file ever gives those mappings any content for
   esp32s3 (esp32s3/sections.ld.in does not include ld.iram.sections /
   ld.dram.sections, and ld.common only defines the macro). Without them the
   input sections become orphans and the linker drops them into whatever
   region fits first - .bss landed in the 24 byte rtc_reserved_seg. The
   patterns are spelled out here so the placement is explicit. */

    *(.iram.bss .iram.bss.*)

 arrays[iram0_bss]
 mapping[iram0_bss]
 mutable[iram0_bss]

 _iram_bss_end = ABSOLUTE(.);

 . = ALIGN(4);
 _iram_end = ABSOLUTE(.);
 } > iram0_0_seg

 .dram0.heap_start (NOLOAD) :
 {

 . = ALIGN(8);
 _heap_low_start = ABSOLUTE(.);
 } > dram0_0_seg

/* CONFIG_* supplied by the generator */

 .noload 0 (INFO) :
 {

 . = 0;
 LONG(0);
 _noload_keep_in_elf_start = ABSOLUTE(.);

 arrays[noload_keep_in_elf]
 mapping[noload_keep_in_elf]
 mutable[noload_keep_in_elf]
 KEEP(*(.noload_keep_in_elf .noload_keep_in_elf.*))
 _noload_keep_in_elf_end = ABSOLUTE(.);
 }

 .debug 0 : { *(.debug) }
 .line 0 : { *(.line) }

 .debug_srcinfo 0 : { *(.debug_srcinfo) }
 .debug_sfnames 0 : { *(.debug_sfnames) }

 .debug_aranges 0 : { *(.debug_aranges) }
 .debug_pubnames 0 : { *(.debug_pubnames) }

 .debug_info 0 : { *(.debug_info .gnu.linkonce.wi.*) }
 .debug_abbrev 0 : { *(.debug_abbrev) }
 .debug_line 0 : { *(.debug_line) }
 .debug_frame 0 : { *(.debug_frame) }
 .debug_str 0 : { *(.debug_str) }
 .debug_loc 0 : { *(.debug_loc) }
 .debug_macinfo 0 : { *(.debug_macinfo) }
 .debug_pubtypes 0 : { *(.debug_pubtypes) }

 .debug_ranges 0 : { *(.debug_ranges) }

 .debug_weaknames 0 : { *(.debug_weaknames) }
 .debug_funcnames 0 : { *(.debug_funcnames) }
 .debug_typenames 0 : { *(.debug_typenames) }
 .debug_varnames 0 : { *(.debug_varnames) }

 .debug_gnu_pubnames 0 : { *(.debug_gnu_pubnames) }
 .debug_gnu_pubtypes 0 : { *(.debug_gnu_pubtypes) }

 .debug_types 0 : { *(.debug_types) }

 .debug_addr 0 : { *(.debug_addr) }
 .debug_line_str 0 : { *(.debug_line_str) }
 .debug_loclists 0 : { *(.debug_loclists) }
 .debug_macro 0 : { *(.debug_macro) }
 .debug_names 0 : { *(.debug_names) }
 .debug_rnglists 0 : { *(.debug_rnglists) }
 .debug_str_offsets 0 : { *(.debug_str_offsets) }

 .comment 0 : { *(.comment) }
 .note.GNU-stack 0 : { *(.note.GNU-stack) }

 .riscv.attributes 0 : { *(.riscv.attributes) }

 .xtensa.info 0 : { *(.xtensa.info) }
 .xt.prop 0 : { *(.xt.prop .xt.prop.* .gnu.linkonce.prop.*) }
 .xt.lit 0 : { *(.xt.lit .xt.lit.* .gnu.linkonce.p.*) }

/* CONFIG_* supplied by the generator */

 /DISCARD/ :
 {

 *(.rela.*)

 *(.fini)
 *(.eh_frame_hdr)

 }

}

ASSERT(((_iram_end - ORIGIN(iram0_0_seg)) <= LENGTH(iram0_0_seg)),
 "IRAM0 segment data does not fit.")

ASSERT(((_heap_low_start - ORIGIN(dram0_0_seg)) <= LENGTH(dram0_0_seg)),
 "DRAM segment data does not fit.")

