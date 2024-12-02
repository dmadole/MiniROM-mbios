# MBIOS

This is a BIOS for inclusion in ROM in an 1802 system to support the Elf/OS operating system, which trying to achieve the following goals:

* High compatibility for most uses with the original [BIOS by Mike Riley](https://github.com/rileym65/Elf-BIOS)
* Small run-time footprint of only 2K to allow maximum contiguous RAM in a system
* Support peripherals for the [1802/Mini](https://github.com/dmadole/1802-Mini) system (and machines with compatible busses) under Elf/OS
* Provide for two-level group port selection to allow an expanded number of peripherals at the BIOS level
* Size and performance improvements to allow more functionality to be included in BIOS
* Enhance peripheral and memory detection including to allow use of in-circuit programmable EEPROM

This BIOS is a completely original software not derived from Mike Riley's original except that the routines included are written to the same API and are meant to be feature-for-feature (and in some cases bug-for-bug) compatible.

While developed to support the 1802/Mini-type systems this could also have inclusion of Pico/Elf or other peripherals if desired. Other than the optional banked RAM scheme and peripheral choices, there is nothing fundamentally unique to the 1802/Mini.

Note that two BIOS routines, f_findtkn, and f_idnum, which are of limited utility and used only by RC/basic (to my knowledge) have been removed to save space. However, I have provided a RAM-loadable version of those routines for those who need them in the [Elfos-tokens](https://github.com/dmadole/Elfos-tokens) module.
