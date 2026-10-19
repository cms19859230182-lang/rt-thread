import os
import sys

BSP_ROOT = os.path.dirname(os.path.abspath(__file__))

def _resolve_rtt_root(bsp_root):
    # Prefer the environment (CI in-tree builds set RTT_ROOT). Dist CI
    # deliberately unsets it so the project must find its own kernel copy.
    env_root = os.getenv('RTT_ROOT')
    if env_root:
        return os.path.abspath(env_root)
    # Dist layout: scons --dist places the kernel next to the project.
    sibling = os.path.join(bsp_root, 'rt-thread')
    if os.path.isfile(os.path.join(sibling, 'include', 'rtdef.h')):
        return sibling
    # In-tree: walk up until the RT-Thread root is found (do not hardcode
    # three levels — that points at bsp/ESP once the tree is under dist/).
    cur = bsp_root
    for _ in range(8):
        if os.path.isfile(os.path.join(cur, 'include', 'rtdef.h')):
            return cur
        parent = os.path.dirname(cur)
        if parent == cur:
            break
        cur = parent
    return os.path.normpath(os.path.join(bsp_root, '..', '..', '..'))

RTT_ROOT = _resolve_rtt_root(BSP_ROOT)
sys.path = sys.path + [os.path.join(RTT_ROOT, 'tools')]
from env_package import find_package_path

# toolchains options
ARCH        ='xtensa'
CPU         ='esp32s3'
CROSS_TOOL  ='gcc'

if os.getenv('RTT_CC'):
    CROSS_TOOL = os.getenv('RTT_CC')

if CROSS_TOOL == 'gcc':
    PLATFORM    = 'gcc'
    EXEC_PATH   = r'~/.espressif/tools/xtensa-esp-elf/esp-15.2.0_20251204/xtensa-esp-elf/bin'
else:
    print('Please make sure your toolchains is GNU GCC!')
    exit(0)

if os.getenv('RTT_EXEC_PATH'):
    EXEC_PATH = os.getenv('RTT_EXEC_PATH')
EXEC_PATH = os.path.expanduser(EXEC_PATH)

# ---------------------------------------------------------------------------
# Core configuration of the unified xtensa-esp-elf toolchain
#
# The unified toolchain is not built for one SoC: its GCC, assembler and linker
# start from the original ESP32 core config and load the real one at run time
# from a shared object shipped next to them,
# <toolchain>/xtensa-esp-elf/lib/xtensa_esp32s3.so.  `gcc -print-multi-lib`
# lists `esp32s3;@mdynconfig=xtensa_esp32s3.so`, i.e. the SoC is selected by
# passing -mdynconfig=<name>; gcc then dlopen()s that object (hence it has to be
# on the dynamic loader path) and switches to the esp32s3 multilib.
#
# Without it every ESP32-S3-only special register is rejected - SR 97
# (XT_REG_MEMCTL, written by bootloader_esp32s3.c) is the first one that bites -
# and the windowed-ABI RER instruction is not recognised.  The per-SoC
# toolchain this BSP used before (xtensa-esp32s3-elf 12.2) had that config
# compiled in, which is why nothing here was needed until the switch to the
# unified 15.2.0_20251204 toolchain shared with the RISC-V BSPs.
# ---------------------------------------------------------------------------
TOOLCHAIN_LIB = os.path.normpath(os.path.join(EXEC_PATH, os.pardir, 'lib'))
XTENSA_DYNCONFIG = 'xtensa_esp32s3.so'

if not os.path.isfile(os.path.join(TOOLCHAIN_LIB, XTENSA_DYNCONFIG)):
    print('WARNING: %s not found; the Xtensa build will use the wrong core config.'
          % os.path.join(TOOLCHAIN_LIB, XTENSA_DYNCONFIG))

# SConstruct feeds this into env.PrependENVPath() below; os.environ cannot be
# used because tools/SConstruct builds the SCons ENV before rtconfig.py loads.

BUILD = 'debug'

if PLATFORM == 'gcc':
    # toolchains
    PREFIX = 'xtensa-esp-elf-'
    CC = PREFIX + 'gcc'
    CXX = PREFIX + 'g++'
    AS = PREFIX + 'gcc'
    AR = PREFIX + 'ar'
    LINK = PREFIX + 'g++'
    TARGET_EXT = 'elf'
    SIZE = PREFIX + 'size'
    OBJDUMP = PREFIX + 'objdump'
    OBJCPY = PREFIX + 'objcopy'
    STRIP = PREFIX + 'strip'

    # -mlongcalls is what ESP-IDF uses everywhere: plain jumps cannot reach
    # across the 0x3C000000/0x40370000/0x600xxxxx ranges this SoC maps code
    # and ROM into. --specs=nosys.specs drops libgloss syscalls; the IDF
    # newlib port in the ESP-IDF package provides the real ones.
    # -mdynconfig picks the ESP32-S3 core config out of the unified
    # xtensa-esp-elf toolchain; see the note next to TOOLCHAIN_LIB above.
    DEVICE  = ' -nostartfiles -mlongcalls -mdynconfig=' + XTENSA_DYNCONFIG + ' --specs=nosys.specs -fasynchronous-unwind-tables '
    # Some ESP-IDF sources pull <sys/ioctl.h> in before the libc headers are on
    # the include path; use the RT-Thread one by absolute path (a relative
    # path would be resolved against each group's variant_dir under build/).
    ioctl_h = os.path.join(RTT_ROOT, 'components', 'libc', 'compilers', 'common', 'include', 'sys', 'ioctl.h')
    CFLAGS = DEVICE + '-Wno-error=incompatible-pointer-types -Wno-error=int-conversion -include ' + ioctl_h + ' -gdwarf-4 -ggdb -Og '
    AFLAGS =  ' -c' + DEVICE + ' -x assembler-with-cpp'
    idf_path = find_package_path(BSP_ROOT, 'ESP-IDF-latest', relative_to=BSP_ROOT, pathsep='/')
    # memory.ld + sections.ld under idf_port/ld are generated from ESP-IDF
    # 5.1.4's esp32s3 templates (see idf_port/ld/ header comments); the ROM
    # alias scripts and peripheral map come straight from the package.
    LFLAGS = DEVICE + ' -Wl,--cref -Wl,--defsym=IDF_TARGET_ESP32S3=0 -Wl,--gc-sections,-Map=rtthread.map,-cref,-u,call_start_cpu0 -T idf_port/ld/memory.ld -T idf_port/ld/sections.ld -T ' + idf_path + '/components/esp_rom/esp32s3/ld/esp32s3.rom.ld -T ' + idf_path + '/components/esp_rom/esp32s3/ld/esp32s3.rom.api.ld -T ' + idf_path + '/components/esp_rom/esp32s3/ld/esp32s3.rom.libgcc.ld -T ' + idf_path + '/components/esp_rom/esp32s3/ld/esp32s3.rom.newlib.ld -T ' + idf_path + '/components/esp_rom/esp32s3/ld/esp32s3.rom.version.ld -T ' + idf_path + '/components/soc/esp32s3/ld/esp32s3.peripherals.ld -Wl,--wrap=esp_system_abort -Wl,--wrap=esp_flash_init_default_chip '
    CXXFLAGS = CFLAGS

    POST_ACTION = OBJCPY + ' -Oihex $TARGET rtthread.hex\n' + SIZE + ' $TARGET \n'

def dist_handle(BSP_ROOT, dist_dir):
    import sys
    sys.path.append(os.path.join(os.path.dirname(BSP_ROOT), 'tools'))
    from sdk_dist import dist_do_building
    dist_do_building(BSP_ROOT, dist_dir)
