MCU = atmega328p
F_CPU = 8000000

SIZE = avr-size
MSG_SIZE_BEFORE = Size before: 
MSG_SIZE_AFTER = Size after:
FORMAT = ihex

TARGET = bootloader
LDSECTION  = --section-start=.text=0x7000,--section-start=.addressData=0x7FF0
LDFLAGS    = -Wl,$(LDSECTION)

# Display size of file.
HEXSIZE = $(SIZE) --target=$(FORMAT) $(TARGET).hex
ELFSIZE = $(SIZE) -A $(TARGET).elf
AVRMEM = avr-mem.sh $(TARGET).elf $(MCU)

all:	uart_code
	avr-gcc -Wall -c -std=c99 -mmcu=$(MCU) $(LDFLAGS) -DF_CPU=$(F_CPU) -Os cc.c -o cc.o
	avr-gcc -Wall -std=c99 -mmcu=$(MCU) $(LDFLAGS) -DF_CPU=$(F_CPU) -Os bootloader.c cc.o uart/uart.o -o $(TARGET).elf
	avr-objcopy -j .text -j .data -j .addressData -O $(FORMAT) $(TARGET).elf $(TARGET).hex

	@echo 'Binary size:' echo; echo; $(HEXSIZE);

uart_code:
	$(MAKE) -C ./uart/

clean:
	$(MAKE) -C ./uart/ clean
	rm bootloader.hex bootloader.elf *.o

