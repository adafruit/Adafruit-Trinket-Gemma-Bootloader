Adafruit-Trinket-Gemma-Bootloader
=================================

This is the code for the Trinket/Gemma bootloader. There are two versions, HV (16MHz 5V) and LV (8MHz 3V), but we only use the 3V version and then clock double in the user code.

Check the Makefile for fuses, etc. Requires modifications to avrdude.conf - for advanced users only - we do not offer any support for this code!

=================================
 Please note: you cannot use the Adafruit USB VID/PID for your own non-Trinket/Gemma products or projects. Purchase a USB VID for yourself at http://www.usb.org/developers/vendor/ 
=================================

Written by Frank Zhao for Adafruit Industries, 2013!

=================================

  This code is heavily derived from USBaspLoader, but also from USBtiny, 
  with USBtinyISP's settings
 
  Copyright (c) 2013 Adafruit Industries
  All rights reserved.

  GemmaBoot is free software: you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation, either version 3 of
  the License, or (at your option) any later version.

  GemmaBoot is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with GemmaBoot. If not, see
  <http://www.gnu.org/licenses/>.
