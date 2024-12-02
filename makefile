
none:
	@echo Specify target as one of mini, superelf, rc1802

mini: .mbios-mini
superelf: .mbios-superelf
rc1802: .mbios-rc1802

.mbios-mini: mbios.asm
	@rm -f .mbios-*
	asm02 -L -b -D1802MINI mbios.asm
	@rm -f mbios.build
	@touch .mbios-mini

.mbios-superelf: mbios.asm
	@rm -f .mbios-*
	asm02 -L -b -DSUPERELF mbios.asm
	@rm -f mbios.build
	@touch .mbios-superelf

.mbios-rc1802: mbios.asm
	@rm -f .mbios-*
	asm02 -L -b -DRC1802 mbios.asm
	@rm -f mbios.build
	@touch .mbios-rc1802

clean:
	@rm -f mbios.bin mbios.lst .mbios-*
