ark.gb: ark.o
	rgblink -o ark.gb ark.o
	rgbfix -v -p 0 ark.gb

run: ark.gb
	gambatte ark.gb

debug: ark.gb
	wine ~/dev/bgb/bgb64.exe ark.gb

ark.o: ark.asm hardware.inc
	rgbasm -o ark.o ark.asm

hardware.inc:
	git clone https://github.com/gbdev/hardware.inc hw
	cp hw/hardware.inc .
	rm -rf ./hw

clean:
	rm ark.o ark.gb hardware.inc
