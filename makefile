
mini: mbios.asm
	asm02 -L -b -D1802MINI mbios.asm
	rm mbios.build

superelf: mbios.asm
	asm02 -L -b -DSUPERELF mbios.asm
	rm mbios.build

clean:
	-rm mbios.bin mbios.lst

