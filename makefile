
mini: mbios.asm
	@sed 's/^  *#/#/' mbios.asm > mbios.tmp
	asm02 -L -b -D1802MINI mbios.tmp
	@rm mbios.build mbios.tmp

superelf: mbios.asm
	@sed 's/^  *#/#/' mbios.asm > mbios.tmp
	asm02 -L -b -DSUPERELF mbios.tmp
	@rm mbios.build mbios.tmp

rc1802: mbios.asm
	@sed 's/^  *#/#/' mbios.asm > mbios.tmp
	asm02 -L -b -DRC1802 mbios.tmp
	@rm mbios.build mbios.tmp

maximize: mbios.asm
	@sed 's/^  *#/#/' mbios.asm > mbios.tmp
	asm02 -L -b -DMAXIMIZE mbios.tmp
	@rm mbios.build mbios.tmp

clean:
	@rm -f mbios.bin mbios.lst

