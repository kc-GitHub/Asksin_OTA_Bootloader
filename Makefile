# Makefile for AskSin OTA bootloader
#
# Instructions
#
# To make bootloader .hex file:
# make HM_LC_Sw1PBU_FM
# make HB_UW_Sen_THPL
# etc...
#

# program name should not be changed...
PROGRAM          = Bootloader-AskSin-OTA
F_CPU            = 8000000
SUFFIX           =

CC               = avr-gcc
OPTIMIZE         = -Os

OBJCOPY          = avr-objcopy
FORMAT           = ihex

# Override is only needed by avr-lib build system.
override CFLAGS  = -g -Wall $(OPTIMIZE) -mmcu=$(MCU) -DF_CPU=$(F_CPU)
override LDFLAGS = -Wl,--section-start=.text=${BOOTLOADER_START},--section-start=.bootloaderUpdate=${BOOTLOADER_UPDATE_START},--section-start=.addressDataType=${ADDRESS_DATA_TYPE_START},--section-start=.addressDataSerial=${ADDRESS_DATA_SERIAL_START},--section-start=.addressDataId=${ADDRESS_DATA_ID_START}

all:

# Settings for HM_LC_Sw1PBU_FM (Atmega644, 4k Bootloader size)
#
# CODE_END:                lenth of program space (adress of crc-check data is at CODE_END - 1)
# BOOTLOADER_START:        Start address of the bootoader   (4k bootloader space)
# ADDRESS_DATA_START:      Start address of adressdata      (last 16 bytes in flash)
# BOOTLOADER_PAGES         Number of pages in the bootloader section (remember 328p and 644a have different page size)
# BOOTLOADER_UPDATE_START  Start address of protected .bootloaderUpdate section for OTA self update function
#
HM_LC_Sw1PBU_FM:    TARGET                    = HM_LC_Sw1PBU_FM
HM_LC_Sw1PBU_FM:    MCU                       = atmega644
HM_LC_Sw1PBU_FM:    CODE_END                  = 0xEFFF
HM_LC_Sw1PBU_FM:    BOOTLOADER_PAGES          = 15
HM_LC_Sw1PBU_FM:    BOOTLOADER_UPDATE_START   = 0xFF00

HM_LC_Sw1PBU_FM:    BOOTLOADER_START          = 0xF000
HM_LC_Sw1PBU_FM:    ADDRESS_DATA_TYPE_START   = 0xFFF0
HM_LC_Sw1PBU_FM:    ADDRESS_DATA_SERIAL_START = 0xFFF2
HM_LC_Sw1PBU_FM:    ADDRESS_DATA_ID_START     = 0xFFFC
HM_LC_Sw1PBU_FM:    hex

# Settings for HM_LC_Sw1PBU_FM (Atmega644, 8k Bootloader size)
HM_LC_Sw1PBU_FM_8k: TARGET                    = HM_LC_Sw1PBU_FM
HM_LC_Sw1PBU_FM_8k: SUFFIX                    = _8k
HM_LC_Sw1PBU_FM_8k: MCU                       = atmega644
HM_LC_Sw1PBU_FM_8k: CODE_END                  = 0xDFFF
HM_LC_Sw1PBU_FM_8k: BOOTLOADER_PAGES          = 31
HM_LC_Sw1PBU_FM_8k: BOOTLOADER_UPDATE_START   = 0xFF00

HM_LC_Sw1PBU_FM_8k: BOOTLOADER_START          = 0xE000
HM_LC_Sw1PBU_FM_8k: ADDRESS_DATA_START        = 0xFFF0
HM_LC_Sw1PBU_FM_8k: ADDRESS_DATA_TYPE_START   = 0xFFF0
HM_LC_Sw1PBU_FM_8k: ADDRESS_DATA_SERIAL_START = 0xFFF2
HM_LC_Sw1PBU_FM_8k: ADDRESS_DATA_ID_START     = 0xFFFC
HM_LC_Sw1PBU_FM_8k: hex

# Settings for HM_LC_Sw1PBU_FM (Atmega328p, 4k Bootloader size)
HB_UW_Sen_THPL:     TARGET                    = HB_UW_Sen_THPL
HB_UW_Sen_THPL:     MCU                       = atmega328p
HB_UW_Sen_THPL:	    CODE_END                  = 0x6FFF
HB_UW_Sen_THPL:     BOOTLOADER_PAGES          = 30
HB_UW_Sen_THPL:     BOOTLOADER_UPDATE_START   = 0x7F00

HB_UW_Sen_THPL:     BOOTLOADER_START          = 0x7000
HB_UW_Sen_THPL:     ADDRESS_DATA_TYPE_START   = 0x7FF0
HB_UW_Sen_THPL:     ADDRESS_DATA_SERIAL_START = 0x7FF2
HB_UW_Sen_THPL:     ADDRESS_DATA_ID_START     = 0x7FFC
HB_UW_Sen_THPL:     hex

hex: uart_code
	$(CC) -Wall -c -std=c99 -mmcu=$(MCU) $(LDFLAGS) -DF_CPU=$(F_CPU) -D$(TARGET) $(OPTIMIZE) cc.c -o cc.o
	$(CC) -Wall    -std=c99 -mmcu=$(MCU) $(LDFLAGS) -DF_CPU=$(F_CPU) -D$(TARGET) -DCODE_END=${CODE_END} -DBOOTLOADER_START=${BOOTLOADER_START} -DBOOTLOADER_PAGES=${BOOTLOADER_PAGES} $(OPTIMIZE) bootloader.c cc.o uart/uart.o -o $(PROGRAM)-$(TARGET)$(SUFFIX).elf
	$(OBJCOPY) -j .text -j .data -j .bootloaderUpdate -j .addressDataType -j .addressDataSerial -j .addressDataId -O $(FORMAT) $(PROGRAM)-$(TARGET)$(SUFFIX).elf $(PROGRAM)-$(TARGET)$(SUFFIX).hex

	@avr-nm -fsysv -n -S -l -a $(PROGRAM)-$(TARGET)$(SUFFIX).elf
	echo
	@avr-size -C --mcu=$(MCU) $(PROGRAM)-$(TARGET)$(SUFFIX).elf

uart_code:
	$(MAKE) -C ./uart/ MCU=$(MCU)
	
clean:
	rm -rf *.o *.elf *.lst *.map *.sym *.lss *.eep *.srec *.bin *.hex \
	uart/*.o uart/*.elf uart/*.lst uart/*.map uart/*.sym uart/*.lss uart/*.eep uart/*.srec uart/*.bin uart/*.hex
