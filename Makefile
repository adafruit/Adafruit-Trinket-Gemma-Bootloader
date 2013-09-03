# Name: Makefile
# Project: GemmaBoot, for Gemma and Trinket
# Author: Frank Zhao
# Creation Date: 2013-06-06
# Tabsize: 4
# License: GNU GPL v3 (see License.txt)
#
# Copyright (c) 2013 Adafruit Industries
# All rights reserved.
#
# GemmaBoot is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
# 
# GemmaBoot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with GemmaBoot. If not, see
# <http://www.gnu.org/licenses/>.
###############################################################################

# Note: if you use "no PLL", then F_CPU should be 12 MHz, but this has proven to not work well, so do not use it
# Note: LV means low voltage, any voltage under 4V, while HV is high voltage, higher than 4V.
# The LV version divides the clock by 2 to give the user 8MHz, while HV leaves it at 16MHz
# Note: if you are unsure what any of this means, then use LV with PLL enabled.

DEVICE = attiny85
# BOOTLOADER_ADDRESS must be a multiple of SPM_PAGESIZE, which is 64 for the ATtiny85
# see table on the bottom of this makefile
# Note: the compiler used was AVR-GCC 4.7.2 , other versions may change the bootloader size
BOOTLOADER_ADDRESS_HV = 1500
BOOTLOADER_ADDRESS_LV = 14C0

PROGRAMMER = -c usbtiny -B 1
# PROGRAMMER contains AVRDUDE options to address your programmer

FUSEOPT_t85        = -U efuse:w:0xFE:m -U hfuse:w:0xD5:m
FUSEOPT_t85_PLL    = -U lfuse:w:0xF1:m $(FUSEOPT_t85)
FUSEOPT_t85_NO_PLL = -U lfuse:w:0xE2:m $(FUSEOPT_t85)
# You may have to change the order of these -U commands.

###############################################################################

# Tools:
AVRDUDE = avrdude $(PROGRAMMER) -p $(DEVICE)
CC = avr-gcc

# Options:
DEFINES = 
C_OPTIMIZATIONS = -ffunction-sections -fpack-struct -fshort-enums -fno-move-loop-invariants -fno-tree-scev-cprop -fno-inline-small-functions
CFLAGS = -Wall -Os $(C_OPTIMIZATIONS) -I. -mmcu=$(DEVICE) -DF_CPU=16500000UL $(DEFINES)
LDFLAGS_BOOT = -Wl,--relax,--gc-sections
LDFLAGS_JUMP = -Wl,--relax,--gc-sections

OBJECTS_BOOT_LV = usbdrv/usbdrvasm_lv.o boot_lv.o osccal_lv.o
OBJECTS_BOOT_HV = usbdrv/usbdrvasm_hv.o boot_hv.o osccal_hv.o

# symbolic targets:
all: flash_me_lv.hex flash_me_hv.hex

all_lv: flash_me_lv.hex

all_hv: flash_me_hv.hex

boot_lv.o: boot.c
	$(CC) $(CFLAGS) -DBOOTLOADER_ADDRESS=0x$(BOOTLOADER_ADDRESS_LV) -DLOW_VOLTAGE -c $< -o $@

boot_hv.o: boot.c
	$(CC) $(CFLAGS) -DBOOTLOADER_ADDRESS=0x$(BOOTLOADER_ADDRESS_HV) -c $< -o $@

osccal_lv.o: osccal.c
	$(CC) $(CFLAGS) -DLOW_VOLTAGE -c $< -o $@

osccal_hv.o: osccal.c
	$(CC) $(CFLAGS) -c $< -o $@

usbdrv/usbdrvasm_lv.o: usbdrv/usbdrvasm.S
	$(CC) $(CFLAGS) -DBOOTLOADER_ADDRESS=0x$(BOOTLOADER_ADDRESS_LV) -x assembler-with-cpp -c $< -o $@

usbdrv/usbdrvasm_hv.o: usbdrv/usbdrvasm.S
	$(CC) $(CFLAGS) -DBOOTLOADER_ADDRESS=0x$(BOOTLOADER_ADDRESS_HV) -x assembler-with-cpp -c $< -o $@

# "-x assembler-with-cpp" should not be necessary since this is the default
# file type for the .S (with capital S) extension. However, upper case
# characters are not always preserved on Windows. To ensure WinAVR
# compatibility define the file type manually.

flash_lv:	all_lv
	$(AVRDUDE) $(FUSEOPT_t85_PLL) -U flash:w:flash_me_lv.hex:i

flash_hv:	all_hv
	$(AVRDUDE) $(FUSEOPT_t85_PLL) -U flash:w:flash_me_hv.hex:i

readflash:
	$(AVRDUDE) -U flash:r:read.hex:i

fuse:
	$(AVRDUDE) $(FUSEOPT_t85)

fuse_no_pll:
	$(AVRDUDE) $(FUSEOPT_t85_NO_PLL)

fuse_pll:
	$(AVRDUDE) $(FUSEOPT_t85_PLL)

clean:
	rm -f *.hex *.bin *.elf *.o *.lst *.lss usbdrv/*.o boot_hv.s boot_lv.s jump_lv.s jump_hv.s usbdrv/oddebug.s usbdrv/usbdrv.s

# file targets:

flash_me_lv.hex:	jump_lv.hex boot_lv.hex
	cat jump_lv.hex boot_lv.hex > $@
	avr-objdump -mavr -D $@ > $@.lss

flash_me_hv.hex:	jump_hv.hex boot_hv.hex
	cat jump_hv.hex boot_hv.hex > $@
	avr-objdump -mavr -D $@ > $@.lss

boot_lv.elf:	$(OBJECTS_BOOT_LV)
	$(CC) $(CFLAGS) -DLOW_VOLTAGE -o $@ $(OBJECTS_BOOT_LV) $(LDFLAGS_BOOT) -Wl,--section-start=.text=$(BOOTLOADER_ADDRESS_LV)
	avr-size --format=avr --mcu=$(DEVICE) $@
	avr-objdump -x -D -S -z $@ > $@.lss

boot_hv.elf:	$(OBJECTS_BOOT_HV)
	$(CC) $(CFLAGS) -o $@ $(OBJECTS_BOOT_HV) $(LDFLAGS_BOOT) -Wl,--section-start=.text=$(BOOTLOADER_ADDRESS_HV)
	avr-size --format=avr --mcu=$(DEVICE) $@
	avr-objdump -x -D -S -z $@ > $@.lss

jump_lv.elf:	jump.asm
	avr-as -mmcu=$(DEVICE) --defsym BOOTLOADER_ADDRESS=0x$(BOOTLOADER_ADDRESS_LV) -o $@ $<

jump_hv.elf:	jump.asm
	avr-as -mmcu=$(DEVICE) --defsym BOOTLOADER_ADDRESS=0x$(BOOTLOADER_ADDRESS_HV) -o $@ $<

boot_lv.hex:	boot_lv.elf
	rm -f boot_lv.hex boot_lv.eep.hex
	avr-objcopy -j .text -j .data -O ihex $< $@
	avr-size $@

boot_hv.hex:	boot_hv.elf
	rm -f boot_hv.hex boot_hv.eep.hex
	avr-objcopy -j .text -j .data -O ihex $< $@
	avr-size $@

jump_lv.hex:	jump_lv.elf
	rm -f $@ $@.tmp jump_lv.eep.hex
	avr-objcopy -j .text -j .data -O ihex $< $@.tmp
	head -1 $@.tmp > $@
	rm -f $@.tmp

jump_hv.hex:	jump_hv.elf
	rm -f $@ $@.tmp jump_hv.eep.hex
	avr-objcopy -j .text -j .data -O ihex $< $@.tmp
	head -1 $@.tmp > $@
	rm -f $@.tmp

# program size lookup table
# decimal then hex, in bytes (not words)
# bootloader compile size on the left, corresponding bootloader address on the right
# 1984	0x07C0					6208	0x1840
# 2048	0x0800					6144	0x1800
# 2112	0x0840					6080	0x17C0
# 2176	0x0880					6016	0x1780
# 2240	0x08C0					5952	0x1740
# 2304	0x0900					5888	0x1700
# 2368	0x0940					5824	0x16C0
# 2432	0x0980					5760	0x1680
# 2496	0x09C0					5696	0x1640
# 2560	0x0A00					5632	0x1600
# 2624	0x0A40					5568	0x15C0
# 2688	0x0A80					5504	0x1580
# 2752	0x0AC0					5440	0x1540
# 2816	0x0B00					5376	0x1500
# 2880	0x0B40					5312	0x14C0
# 2944	0x0B80					5248	0x1480
# 3008	0x0BC0					5184	0x1440
# 3072	0x0C00					5120	0x1400
