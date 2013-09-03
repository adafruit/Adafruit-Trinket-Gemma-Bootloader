; Project: GemmaBoot
; by Frank Zhao
; GemmaBoot is the bootloader that will be used in Gemma (from Adafruit Industries)
; 
; this file is used to generate the jump.hex that is appended to the top of boot.hex in order to generate flash_me.hex
; this avoids having the bootloader writing these jumps at runtime, saving some memory
;
; Copyright (c) 2013 Adafruit Industries
; All rights reserved.
; 
; GemmaBoot is free software: you can redistribute it and/or modify
; it under the terms of the GNU Lesser General Public License as
; published by the Free Software Foundation, either version 3 of
; the License, or (at your option) any later version.
; 
; GemmaBoot is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU Lesser General Public License for more details.
; 
; You should have received a copy of the GNU Lesser General Public
; License along with GemmaBoot. If not, see
; <http://www.gnu.org/licenses/>.

.org 0x0000
		rjmp BOOTLOADER_ADDRESS
		rjmp BOOTLOADER_ADDRESS + 2
		rjmp BOOTLOADER_ADDRESS + 4
		rjmp BOOTLOADER_ADDRESS + 6
		rjmp BOOTLOADER_ADDRESS + 8
		rjmp BOOTLOADER_ADDRESS + 10
		rjmp BOOTLOADER_ADDRESS + 12
		rjmp BOOTLOADER_ADDRESS + 14
		rjmp BOOTLOADER_ADDRESS + 16
main:	cli
		rjmp .-2
