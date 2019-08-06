/* SPDX-License-Identifier: GPL-2.0+ */
/*
 * Configuration file for the SAMA5D27 SOM1 EK Board.
 *
 * Copyright (C) 2017 Microchip Corporation
 *		      Wenyou Yang <wenyou.yang@microchip.com>
 */

#ifndef __CONFIG_H
#define __CONFIG_H

#include "at91-sama5_common.h"

#undef CONFIG_SYS_AT91_MAIN_CLOCK
#define CONFIG_SYS_AT91_MAIN_CLOCK      24000000 /* from 24 MHz crystal */

/* SDRAM */
#define CONFIG_SYS_SDRAM_BASE		0x20000000
#define CONFIG_SYS_SDRAM_SIZE		0x8000000

#ifdef CONFIG_SPL_BUILD
#define CONFIG_SYS_INIT_SP_ADDR		0x218000
#else
#define CONFIG_SYS_INIT_SP_ADDR \
	(CONFIG_SYS_SDRAM_BASE + 16 * 1024 - GENERATED_GBL_DATA_SIZE)
#endif

#define CONFIG_SYS_LOAD_ADDR		0x22000000 /* load address */

/* NAND flash */
#undef CONFIG_CMD_NAND

/* SPI flash */

#undef CONFIG_BOOTCOMMAND
#ifdef CONFIG_SD_BOOT
/* u-boot env in sd/mmc card */
#define CONFIG_ENV_SIZE		0x4000
/* bootstrap + u-boot + env in sd card */
#define CONFIG_SUPPORT_RAW_INITRD
#define CONFIG_EXTRA_ENV_SETTINGS \
    "initrd_high=0xffffffff\0" \
    "fdt_high=0xffffffff\0" \
    "fdtovaddr=0x21800000\0" \
    "loadaddr=0x22000000\0" \
    "fdtaddr=0x21000000\0" \
    "fdtfile=/dtbs/at91-sama5d27_giantboard.dtb\0" \
    "enable_uboot_overlays=\0" \
    "dtboverlay=\0" \
    "dtboverlay1=\0" \
    "dtboverlay2=\0" \
    "dtboverlay3=\0" \
    "dtboverlay4=\0" \
    "console=ttyS0,115200\0" \
    "optargs=\0" \
    "video=\0" \
    "mmcdev=0\0" \
    "mmcpart=1\0" \
    "mmcroot=/dev/mmcblk0p2 ro\0" \
    "mmcrootfstype=ext4 rootwait\0" \
    "mmcargs=setenv bootargs console=${console} " \
        "${optargs} " \
        "root=${mmcroot} " \
        "rootfstype=${mmcrootfstype} " \
        "video=${video}\0" \
    "loadbootenv=load mmc ${mmcdev}:${mmcpart} ${loadaddr} uEnv.txt\0" \
    "importbootenv=echo Importing environment from mmc (uEnv.txt)...; " \
        "env import -t ${loadaddr} ${filesize}\0" \
    "loadzimage=load mmc ${mmcdev}:${mmcpart} ${loadaddr} zImage\0" \
    "loadfdt=load mmc ${mmcdev}:${mmcpart} ${fdtaddr} ${fdtfile}\0" \
    "loadoverlay=load mmc ${mmcdev}:${mmcpart} ${fdtovaddr} ${dtboverlay}\0" \
    "loadoverlay1=load mmc ${mmcdev}:${mmcpart} ${fdtovaddr} ${dtboverlay1}\0" \
    "loadoverlay2=load mmc ${mmcdev}:${mmcpart} ${fdtovaddr} ${dtboverlay2}\0" \
    "loadoverlay3=load mmc ${mmcdev}:${mmcpart} ${fdtovaddr} ${dtboverlay3}\0" \
    "loadoverlay4=load mmc ${mmcdev}:${mmcpart} ${fdtovaddr} ${dtboverlay4}\0" \
    "mmcboot=echo Booting from mmc ...; " \
        "run mmcargs; " \
        "bootz ${loadaddr} - ${fdtaddr}\0"

#define CONFIG_BOOTCOMMAND \
    "mmc dev ${mmcdev};" \
    "if mmc rescan; then " \
        "echo SD/MMC found on device ${mmcdev};" \
        "if run loadbootenv; then " \
            "run importbootenv;" \
        "fi;" \
        "echo Running default loadzimage ...;" \
        "if run loadzimage; then " \
            "run loadfdt;" \
            "echo Checking for overlays ...;" \
            "if test -n $enable_uboot_overlays; then " \
                "fdt addr ${fdtaddr};" \
                "fdt resize 4096;" \
                "if test -n $dtboverlay; then " \
                    "run loadoverlay;" \
                    "fdt apply ${fdtovaddr};" \
                    "echo loaded ${dtboverlay};" \
                "fi;" \
                "if test -n $dtboverlay1; then " \
                    "run loadoverlay1;" \
                    "fdt apply ${fdtovaddr};" \
                    "echo loaded ${dtboverlay1};" \
                "fi;" \
                "if test -n $dtboverlay2; then " \
                    "run loadoverlay2;" \
                    "fdt apply ${fdtovaddr};" \
                    "echo loaded ${dtboverlay2};" \
                "fi;" \
                "if test -n $dtboverlay3; then " \
                    "run loadoverlay3;" \
                    "fdt apply ${fdtovaddr};" \
                    "echo loaded ${dtboverlay3};" \
                "fi;" \
                "if test -n $dtboverlay4; then " \
                    "run loadoverlay4;" \
                    "fdt apply ${fdtovaddr};" \
                    "echo loaded ${dtboverlay4};" \
                "fi;" \
            "fi;" \
            "run mmcboot;" \
        "fi;" \
    "fi;"
#endif

#ifdef CONFIG_QSPI_BOOT
#undef CONFIG_BOOTARGS
#define CONFIG_BOOTARGS \
	"console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p2 rw rootwait"
#endif

/* SPL */
#define CONFIG_SPL_MAX_SIZE		0x10000
#define CONFIG_SPL_BSS_START_ADDR	0x20000000
#define CONFIG_SPL_BSS_MAX_SIZE		0x80000
#define CONFIG_SYS_SPL_MALLOC_START	0x20080000
#define CONFIG_SYS_SPL_MALLOC_SIZE	0x80000

#define CONFIG_SYS_MONITOR_LEN		(512 << 10)

#ifdef CONFIG_SD_BOOT
#define CONFIG_SYS_MMCSD_FS_BOOT_PARTITION	1
#define CONFIG_SPL_FS_LOAD_PAYLOAD_NAME		"u-boot.img"
#endif

#ifdef CONFIG_QSPI_BOOT
#define CONFIG_SYS_SPI_U_BOOT_OFFS	0x10000
#endif

#endif
