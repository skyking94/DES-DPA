# makfile configuration
NAME            = main
OBJECTS         = main.o

#CFLAGS          = -O2 -Wall -g                                          # Old flags
#CFLAGS          = -O0 -Wall -g -mcpu=430 -mivcnt=16 -mmpy=32

#msp430x336 possible
#CFLAGS          = -Os -Wall -g -mcpu=msp430
CFLAGS          = -Os -Wall -g -mcpu=msp430
# Uniarch flags

#switch the compiler (for the internal make rules)
CC              = msp430-elf-gcc


.PHONY: all FORCE clean download download-jtag download-bsl dist

#all should be the first target. it's built when make is run without args
all: ${NAME}.elf ${NAME}.a43 ${NAME}.lst ${NAME}.h

#confgigure the next line if you want to use the serial download
download: download-uart
#download: download-jtag
#download: download-bsl

#additional rules for files
${NAME}.elf: ${OBJECTS}
	${CC} $(CFLAGS) -Wl,-x -T linker.msp430.elf.x -o $@ ${OBJECTS}

${NAME}.a43: ${NAME}.elf
	msp430-elf-objcopy -O ihex $^ $@

${NAME}.lst: ${NAME}.elf
	msp430-elf-objdump -dt $^ >$@

download-jtag: all
	msp430-elf-jtag -e ${NAME}.elf

download-bsl: all
	msp430-elf-bsl -e ${NAME}.elf

download-uart: all
	openmsp430-loader.tcl -device /dev/ttyUSB0 -baudrate 115200 ${NAME}.elf

clean:
	del ${NAME} ${NAME}.a43 ${NAME}.lst ${NAME}.elf *.o

#backup archive
dist:
	tar czf dist.tgz *.c *.h *.txt makefile

#dummy target as dependecy if something has to be build everytime
FORCE:

#project dependencies
main.o: main.c
