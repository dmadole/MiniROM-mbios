
none:
	@echo Specify target as one of mini, superelf, rc1802

mini: mbios.asm
	asm02 -L -b -D1802MINI mbios.asm

superelf: mbios.asm
	asm02 -L -b -DSUPERELF mbios.asm

rc1802: mbios.asm
	asm02 -L -b -DRC1802 mbios.asm

test: mbios.asm
	asm02 -L -b -DTEST mbios.asm

clean:
	@rm -f mbios.bin mbios.lst

