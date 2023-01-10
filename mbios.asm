;  Copyright 2022, David S. Madole <david@madole.net>
;
;  This program is free software: you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published by
;  the Free Software Foundation, either version 3 of the License, or
;  (at your option) any later version.
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this program.  If not, see <https://www.gnu.org/licenses/>.


            ; Hardware and Build Target Definitions

#define NO_GROUP       0                ; hardware defined - do not change

#define IDE_SETTLE     500              ; milliseconds delay before booting
#define UART_DETECT                     ; use uart if no bit-bang cable
#define INIT_CON                        ; initialize console before booting

#define USE_SDCARD                      ; use the sd card as the disk device

#ifdef 1802MINI
  #define BRMK         bn2              ; branch on serial mark
  #define BRSP         b2               ; branch on serial space
  #define SEMK         seq              ; set serial mark
  #define SESP         req              ; set serial space
  #define EXP_PORT     5                ; group i/o expander port
  #define EXP_MEMORY                    ; enable expansion memory
  #define IDE_GROUP    0                ; ide interface group
  #define IDE_SELECT   2                ; ide interface address port
  #define IDE_DATA     3                ; ide interface data port
  #define RTC_GROUP    1                ; real time clock group
  #define RTC_PORT     3                ; real time clock port
  #define UART_GROUP   0                ; uart port group
  #define UART_DATA    6                ; uart data port
  #define UART_STATUS  7                ; uart status/command port
  #define SPI_GROUP    2                ; spi card port group
  #define SPI_CTRL     2                ; spi card control port
  #define SPI_DATA     3                ; sip card data port
  #define SET_BAUD     19200            ; bit-bang serial fixed baud rate
  #define FREQ_KHZ     4000             ; default processor clock frequency
#endif

#ifdef SUPERELF
  #define BRMK         bn2              ; branch on serial mark
  #define BRSP         b2               ; branch on serial space
  #define SEMK         seq              ; set serial mark
  #define SESP         req              ; set serial space
  #define EXP_PORT     5                ; group i/o expander port
  #define EXP_MEMORY                    ; enable expansion memory
  #define IDE_GROUP    0                ; ide interface group
  #define IDE_SELECT   2                ; ide interface address port
  #define IDE_DATA     3                ; ide interface data port
  #define RTC_GROUP    1                ; real time clock group
  #define RTC_PORT     3                ; real time clock port
  #define UART_GROUP   0                ; uart port group
  #define UART_DATA    6                ; uart data port
  #define UART_STATUS  7                ; uart status/command port
  #define SET_BAUD     9600             ; bit-bang serial fixed baud rate
  #define FREQ_KHZ     1790             ; default processor clock frequency
#endif

#ifdef RC1802
  #define BRMK         bn3              ; branch on serial mark
  #define BRSP         b3               ; branch on serial space
  #define SEMK         seq              ; set serial mark
  #define SESP         req              ; set serial space
  #define EXP_PORT     1                ; group i/o expander port
  #define IDE_GROUP    0                ; ide interface group
  #define IDE_SELECT   2                ; ide interface address port
  #define IDE_DATA     3                ; ide interface data port
  #define UART_GROUP   1                ; uart port group
  #define UART_DATA    2                ; uart data port
  #define UART_STATUS  3                ; uart status/command port
  #define RTC_GROUP    2                ; real time clock group
  #define RTC_PORT     3                ; real time clock port
  #define SET_BAUD     9600             ; bit-bang serial fixed baud rate
  #define FREQ_KHZ     2000             ; default processor clock frequency
#endif

#ifdef TEST
  #define BRMK         bn2              ; branch on serial mark
  #define BRSP         b2               ; branch on serial space
  #define SEMK         seq              ; set serial mark
  #define SESP         req              ; set serial space
  #define EXP_PORT     5                ; group i/o expander port
  #define IDE_GROUP    1                ; ide interface group
  #define IDE_SELECT   2                ; ide interface address port
  #define IDE_DATA     3                ; ide interface data port
  #define UART_GROUP   4                ; uart port group
  #define UART_DATA    6                ; uart data port
  #define UART_STATUS  7                ; uart status/command port
  #define RTC_GROUP    2                ; real time clock group
  #define RTC_PORT     3                ; real time clock port
  #define FREQ_KHZ     4000             ; default processor clock frequency
#endif



            ; SCALL Register Usage

scall:      equ   r4
sret:       equ   r5


            ; Low Memory Usage

findtkn:    equ   0030h                 ; jump vector for f_findtkn
idnum:      equ   0033h                 ; jump vector for f_idnum
devbits:    equ   0036h                 ; f_getdev device present result
clkfreq:    equ   0038h                 ; processor clock frequency in khz
lastram:    equ   003ah                 ; f_freemem last ram address result
ocrreg:     equ   003ch                 ; ocr register of inserted sd card
diskwr:     equ   003dh                 ; disk write vector
diskrd:     equ   0040h                 ; disk read vector
diskck:     equ   0043h                 ; checksum of disk vectors

scratch:    equ   0080h                 ; pre-boot scratch buffer memory
stack:      equ   00ffh                 ; top of temporary booting stack
bootpg:     equ   0100h                 ; address to load boot block to


            ; Elf/OS Kernel Variables

o_wrmboot:  equ   0303h                 ; kernel warm-boot reinitialization
k_clkfreq:  equ   0470h                 ; processor clock frequency in khz


            ; The BIOS is divided into two parts, an always-resident part
            ; from F800-FFFF that is always mapped into memory and an
            ; initialization-only part that is below F800, and is currently
            ; F500-F7FF. This part is used for things that only need to 
            ; happen at a hard reset and never again, so that ROM space can
            ; be paged out and replaced with RAM when booting.


            org   0f500h

            ; Enable expander card memory (this code runs from low RAM).
            ; If the expander card is not present, this does nothing.

raminit:    sex   r3                    ; enable banked ram

          #ifdef EXP_MEMORY
            out   RTC_PORT
            db    81h
          #endif

          #if RTC_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    NO_GROUP
          #endif


            ; Find the last address of RAM present in the system. The search
            ; is done with a granularity of one page; this is not reliable
            ; on systems that do not have an integral number of pages of RAM.
            ;
            ; This implementation is safe for systems with EEPROM, which will
            ; go into a write cycle when a write is attempted to it, even when
            ; software write-protected. When this happens, data read is not
            ; valid until the end of the write cycle. The safety of this
            ; routine in this situation is accomplished by copying the code
            ; into RAM and running it from there instead of from ROM. This
            ; is run once at system initialization and the value stored and
            ; later that stored value is returned by f_freemem.
            ;
            ; In case this is run against an EEPROM that is not software
            ; write-protected (not recommended) this attempts to randomize
            ; the address within the page tested to distribute wear across
            ; the memory cells in the first page of the EEPROM.

            ldi   3fh                   ; we must have at least 16K
            phi   rf

            sex   rf                    ; rf is pointer to search address

scnloop:    glo   rf                    ; randomize address within page
            xor
            plo   rf

            ghi   rf                    ; advance pointer to next page
            adi   1
            phi   rf

            ldi   0                     ; get contents of memory, save it,
            xor                         ;  then complement it
            plo   re
            xri   255

            str   rf                    ; write complement back, then read,
            xor                         ;  if not the same then set df
            adi   255

            glo   re                    ; restore original value
            str   rf
  
scnwait:    glo   re                    ; wait until value just written
            xor                         ;  reads back again
            bnz   scnwait

            bnf   scnloop

            ghi   rf
            smi   1
            str   ra

            inc   ra
            ldi   0ffh
            str   ra

            ;
            ;

bootmsg:    ldi   devbits.1             ; pointer to memory variables
            phi   ra
            ldi   devbits.0
            plo   ra

          #ifdef INIT_CON
            sep   scall
            dw    setbd
          #endif

            sep   scall
            dw    inmsg
            db    13,10
            db    13,10
            db    'MBIOS 2.1.0',13,10
            db    'Devices: ',0

            inc   ra
            lda   ra
            plo   rb

            ldi   bootpg.1
            phi   rd
            ldi   devname.0
            plo   rd

devloop:    glo   rb
            shr
            plo   rb
            bnf   skipdev

            ghi   rd
            phi   rf
            glo   rd
            plo   rf

            sep   scall
            dw    msg

            ldi   ' '
            sep   scall
            dw    type

skipdev:    lda   rd
            bnz   skipdev

            ldn   rd
            bnz   devloop

            sep   scall
            dw    inmsg
            db    13,10
            db    'Clock: ',0

            ldi   scratch.1
            phi   rf
            ldi   scratch.0
            plo   rf

            lda   ra
            phi   rd
            lda   ra
            plo   rd

            sep   scall
            dw    uintout

            ldi   0
            str   rf

            ldi   scratch.1
            phi   rf
            ldi   scratch.0
            plo   rf

            sep   scall
            dw    msg

            sep   scall
            dw    inmsg
            db    ' KHz'13,10
            db    'Memory: ',0

            ldi   0
            phi   rd
            lda   ra
            shr
            shr
            adi   1
            plo   rd

            ldi   scratch.1
            phi   rf
            ldi   scratch.0
            plo   rf

            sep   scall
            dw    uintout

            ldi   0
            str   rf

            ldi   scratch.1
            phi   rf
            ldi   scratch.0
            plo   rf

            sep   scall
            dw    msg

            sep   scall
            dw    inmsg
            db    ' KB',13,10
            db    13,10,0

doboot:

            ; Now that all initialization has been done, boot the system by
            ; simply jumping to ideboot.

          #ifdef IDE_SETTLE
            ldi   255
            plo   rf
            ldi   ((FREQ_KHZ/32)*(IDE_SETTLE/20))/51

bootdly:    phi   rf
            dec   rf
            ghi   rf
            bnz   bootdly
          #endif

            lbr   ideboot



            ;   0: IDE-like disk device
            ;   1: Floppy (no longer relevant)
            ;   2: Bit-banged serial
            ;   3: UART-based serial
            ;   4: Real-time clock
            ;   5: Non-volatile RAM

devname:    db  'IDE',0                 ; bit 0
            db  'Floppy',0              ; bit 1
            db  'Serial',0              ; bit 2
            db  'UART',0                ; bit 3
            db  'RTC',0                 ; bit 4
            db   0


endinit:    equ   $


          #if $ > 0f600h
            #error Page F500 overflow
          #endif

            org   0f600h


            ; Do some basic initialization. Branching to initcall will setup
            ; R4 and R5 for SCALL, R2 as stack pointer, and finally, R3 as PC
            ; when it returns via SRET.

sysinit:    ldi   stack.1               ; temporary boot stack
            phi   r2
            ldi   stack.0
            plo   r2

            ldi   chkdevs.1             ; return address for initcall
            phi   r6
            ldi   chkdevs.0
            plo   r6

            lbr   initcall


            ; Discover devices present in the system to store into a memory
            ; variable that getdev will later return when called. Detection
            ; is not necessarily robust but should work on the platform and
            ; configurations it is designed for. It's hard to do better.

chkdevs:    ldi   devbits.1             ; pointer to memory variables
            phi   ra
            ldi   devbits.0
            plo   ra

            ldi   FREQ_KHZ.1            ; default processor clock frequency
            phi   rb
            ldi   FREQ_KHZ.0
            plo   rb


            ; Setup the device map entry which will later be returned by any
            ; call to f_getdev. Devices that may or may not be present will
            ; be determined at reset time by probing for them.

            ldi   0                     ; device map msb for future use
            str   ra

            ldi   (1<<0)+(1<<2)         ; serial and disk always present
            inc   ra
            str   ra


            ; Discovery of the devices is done by looking for some bits that
            ; should always have particular values. This doesn't guarantee
            ; that some other device isn't at the port, but it should be able
            ; to tell if nothing is there. Since the 1802/Mini bus floats,
            ; reading an unused port normally returns the INP instruction
            ; opcode due to bus capacitance from the fetch machine cycle.

            ; Discovery of UART is done by looking for 110XXXX0 pattern in
            ; status register which should be present once the DA flag is
            ; cleared by reading the data register.

          #if UART_GROUP
            sex   r3
            out   EXP_PORT
            db    UART_GROUP
            sex   r2
          #endif

            inp   UART_STATUS           ; clear status flags
            inp   UART_DATA

            inp   UART_STATUS           ; check for psi and da bits low
            ani   0e1h
            xri   0c0h
            bnz   findrtc

            ldn   ra                    ; looks like uart is present
            ori   (1<<3)
            str   ra


            ; Check for the RTC by looking for XXXX000X at the RTC month
            ; tens digit. Since it can only be 0 or 1 those zero bits will
            ; always be present even if the clock is not setup right.

findrtc:    sex   r3                    ; select rtc month msd register

          #if RTC_GROUP != UART_GROUP
            out   EXP_PORT
            db    RTC_GROUP
          #endif

            out   RTC_PORT
            db    29h

            sex   r2                    ; look for xxxx000x data
            inp   RTC_PORT
            ani   0eh
            bnz   savefrq

            ldn   ra                    ; looks like rtc is present
            ori   (1<<4)
            str   ra


            ; If we have an RTC, we can use it to measure the processor
            ; frequency, so do that now.

            sex   r3                    ; setup rtc for 64 hz pulse mode
            out   RTC_PORT
            db    2fh
            out   RTC_PORT
            db    14h
            out   RTC_PORT
            db    2eh
            out   RTC_PORT
            db    10h
            out   RTC_PORT
            db    2dh
            out   RTC_PORT
            db    10h

            ldi   0                     ; start frequency count at 0
            plo   rb
            phi   rb

            ldi   4                     ; number of pulses to measure
            plo   rc

            sex   r2                    ; needed for inp to be safe


            ; First syncronize to the falling edge of a FLAG pulse.

freqlp1:    inp   RTC_PORT              ; wait for low signal to sync
            ani   4
            bnz   freqlp1

freqlp2:    inp   RTC_PORT              ; wait for high signal to sync
            ani   4
            bz    freqlp2


            ; Now time the next full cycle of FLAG. We increment twice for
            ; two reasons, one is that it gives the proper loop timing (10
            ; machine cycles) for the math to work out with integral numbers,
            ; the other is that we need a multiply to two in here anyway since
            ; the final ratio of counts to frequency is 32/25.

freqlp3:    inc   rb                    ; wait for low signal to count
            inc   rb
            inp   RTC_PORT
            ani   4
            bnz   freqlp3

freqlp4:    inc   rb                    ; wait for high signal to count
            inc   rb
            inp   RTC_PORT
            ani   4
            bz    freqlp4

            inc   rb                    ; loop while still keeping count
            inc   rb
            dec   rc
            glo   rc
            bnz   freqlp3


            ; Multiply the result by 16/25 to get the final answer, but do
            ; it by multiplying by 4/5 twice so we don't overflow 16 bits.
            ; The calculated result will be stored after all devices are
            ; probed inc case another device wants to override the result.

            ldi   2
            plo   rc

hzratio:    glo   rb                    ; multiply by 2 while moving to rf
            shl
            plo   rf
            ghi   rb
            shlc
            phi   rf

            glo   rf                    ; multiply by 2 again so 4 total
            shl
            plo   rf
            ghi   rf
            shlc
            phi   rf

            ldi   5.1                   ; divide by 5
            phi   rd
            ldi   5.0
            plo   rd

            sep   scall
            dw    div16

            dec   rc                    ; loop the 4/5 multiply twice
            glo   rc
            bnz   hzratio


            ; Store the processor clock frequency to it's memory variable.

savefrq:    inc   ra                    ; move on from device map

            ghi   rb                    ; save processor frequency
            str   ra
            inc   ra
            glo   rb
            ani   -2
            str   ra
            inc   ra


            ; Initialize the jump vectors for the BIOS API calls that have
            ; been moved to loadable modules. Install for each one a LBR
            ; instruction to O_WRMBOOT which the module will overwrite the
            ; address when its loaded. This will at least fail gracefully
            ; if they are called when the module is not loaded.

            ldi   findtkn.1             ; get address of first vector
            phi   rf
            ldi   findtkn.0
            plo   rf

            ldi   2                     ; two of them to populate
            plo   re

tknloop:    ldi   0c0h                  ; write lbr opcode and address
            str   rf
            inc   rf
            ldi   o_wrmboot.1
            str   rf
            inc   rf
            ldi   o_wrmboot.0
            str   rf
            inc   rf

            dec   re                    ; loop for all
            glo   re
            bnz   tknloop


          ; Check the disk I/O vectors in BIOS RAM to see if they are valid
          ; by calculating CRC8 over them and checking against the stored sum

            ldi   diskwr.1
            phi   rf
            ldi   diskwr.0
            plo   rf

            ldi   6
            phi   rd

            sep   scall
            dw    crc8itu

            sex   rf
            xor
            lbz   sizeram


          ; If not valid, then copy the compiled-in defaults into RAM.

            ldi   diskwr.1
            phi   rd
            ldi   diskwr.0
            plo   rd

          #ifdef USE_SDCARD
            ldi   sddeflt.1
            phi   rf
            ldi   sddeflt.0
            plo   rf
          #else
            ldi   cfdeflt.1
            phi   rf
            ldi   cfdeflt.0
            plo   rf
          #endif

            ldi   6
            plo   re

copylp:     lda   rf
            str   rd
            inc   rd

            dec   re
            glo   re
            bnz   copylp


          ; Now update the CRC in BIOS RAM so these will be valid until next
          ; power cycle.

            ldi   diskwr.1
            phi   rf
            ldi   diskwr.0
            plo   rf

            ldi   6
            phi   rd

            sep   scall
            dw    crc8itu

            str   rf

            lbr   sizeram


          #if $ > 0f700h
            #error Page F600 overflow
          #endif

            org   0f700h


cfdeflt:    lbr   cfpriwr
            lbr   cfprird
sddeflt:    lbr   sdpriwr
            lbr   sdprird

            lbr   crc8itu



            ; It's not safe to run the expansion memory enable and memory
            ; scan code from ROM for two reasons: we are running from part
            ; of the ROM that will disappear once RAM is switched in, and
            ; attempting to write the EEPROM will cause a write cycle that
            ; makes it temporarily unreadable, even when software protected.
            ;
            ; So copy these routines to RAM in the boot sector page first,
            ; then run it from there, and we will jump to BIOS boot after.

sizeram:    ldi   raminit.1             ; get start of code to copy
            phi   rc

            ldi   bootpg.1              ; get address to copy to
            phi   rd

            ldi   raminit.0             ; lsb is same for both
            plo   rc
            plo   rd

            ldi   (endinit-raminit).1   ; number of bytes to copy
            phi   re
            ldi   (endinit-raminit).0
            plo   re

cpyloop:    lda   rc                    ; copy each byte to ram
            str   rd
            inc   rd

            dec   re
            glo   re
            bnz   cpyloop
            ghi   re
            bnz   cpyloop

            lbr   bootpg


crc8itu:    sex   rf

            ldi   0
            plo   re

crc8byt:    ldi   8
            plo   rd

            glo   re
            xor
            plo   re

crc8bit:    glo   re
            shl

            bnf   crc8zer
            xri   07h

crc8zer:    plo   re

            dec   rd
            glo   rd
            bnz   crc8bit

            inc   rf

            dec   rd
            ghi   rd
            bnz   crc8byt

            glo   re
            xri   55h
            sep   sret


          #if $ > 0f800h
            #error Page F700 overflow
          #endif


            ; The vector table at 0F800h was introduced with the Elf2K and
            ; provides some extended functionality for hardware of that
            ; platform. Where sensible, the same functions are provided here
            ; in a compatible way to support like 1802/Mini hardware.

            org   0f800h


            ; These theoretically provide a way to access the bit-banged UART
            ; even when another console device is selected, but the fact that
            ; there is probably not the correct baud rate in RE.1 will limit
            ; their usefulness (except for btest).

f_bread:    lbr   bread
f_btype:    lbr   btype
f_btest:    lbr   btest


            ; These provide direct access to the hardware UART and some more
            ; functionality such as being able to change parameters and check
            ; for a character ready. These are independent of RE.1 contents.

f_utype:    lbr   utype        ; type console character via UART
f_uread:    lbr   uread        ; read console character via UART
f_utest:    lbr   utest        ; test UART for character available
f_usetbd:   lbr   usetbd       ; set UART baud rate and character format


            ; These provide access to read and write the hardware clock in
            ; a format compatible with Elf/OS. The set routine will also
            ; properly initialize a new chip or after a bettery replacement.

f_gettod:   lbr   gettod
f_settod:   lbr   settod


            ; The rest of these extended calls are not supported and are,
            ; I believe, only used by the Elf2K. There are in the Pico/Elf
            ; BIOS but hopefully no one uses them. Some are particular to
            ; NVR capability and so are not relevant when that's not present.

f_rdnvr:    lbr   error
f_wrnvr:    lbr   error
f_idesize:  lbr   error
f_ideid:    lbr   error
f_dttoas:   lbr   error
f_tmtoas:   lbr   error
f_rtctest:  lbr   error
f_astodt:   lbr   error
f_astotm:   lbr   error
f_nvrcchk:  lbr   error


            ; Converts an ASCII decimal number string to 16-bit binary. The
            ; original version in the Mike Riley BIOS has some code to deal
            ; with negative numbers but it doesn't work right, so this 
            ; implementation does not support negative numbers at all.
            ;
            ;   IN:   RF - pointer to string
            ;   OUT:  RD - binary representation
            ;         RF - points just past the number
            ;         DF - set if first character is not a digit

atoi:       ldi   0                     ; clear result to start
            plo   rd
            phi   rd

            lda    rf                   ; get first character

            sdi   '0'-1                 ; if less than 0 exit with df=1
            bdf   a2iend

            sdi   '0'-1-'9'-1           ; if greater than 9 exit with df=1
            bdf   a2iend

            adi   '9'+1-'0'             ; make into binary 0-9 range

a2iloop:    stxd                        ; save new digit value to stack

            glo   rd                    ; shift rd left one bit, put result
            shl                         ;  into re.0:m(r2) temporarily
            str   r2
            ghi   rd
            shlc
            plo   re

            ldn   r2                    ; shift re.0:m(r2) left one bit
            shl                         ;  to give rd x 4
            str   r2
            glo   re
            shlc
            plo   re

            glo   rd                    ; add rd x 4 back to rd to give
            add                         ;  result of rd x 5
            plo   rd
            glo   re
            str   r2
            ghi   rd
            adc
            phi   rd

            irx                         ; discard intermediate  value

            glo   rd                    ; shift rd left one bit to give
            shl                         ;  rd x 10
            plo   rd
            ghi   rd
            shlc
            phi   rd

            glo   rd                    ; add new digit into result in rd
            add
            plo   rd

            lda   rf                    ; get next character

            sdi   '9'                   ; if greater than 9, exit with df=0
            bnf   a2iend

            sdi   9                     ; if 0 or greater, loop, else df=0
            bdf   a2iloop

a2iend:     dec   rf                    ; back up to non-digit and return
            sep   sret






hexin:      ldi   0                      ; clear holding register
            plo   re

            plo   rd                     ; clear result value
            phi   rd

hexnext:    lda   rf                     ; get next char, end if null
            bz    hexend

            smi   1+'f'                  ; if greater than 'f', end
            bdf   hexend

            adi   1+'f'-'a'              ; if 'a'-'f', make 0-5, keep
            bdf   hexten

            smi   1+'F'-'a'              ; if greater than 'F', end
            bdf   hexend

            adi   1+'F'-'A'              ; if 'A'-'F', make 0-5, keep
            bdf   hexten

            smi   1+'9'-'A'              ; if greater than '9', end
            bdf   hexend

            adi   1+'9'-'0'              ; if '0'-'9', make 0-9, keep
            bdf   hexone

hexend:     dec   rf                     ; back to non-hex and return
            sep   sret

hexten:     adi   10                     ; make 'a'-'f' values 10-15
 
hexone:     str   r2                     ; save value of this digit

            glo   re                     ; move prior lsb into new msb
            phi   rd

            glo   rd                     ; save current lsb for later
            plo   re

            shl                          ; move least sig digit to most
            shl
            shl
            shl

            or                           ; put new digit into least sig
            plo   rd

            br    hexnext                ; loop back and check next char





            ; Convert 16-bit number in RD to ASCII hex reprensation into the
            ; buffer pointed to by RF. This calls hexout twice.

hexout4:    ldi   hexout2.0
            stxd
            ghi   rd

            br    hexout


            ; Convert 8-bit number in RD.0 to ASCII hex reprensation into the
            ; buffer pointed to by RF.

hexout2:    ldi   hexoutr.0
            stxd
            glo   rd
 
hexout:     str   r2
            shr
            shr
            shr
            shr

            smi   10
            bnf   hexskp1
            adi   'A'-'0'-10
hexskp1:    adi   '0'+10

            str   rf
            inc   rf

            lda   r2
            ani   0fh

            smi   10
            bnf   hexskp2
            adi   'A'-'0'-10
hexskp2:    adi   '0'+10

            str   rf
            inc   rf

            ldx
            plo   r3

hexoutr:    sep   sret


            ; Test if D contains a symbol terminating character, that is,
            ; a character that is not alphanumeric. This simply calls isalnum
            ; and inverts the result. The character is returned unchanged.
 
isterm:     sep   scall
            dw    isalnum

            shlc
            xri   1
            shrc

            sep   sret


            ; Test if D contains an alphanumeric character, that is, 0-9,
            ; A-Z, or a-z. If so, return DF set, otherwise DF is cleared.
            ; The passed character is returned unchanged either way.
 
isalnum:    smi   '0'                   ; if less than 0, no
            bnf   alnumret

            sdi   '9'-'0'               ; if 9 or less, yes
            bdf   alnumret

            sdi   '9'-'A'               ; if A or greater, check alpha
            bdf   alphatst

alnumret:   glo   re                    ; restore and return
            sep   sret


            ; Test if D contains an alpha character, that is, A-F or a-f.
            ; If so, return DF set, otherwise DF is cleared. The passed
            ; character is returned unchanged either way.
 
isalpha:    smi   'A'                   ; if less than A, no
            bnf   alpharet

alphatst:   sdi   'Z'-'A'               ; if Z or less, yes
            bdf   alpharet

            sdi   'Z'-'a'               ; if less than a, no
            bnf   alpharet

            sdi   'z'-'a'               ; if z or less, yes

alpharet:   glo   re                    ; restore and return
            sep   sret

           
          #if $ > 0f900h
            #error Page F800 overflow
          #endif


            org   0f900h

            ; Converts a 16-bit number to an ASCII decimal string. This will
            ; output negative or positive numbers when called at intout, or
            ; positive numbers only at uintout. Leading zeroes are suppressed.
            ;
            ;   IN:   RD - number to convert
            ;         RF - pointer to buffer to place number at
            ;   OUT:  RD - destroyed
            ;         RF - points just past converted number

intout:     ghi   rd                    ; test if number is negative
            shl
            bnf   uintout

            glo   rd                    ; if so, subtract from zero to 
            sdi   0                     ;  convert to positive
            plo   rd
            ghi   rd
            sdbi  0
            phi   rd

            ldi   '-'                   ; output minus sign to buffer
            str   rf
            inc   rf

uintout:    glo   rc                    ; need for pointer to constants
            stxd
            ghi   rc
            stxd

            ldi   divisor.1             ; get pointer to constants table
            phi   rc
            ldi   divisor.0
            plo   rc

            sex   rc                    ; arithmatic operations against table

            ldi   0                     ; clear dividend
            plo   re

            br    i2adig                ; start division

            ; This divides by the constant in the table by repeated
            ; subtraction. For small dividends like this, it's faster than
            ; more complex algorithms.

i2adiv:     phi   rd                    ; update with result of subtraction
            ldn   r2
            plo   rd

            inc   rc                    ; back to lsb, increment dividend
            inc   re

i2adig:     glo   rd                    ; subtract constant from number but
            sm                          ;  dont update result yet
            str   r2
            dec   rc
            ghi   rd
            smb

            bdf   i2adiv                ; loop if result is positive

            glo   re                    ; if result is zero, skip output
            bz    i2azero

            ani   15                    ; mask off leading zero flag

            adi   '0'                   ; convert to digit and put in buffer
            str   rf
            inc   rf

            ldi   16                    ; set zero flag bit in counter
            plo   re

i2azero:    dec   rc                    ; move to next divisor in table,
            ldn   rc                    ;  keep looping until last one
            bnz   i2adig

            glo   rd                    ; what's left is the last digit,
            adi   '0'                   ;  add it to the buffer
            str   rf
            inc   rf

            br    sretrc


            ; Table of divisors used by intout. We don't need 1 because that
            ; is just the remainder, of course. Table is used from top down.

            db    0
            dw    10, 100, 1000, 10000
divisor:    equ   $-1


            ; Get the time of day from the hardware clock into the buffer
            ; at RF in the order that Elf/OS expects: M, D, Y, H, M, S.

gettod:     sex   r3                    ; output register d address to rtc

          #if RTC_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    RTC_GROUP
          #endif

            out   RTC_PORT
            db    2dh

            br    todhold               ; go to busy bit check algorithm

todbusy:    sex   r3                    ; clear hold bit
            out   RTC_PORT
            db    10h

todhold:    out   RTC_PORT              ; set hold bit
            db    11h

            sex   r2                    ; wait until busy bit is clear
            inp   RTC_PORT
            ani   02h
            bnz   todbusy

            glo   rc                    ; save so we can use as table pointer
            stxd
            ghi   rd
            stxd

            ghi   r3                    ; get pointer to register table
            phi   rc
            ldi   clocktab.0
            plo   rc

getnext:    sex   rc                    ; output tens address, inc pointer
            out   RTC_PORT

            sex   r2                    ; input tens and multiply by 10
            inp   RTC_PORT
            ani   0fh
            str   r2
            shl
            shl
            add
            shl
            stxd                        ; decrement for room for next inp

            sex   rc                    ; output ones address, inc pointer
            out   RTC_PORT

            sex   r2                    ; input ones and add to tens
            inp   RTC_PORT
            ani   0fh
            inc   r2
            add

            str   rf                    ; save to output buffer and bump
            inc   rf

            ldn   rc                    ; continue if more digits to fetch
            bnz   getnext

            sex   r3                    ; clear hold bit
            out   RTC_PORT
            db    2dh
            out   RTC_PORT
            db    10h

todretn:    
          #if RTC_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    NO_GROUP
          #endif

sretrc:     inc   r2                    ; restore table pointer register
            lda   r2
            phi   rc
            ldn   r2
            plo   rc

            sep   sret


            ; Set the time on the 72421 RTC chip. This reinitializes the
            ; chip when it sets the time so that it can properly setup a
            ; new system or after the clock battery has been replaced. This
            ; also resets the internal fraction of second to zero so the
            ; time set is precise and will roll over one second later.

settod:     glo   rc                    ; save so we can use as table pointer
            stxd
            ghi   rc
            stxd

          #if RTC_GROUP
            sex   r3
            out   EXP_PORT              ; make sure default expander group
            db    RTC_GROUP
          #endif

            ghi   r3                    ; get pointer to table of data
            phi   rc
            ldi   clockini.0
            plo   rc

            sex   rc                    ; port output from table

setinit:    out   RTC_PORT              ; output values until zero reached
            ldn   rc
            bnz   setinit

            inc   rc                    ; skip zero marker and restore x
            sex   r2

            ; Now that the chip is initialized, set the time into the chip.

setnext:    ldi   0                     ; clear tens counter
            plo   re

            lda   rf                    ; load value, advance pointer

settens:    inc   re                    ; divide by 10 by subtraction
            smi   10
            bdf   settens

            adi   10h + 10              ; adjust remainder and push to stack
            stxd

            glo   re                    ; push tens to stack
            adi   10h - 1
            str   r2

            sex   rc                    ; output tens address, inc pointer
            out   RTC_PORT
            sex   r2                    ; output tens value, pop stack
            out   RTC_PORT

            sex   rc                    ; output ones address, inc pointer
            out   RTC_PORT
            sex   r2                    ; output ones value, pop stack
            out   RTC_PORT

            dec   r2                    ; put stack pointer back

            ldn   rc                    ; continue if more digits to fetch
            bnz   setnext

            sex   r3                    ; start the clock running
            out   RTC_PORT
            db    2fh
            out   RTC_PORT
            db    14h
            
            br    todretn               ; restore register and return


clockini:   db    2fh,17h
            db    2eh,10h
            db    2dh,10h
            db    2ch,10h
            db    0

            ; Table of the time-of-day digit addresses in the RTC 72421
            ; chip in the order that Elf/OS presents the date.

clocktab:   db    29h                   ; month
            db    28h
            db    27h                   ; day
            db    26h
            db    2bh                   ; year
            db    2ah
            db    25h                   ; hour
            db    24h
            db    23h                   ; minute
            db    22h
            db    21h                   ; second
            db    20h
            db    0


            ; Test if D contains a hex character, that is, 0-9, A-F, or a-f.
            ; If so, return DF set, otherwise DF is cleared. The passed
            ; character is returned unchanged either way.
 
ishex:      sdi   'f'
            bnf   hexret

            sdi   'f'-'a'
            bdf   hexret

            sdi   'F'-'a'
            bnf   hexret

            sdi   'F'-'A'
            bdf   hexret

            sdi   '9'-'A'
            bdf   numtest

hexret:     glo   re
            sep   sret


            ; Test if D contains a numeric character, that is, 0-9.
            ; If so, return DF set, otherwise DF is cleared. The passed
            ; character is returned unchanged either way.
 
isnum:      sdi   '9'
            bnf   numret

numtest:    sdi   '9'-'0'

numret:     glo   re                    ; restore and return
            sep   sret

 

          #if $ > 0fa00h
            #error Page F900 overflow
          #endif

            org   0fa00h

            ; Bits in CF interface address port

#define IDE_A_COUNT 80h                 ; dma sector count
#define IDE_A_DMOUT 40h                 ; dma out enable
#define IDE_A_DMAIN 20h                 ; dma in enable
#define IDE_A_STOP  00h                 ; dma in enable

            ; IDE register addresses

#define IDE_R_ERROR 01h
#define IDE_R_FEAT  01h
#define IDE_R_COUNT 02h
#define IDE_R_SECT  03h
#define IDE_R_CYLLO 04h
#define IDE_R_CYLHI 05h
#define IDE_R_HEAD  06h
#define IDE_R_STAT  07h
#define IDE_R_CMND  07h

            ; Bits in IDE status register

#define IDE_S_BUSY  80h                 ; busy
#define IDE_S_RDY   40h                 ; ready
#define IDE_S_DRQ   08h                 ; data request
#define IDE_S_ERR   01h                 ; error

            ; IDE head register bits

#define IDE_H_CHS   0a0h
#define IDE_H_LBA   0e0h

            ; IDE command code values

#define IDE_C_READ  20h                 ; read sector
#define IDE_C_WRITE 30h                 ; write sector
#define IDE_C_FEAT  0efh                ; set feature

            ; IDE features

#define IDE_F_8BIT  01h                 ; 8-bit mode

cfreset:    sex   r3                    ; use inline arguments

          #if IDE_GROUP
            out   EXP_PORT              ; select ide port group
            db    IDE_GROUP
          #endif

            sep   scall                 ; wait until drive ready
            dw    waitrdy
            bdf   ideret

            sex   r3                    ; use inline arguments

            out   IDE_SELECT            ; select lba mode and drive 0
            db    IDE_R_HEAD
            out   IDE_DATA
            db    IDE_H_LBA

            out   IDE_SELECT            ; enable feature 8 bit mode
            db    IDE_R_FEAT
            out   IDE_DATA
            db    IDE_F_8BIT 

            out   IDE_SELECT            ; send set feature command
            db    IDE_R_CMND
            out   IDE_DATA
            db    IDE_C_FEAT 

waitret:    sep   scall
            dw    waitrdy
ideret:
          #if IDE_GROUP
            sex   r3
            out   EXP_PORT              ; leave as default group
            db    NO_GROUP
          #endif

            sep   sret


waitrdy:    sex   r3

            out   IDE_SELECT            ; select status register
            db    IDE_R_STAT

            sex   r2                    ; inp result to stack

looprdy:    inp   IDE_DATA              ; wait for rdy set and bsy clear
            xri   IDE_S_RDY
            ani   IDE_S_RDY+IDE_S_BUSY
            bnz   looprdy

            ldn   r2                    ; error if err is set
            ani   IDE_S_ERR
            bnz   rdyerr

            ldn   r2                    ; get status back, return success
            adi   0
            sep   sret

rdyerr:     sex   r3                    ; select error register
            out   IDE_SELECT
            db    IDE_R_ERROR

            sex   r2                    ; inp result onto stack

            inp   IDE_DATA              ; get error status, return failure
            smi   0
            sep   sret


            ; Disk read and write share mostly common code, there is just a
            ; difference in two varaibles: what command to send to the drive
            ; and what DMA direction to enable for the transfer. So we just
            ; set these onto the stack appropriately before the routine.

            ; Write operations use the IDE write command and DMA OUT.

cfpriwr:    ghi   r8                    ; if second drive, do sdcard
            ani   1fh
            lbnz  sdwrite

cfwrite:    ldi   dmawrt.0              ; address of write routine
            stxd
            ldi   IDE_C_WRITE           ; write sector command
            stxd

            br    execide               ; jump to disk routine
 
            ; Read operations use the IDE read command and DMA IN.

cfprird:    ghi   r8                    ; if second drive, do sdcard
            ani   1fh
            lbnz  sdread

cfread:     ldi   dmard.0               ; address of read routine
            stxd
            ldi   IDE_C_READ            ; read sector command
            stxd

            ; Now the working part of the disk routine for the transfer.
 
execide:    sex   r3                    ; inline out arguments

          #if IDE_GROUP
            out   EXP_PORT              ; set ide expander group
            db    IDE_GROUP
          #endif

            sep   scall                 ; be sure drive is ready
            dw    waitrdy
            bdf   idepop

            glo   r8                    ; push lba high byte
            stxd
            ghi   r7                    ; push lba middle byte
            stxd
            glo   r7                    ; push lba low byte
            str   r2

            sex   r3                    ; set sector count to one
            out   IDE_SELECT
            db    IDE_R_COUNT
            out   IDE_DATA
            db    1

            out   IDE_SELECT            ; set lba low byte (r7.0)
            db    IDE_R_SECT
            sex   r2
            out   IDE_DATA

            sex   r3                    ; set lba middle byte (r7.1)
            out   IDE_SELECT
            db    IDE_R_CYLLO
            sex   r2
            out   IDE_DATA

            sex   r3                    ; set lha high byte (r8.0)
            out   IDE_SELECT
            db    IDE_R_CYLHI
            sex   r2
            out   IDE_DATA
 
            sex   r3                     ; execute read or write command
            out   IDE_SELECT
            db    IDE_R_CMND
            sex   r2
            out   IDE_DATA

            dec   r2                    ; make room for inp value

idebusy:    inp   IDE_DATA              ; wait until drive not busy
            ani   IDE_S_BUSY
            bnz   idebusy

            ldn   r2                    ; wait until drq or err is set
            ani   IDE_S_DRQ+IDE_S_ERR
            bz    idebusy

            lda   r2                    ; if error then return failure
            ani   IDE_S_ERR
            bnz   idepop

            ldn   r2                    ; jumnp to dmawrt or dmaread
            plo   r3

idepop:     lda   r2                    ; get saved status register value
            inc   r2

          #if IDE_GROUP
            sex   r3
            out   EXP_PORT              ; set ide expander group
            db    IDE_GROUP
          #endif

error:      smi   0
            sep   sret                  ; return to caller

dmawrt:     glo   rf                    ; set dma pointer to data buffer
            plo   r0
            ghi   rf
            phi   r0

            adi   2                     ; advance buffer pointer past end
            phi   rf

            sex   r3                    ; set dma count to one sector
            out   IDE_SELECT
            db    IDE_A_COUNT+1

            out   IDE_SELECT
            db    IDE_A_DMOUT

            br    waitret


dmard:      glo   rf                    ; set dma pointer to data buffer
            plo   r0
            str   r2                    ; put lsb on stack for compare later
            ghi   rf
            phi   r0

            adi   2                     ; advance buffer pointer past end
            phi   rf

            ldn   rf                    ; save byte just past end of buffer
            plo   re

            sex   r3                    ; set dma count to one sector
            out   IDE_SELECT
            db    IDE_A_COUNT+1

            out   IDE_SELECT            ; start dma input operation
            db    IDE_A_DMAIN

            sex   r2                    ; extra instruction for timing
            sex   r2

            glo   r0                    ; if no dma overrun, complete
            sm
            bz    waitret

            glo   re                    ; fix overrun byte, then complete
            str   rf
            br    waitret


boot:       ldi   stack.1               ; setup stack for mark opcode
            phi   r2
            ldi   stack.0
            plo   r2

            ldi   ideboot.1             ; setup stack for mark opcode
            phi   r6
            ldi   ideboot.0
            plo   r6

            lbr   initcall              ; jump to initialization

ideboot:    sep   scall                 ; initialize disk device
            dw    sdreset

            sep   scall
            dw    cfreset

            ldi   bootpg.1              ; load boot sector to $0100
            phi   rf
            ldi   bootpg.0
            plo   rf

            plo   r7                    ; set lba sector number to 0
            phi   r7
            plo   r8

            ldi   IDE_H_LBA             ; set lba mode
            phi   r8

            sep   scall                 ; read boot sector from disk
            dw    diskrd

            lbr   bootpg+6              ; jump to entry point


            ; Return the address of the last byte of RAM. This returns the
            ; RAM size that was discovered at boot rather than discovering
            ; each time or having a built-in value. As a side effect, this
            ; also updates the kernel variable containing the processor clock
            ; frequency since there is no other way for that to happen
            ; currently and this is a way to make it happen at start-up.

freemem:    ghi   re                    ; we only need to half-save for temp
            stxd

            ldi   clkfreq.1             ; get address of bios variable
            phi   re
            ldi   clkfreq.0
            plo   re

            ldi   k_clkfreq.1           ; get address of kernel variable
            phi   rf
            ldi   k_clkfreq.0
            plo   rf

            lda   re                    ; update kernel with clock freq
            str   rf
            inc   rf
            lda   re
            str   rf

            br    retvar                ; return freemem in rf


            ; Return a bitmap of devices present in the system. This now
            ; gives devices actually present, rather than just what has
            ; support in the BIOS. This is discovered at boot time and then
            ; that value is returned whenever requested.

            ;   0: IDE-like disk device
            ;   1: Floppy (no longer relevant)
            ;   2: Bit-banged serial
            ;   3: UART-based serial
            ;   4: Real-time clock
            ;   5: Non-volatile RAM

getdev:     ghi   re                    ; we only need to half-save for temp
            stxd

            ldi   devbits.1             ; get address of device bitmap
            phi   re
            ldi   devbits.0
            plo   re

retvar:     lda   re                    ; return variable value in rf
            phi   rf
            lda   re
            plo   rf

            inc   r2                    ; restore re.1 from temp use
            ldn   r2
            phi   re

            sep   sret                  ; return to caller



          #if $ > 0fb00h
            #error Page FA00 overflow
          #endif


            org   0fb00h


            ; Initialize CDP1854 UART port and set RE to indicate UART in use.
            ; This was written for the 1802/Mini but is generic to the 1854
            ; since it doesn't access the extra control register that the
            ; 1802/Mini has. This means it runs at whatever baud rate the
            ; hardware has setup since there isn't any software control on
setbd:      ; a generic 1854 implementation.

          #ifdef UART_DETECT
            BRMK  usebbang
          #endif
 
          #if UART_GROUP
            sex   r3
            out   EXP_PORT              ; make sure default expander group
            db    UART_GROUP
            sex   r2
          #endif

            inp   UART_DATA
            inp   UART_STATUS

            inp   UART_STATUS
            ani   2fh
            bnz   usebbang

            sex   r3
            out   UART_STATUS
            db    19h                 ; 8 data bits, 1 stop bit, no parity

          #if UART_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    NO_GROUP
          #endif

            ldi   1
            phi   re
            sep   sret

usebbang:   lbr   btimalc


; READ54 inputs character from the 1854 UART by jumping to UREAD54 if baud
; rate in RE.1 is set to zero, and from the bit-banged UART otherwise.

read:       ghi   re
            shr
            bnz   bread
            br    uread

; Output character through the 1854 UART if baud rate in RE.1 is zero by
; jumping to UTYPE54, or through bit-banged port otherwise.

type:       ghi   re
            shr
            bnz   btype
            br    utype


; UREAD54 inputs character from the 1854 UART and echos character to output
; if RE.1 bit zero is set by falling through to UTYPE54 after input.

uread:      ghi   re
            shr

          #if UART_GROUP
            sex   r3
            out   EXP_PORT
            db    UART_GROUP
            sex   r2
          #endif

ureadlp:    inp   UART_STATUS
            ani   1
            bz    ureadlp

            inp   UART_DATA

            bnf   utypert
            plo   re


            ; UTYPE54 outputs character in D through 1854 UART.

          #if UART_GROUP
            br    uecho

utype:      sex   r3
            out   EXP_PORT
            db    UART_GROUP
            sex   r2

uecho:      inp   UART_STATUS
          #else
utype:      inp   UART_STATUS
          #endif

            shl
            bnf   utype

            glo   re
            str   r2
            out   UART_DATA
            dec   r2

utypert:
          #if UART_GROUP
            sex   r3
            out   EXP_PORT
            db    NO_GROUP
          #endif

            sep   sret


            ; UTEST54 returns DF=1 if an input character is available from
utest:      ; the 1854 UART, and DF=0 otherwise.

          #if UART_GROUP
            sex   r3
            out   EXP_PORT
            db    UART_GROUP
            sex   r2
          #endif

            inp   UART_STATUS
            shr

          #if UART_GROUP
            sex   r3
            out   EXP_PORT
            db    NO_GROUP
          #endif

            sep   sret

; End of 1854 UART send and receive code.


            ; The recvwait call receives a character through the serial port
            ; waiting indefinitely. This is the core of the normal read call
            ; and is only callable via SEP. This requires unpack to be called
            ; first to setup the time delay value at M(R2).

bread:      ghi   re                    ; remove echo bit from delay, get 1's
            shr                         ;  complement, and save on stack
            sdi   0
            str   r2

            smi   192                   ; if higher than 192, leave as it is
            bdf   breprep

            shl                         ; multiply excess by two and add back
            add                         ;  to value, update on stack
            str   r2

breprep:    ldi   0ffh
            plo   re

            ldn   r2                    ; get half for delay to middle of start
            shrc                        ;  bit, start delay calculation

brewait:    BRMK  brewait               ; wait here until start bit comes in,

bredely:    adi   4
            bnf   bredely               ;  jump based on first delay subtract

            shr                         ; separate bit 1 and 0 into D and DF,
            bnf   breoddc               ;  handle odd and even separately

            bnz   bretest               ; for even counts, add 2 cycles if
            br    bretest               ;  bit 1 non-zero, and 4 otherwise

breoddc:    lsnz                        ; for odd counts, add 3 cycles if
            br    bretest               ;  bit 1 non-zero, and 5 otherwise

bretest:    BRMK  bremark               ; if ef2 is asserted, is a space,

            glo   re
            shr
            br    bresave

bremark:    glo   re
            shr
            ori   128                   ; otherwise, for mark, shift a one

bresave:    plo   re

            ldn   r2
            bdf   bredely


            ; Done receiving bits

brestop:    BRSP  brestop               ; wait for stop bit

            ghi   re                    ; if echo flag clear, just return it
            shr
            bdf   btype

            glo   re
            sep   sret


            ; The send routine outputs the character in RE.0 through the serial
            ; interface. This requires the delay timer value to be at M(R2)
            ; which is setup by calling unpack first. This is inlined into
            ; nbread but can also be called separately using SEP.

btype:      glo   re
            stxd

            ghi   re                    ; remove echo bit from delay, get 1's
            shr                         ;  complement, and save on stack
            sdi   0
            str   r2

            smi   192                   ; if higher than 192, leave as it is
            bdf   btywait

            shl                         ; multiply excess by two and add back
            add                         ;  to value, update on stack
            str   r2




            ; Delay for the stop bit

btywait:    ldn   r2                    ; Delay for one bit time before start
            adi   40
            bdf   btystrt

btydly1:    adi   4                     ;  bit so we can be called back-to-
            bnf   btydly1               ;  back without a start bit violation





            ; Send the start bit

btystrt:    SESP

            ldn   r2                    ; Delay for one bit time before start
btydly2:    adi   4                     ;  bit so we can be called back-to-
            bnf   btydly2               ;  back without a start bit violation

            shr                         ; separate bit 1 and 0 into D and DF,
            bnf   btyodds               ;  handle odd and even separately

            bnz   btyinit               ; for even counts, add 2 cycles if
            br    btyinit               ;  bit 1 non-zero, and 4 otherwise

btyodds:    lsnz                        ; for odd counts, add 3 cycles if
            br    btyinit               ;  bit 1 non-zero, and 5 otherwise




            ; Shift a one bit into the shift register to mark end

btyinit:    glo   re
            smi   0
            shrc
            plo   re

            bdf   btymark


            ; Loop through the data bits and send

btyspac:    SESP
            SESP

btyloop:    ldn   r2                    ;  advance the stack pointer back
btydly3:    adi   4                     ;  to character value, then delay
            bnf   btydly3               ;  for one bit time

            shr                         ; separate bit 1 and 0 into D and DF,
            bnf   btyoddc               ;  handle odd and even separately

            bnz   btyshft               ; for even counts, add 2 cycles if
            br    btyshft               ;  bit 1 non-zero, and 4 otherwise

btyoddc:    lsnz                        ; for odd counts, add 3 cycles if
            br    btyshft               ;  bit 1 non-zero, and 5 otherwise

btyshft:    glo   re
            shr
            plo   re

            bnf   btyspac

btymark:    SEMK
            bnz   btyloop



            ; Retrieve saved character and return

btyretn:    inc   r2
            ldn   r2
            sep   sret





btest:      adi   0                   ; if no break, return df clear
            BRMK  nobreak

            smi   0                   ; return df set, wait for end
break:      BRSP  break

nobreak:    sep   sret                ; return result


; Set baud rate and character format for the 1854 UART. This does a bunch
; of conversions and shifts since the original BIOS call is based on the
; 8250 UART registers, and we want to be compatible with that.

usetbd:     ani   7                     ; mask baud rate bits,
            lsz                         ;  if not zero,
            adi   1                     ;  add one

            shl                         ; shift left,
            ori   32                    ;  set no jumper bit

          #if UART_GROUP
            sex   r3
            out   EXP_PORT
            db    UART_GROUP
            sex   r2
          #endif

            str   r2                    ; output to aux control register
            out   UART_STATUS
            dec   r2

            glo   re                    ; get argument again,
            shlc                        ;  shift bits 6-7 to 0-1,
            shlc                        ;  through df bit
            shlc
            ani   3                     ; mask parity bits, invert parity
            xri   1+16                  ; enable, set wls2 bit, and save
            str   r2

            glo   re                    ; get argument again,
            shr                         ;  shift bit 4 to 3,
            ani   8                     ;  mask bit 3
            or                          ;  combine with previous value,

            str   r2                    ;  output to control register
            out   UART_STATUS
            dec   r2

          #if UART_GROUP
            sex   r3
            out   EXP_PORT
            db    NO_GROUP
          #endif

            shl
            sep   sret


          #if $ > 0fc00h
            #error Page FB00 overflow
          #endif


            org     0fc00h

initcall:   ldi     call.1             ; address of scall
            phi     r4
            ldi     call.0
            plo     r4

            ldi     ret.1              ; address of sret
            phi     r5
            ldi     ret.0
            plo     r5

            dec     r2                 ; sret needs to pop r6
            dec     r2

            sep     r5                 ; jump to sret


            ; Compare two strings pointed to by RF and RF and return a byte
            ; in D indicating comparison result. If equal, D is 0, else if
            ; RF < RD, D is -1, else if RF > RD, D is 1.

strcmp:     sex   rd

cmploop:    lda   rf
            bz    strend

            sm
            inc   rd
            bz    cmploop

            bnf   cmpless

            ldi   1
cmpret:     sep   sret

strend:     lda   rd
            bz    cmpret

cmpless:    ldi   -1
            sep   sret




            ; Trim leading whitespace (space or any control characters)
            ; from zero-terminated string pointed to by RF. Updates RF to
            ; first non- whitespace character, or terminating null.

ltrim:      lda   rf
            bz    trimret

            sdi   ' '
            bdf   ltrim

trimret:    dec   rf
            sep   sret


            ; Copy the string pointed to by RF to RD, up to, and including,
            ; a terminating null. Note that RF is advanced past the null,
            ; but RD points to the null. Odd handling, but preserved from
            ; the original implementation in case there are dependencies.

strloop:    inc   rd

strcpy:     lda   rf
            str   rd
            bnz   strloop

            sep   sret


            ; Copy memory from RF to RD for RC bytes. Only copies upwards,
            ; so it is unsafe for RD to be within the source (although it
            ; it ok for RF to be within the destinaton). RC is zeroed.

memloop:    lda   rf
            str   rd
            inc   rd
            dec   rc

memcpy:     glo   rc
            bnz   memloop
            ghi   rc
            bnz   memloop

            sep   sret


            ; Multiply two 16-bit numbers to get a 16-bit result. The input
            ; numbers are in RF and RD and the result is returned in RB.


mul16:      ldi   16                    ; 16 bits to process
            plo   re

            ldi   0
            plo   rb
            phi   rb

mulloop:    ghi   rf                    ; copy multiplier into low 16 bits
            shr                         ;  of product while shifting first bit
            phi   rf
            glo   rf
            shrc
            plo   rf

            bnf   mulskip               ; skip addition if bit is zero

            glo   rd                    ; add multiplicand into high 16 bits
            str   r2                    ;  of product
            glo   rb
            add
            plo   rb
            ghi   rd
            str   r2
            ghi   rb
            adc                         ; carry bit will get shifted in
            phi   rb

mulskip:    glo   rd                    ; right shift product, while also
            shl                        ;  shifting out next multiplier bit
            plo   rd
            ghi   rd
            shlc
            phi   rd

            dec   re                    ; keep going until 16 bits done
            glo   re
            bnz   mulloop

            sep   sret                  ; product is complete





            ; Divide two 16-bit numbers to get a 16-bit result plus a 16-bit
            ; remainder. The input numbers are in RF and RD and the result
            ; RF/RD is returned in RB with the remainder in RF.
 
div16:      ghi   re                    ; temporary place for subtraction lsb
            stxd

            ldi   16                    ; number of bits to process
            plo   re

            glo   rf                    ; transfer dividend to quotient while
            shl                         ;  shifting out first dividend bit
            plo   rb
            ghi   rf
            shlc
            phi   rb

            ldi   0                     ; clear remainder to start
            plo   rf
            phi   rf

divloop:    glo   rf                    ; shift dividend bit into remainder
            shlc
            plo   rf
            ghi   rf
            shlc
            phi   rf

            glo   rd                    ; subtract divisor from remainder
            str   r2                    ;  but do not update remainder yet
            glo   rf
            sm
            phi   re
            ghi   rd
            str   r2
            ghi   rf
            smb

            bnf   divskip               ; if negative do not update remainder

            phi   rf                    ; transfer difference to remainder
            ghi   re
            plo   rf

divskip:    glo   rb                    ; shift borrow bit into result and
            shlc                        ;  shift dividend bit into remainder
            plo   rb
            ghi   rb
            shlc
            phi   rb

            dec   re                    ; repeat until all 16 bits done
            glo   re
            bnz   divloop

            irx                         ; restore temporary register
            ldx
            phi   re

            sep   sret                  ; return to caller



            ; Output a zero-terminated string to current console device.
            ;
            ;   IN:   RF - pointer to string to output
            ;   OUT:  RD - set to zero
            ;         RF - left just past terminating zero byte

msglp:      sep   scall                 ; call type routine
            dw    type

msg:        lda   rf                    ; load byte from message
            bnz   msglp                 ; return if last byte

            sep   sret


            ; Output an inline zero-terminated string to console device.
            ;
            ;   OUT:  RD - set to zero

inmsglp:    sep   scall
            dw    type

inmsg:      lda   r6
            bnz   inmsglp

            sep   sret




input:      ldi   1                     ; preset input length to 256
            phi   rc
            shr
            plo   rc

inputl:     ghi   re                    ; disable echo
            stxd
            ani   0feh
            phi   re

            glo   rb
            stxd
            ghi   rb
            stxd

            ldi   0
            plo   rb
            phi   rb

inloop:     sep   scall
            dw    read

            smi   127
            bdf   inloop

            adi   127-32
            bdf   print

            adi   32-13
            bz    cr

            adi   13-8
            bz    bs

            adi   8-3
            bnz   inloop

            ldi   1
            br    endin

cr:         glo   re
            sep   scall
            dw    type

            ldi   0

endin:      shr
            str   rf

            irx
            ldxa
            phi   rb
            ldxa
            plo   rb

            ldx
            phi   re
            
            sep   sret

print:      glo   rc
            bnz   save
            ghi   rc
            bz    inloop

save:       glo   re
            str   rf

            inc   rf
            inc   rb
            dec   rc

            sep   scall
            dw    type
            br    inloop

bs:         glo   rb
            bnz   back
            ghi   rb
            bz    inloop

back:       dec   rf
            dec   rb
            inc   rc

            sep   scall
            dw    inmsg
            db    8,32,8,0
            br    inloop
           

          #if $ > 0fd00h
            #error Page FC00 overflow
          #endif


            org   0fd00h


          ; The following two pages are the SD Card storage driver for Tony\
          ; Hefner's SPI card for the 1802/Mini bus:
          ;
          ; https://github.com/arhefner/1802-Mini-SPI-DMA
          ;
          ; This driver supports SDSC, SDHC, and SDXC cards up to the first
          ; 8GB of capacity, and  also supports hot-swapping of cards.
          ;
          ; There are three kinds of subroutine calls in use here. The main
          ; entry points of SDRESET, SDREAD, and SDWRITE are all called with
          ; standard SCRT conventions like all of Elf/OS uses. There are also
          ; two other methods used which have much less overhead than SCRT.
          ;
          ; For calling subroutines in the same page, we use a calling 
          ; convention of GLO R3,BR SUBR; the GLO R3 is to pass the return
          ; address to the subroutine, which it increments by 2 to get the
          ; return address past the BR instruction, and saves it somewhere.
          ; To return, the address is simply stuffed into the PC with PLO R3.

          ; For calling subroutines in the other page, we use SEP R9 to 
          ; switch PC to one in the other page. In this case, we follow the
          ; SEP R9 with the address of the subroutine within the other page.
          ; R9 is initialized to point to a LDA R3,PLO R9 sequence which
          ; gets the inline address argument and jumps to it. To save having
          ; to reset R9, each subroutine return (consisting of SEP R3) is
          ; followed by this same sequence to R9 is always pointing to one
          ; or another instance of it.


          ; Hardware definitions for the SPI card:

#define SPI_NONE   0                    ; select no device
#define SPI_OUT0   1                    ; general output bit
#define SPI_OUT1   2                    ; general output bit
#define SPI_CS0    4                    ; chip select device 0
#define SPI_CS1    8                    ; chip select device 1
#define SPI_128    16                   ; high bit of dma counter
#define SPI_DMAIN  32                   ; enable dma input transfer
#define SPI_DMAOUT 64                   ; enable dma output transfer
#define SPI_COUNT  128                  ; set dma transfer byte count


          ; Note that the following must be a power of two as 512 needs
          ; to be exactly divisible by it to transfer a whole sector.

#define SPI_BURST 64                    ; number of bytes per dma operation


          ; The following are the SD Card command packets the we use in
          ; the driver. The ones that are complete 6-byte packets are to
          ; be sent using SENDLIT, the ones that are just the selector byte
          ; are to be sent using SENDBLK which will create the rest.

#define SD_CMD0    40h,0,0,0,0,95h
#define SD_CMD8    48h,0,0,1,5,8fh
#define SD_CMD13   4dh,0,0,0,0,1
#define SD_CMD17   51h
#define SD_CMD24   58h
#define SD_ACMD41  69h,40h,0,0,0,1
#define SD_CMD55   77h,0,0,0,0,1
#define SD_CMD58   7ah,0,0,0,0,1


          ; SDRESET initializes the SD Card, if one is present. This should
          ; be called before the first read or write operations happen.

sdreset:    glo   r3                    ; save and intialize registers
            br    sdsetup

            glo   r3                    ; initialize sd card to spi mode
            br    spiinit 

            adi   0                     ; return with df clear
            br    sdfinal


          ; SDREAD reads a block from the SD Card; the block address is passed
          ; in R8:R7 and the pointer to the data buffer is in RF. If the read
          ; is successful, DF is cleared, otherwise it is set. If the initial
          ; read command times out or returns a card busy status, it means
          ; that the card is not in SPI mode and was probably just inserted,
          ; so the card is initialized and the read then re-tried.

sdprird:    ghi   r8                    ; if second drive, do sdcard
            ani   1fh
            lbnz  cfread

sdread:     glo   r3                    ; save and initialize registers
            br    sdsetup               ;  if busy then re-initialize
            bdf   reinit

            sep   r9                    ; read the block from disk
            db    sendblk
            db    SD_CMD17

            bz    rdblock               ; get the data if response is zero,
            bnf   sderror               ;  else other than timeout is error

reinit:     glo   r3                    ; if timeout, initialize sd card
            br    spiinit

            sep   r9                    ; resend block read command
            db    sendblk
            db    SD_CMD17

            bnz   sderror               ; timeout or non-zero is error

rdblock:    sep   r9                    ; receive data block start token
            db    recvspi

            xri   0feh                  ; other than 11111110 is an error,
            bnz   sderror               ;  including a timeout

            sep   r9                    ; get 512 data bytes to buffer
            db    recvbuf

            adi   0                     ; return with df clear
            br    sdfinal


          ; SDWRITE writes a block to the SD Card; the block address is passed 
          ; in R8:R7 and the pointer to the data buffer is in RF. If the write
          ; is successful, DF is cleared, otherwise it is set. Unlike in
          ; SDREAD, we do not intialize the card if the write command times
          ; out or the device is busy, but return error instead.
          ;
          ; This is because a write as the first operation to a newly inserted
          ; card is almost certainly wrong and will corrput data, probably it
          ; happened as a result of a card that was swapped while a file was
          ; open. So, it seems safer to let these fail.
 
sdpriwr:    ghi   r8                    ; if second drive, do sdcard
            ani   1fh
            lbnz  cfwrite

sdwrite:    glo   r3                    ; save and initialize registers
            br    sdsetup               ;  if busy then it's an error
            bdf   reinit

            sep   r9                    ; send block write command
            db    sendblk
            db    SD_CMD24
  
            bnz   sderror

            sep   r9                    ; send 512 bytes from buffer
            db    sendbuf

            ani   1fh                   ; response other than xxx00101 is
            xri   05h                   ;  error, including a timeout
            bnz   sderror

            sep   r9                    ; wait while write completes, if
            db    spibusy               ;  not within timeout, then error
            bdf   sderror

            sep   r9                    ; send get device status command
            db    sendcmd
            db    SD_CMD13

            bnz   get1err

            sep   r9                    ; get second byte of r2 response
            db    recvstk,1

            lda   r2                    ; not zero is an error
            bnz   sderror

            adi   0                     ; return with df clear
            br    sdfinal


          ; SDSETUP saves the registers we use and presets R9 for subroutine
          ; calls in the other page. RE is used for temporary storage of the
          ; return address since we are pushing to the stack here. This
          ; calls SPIWAKE which actually performs the return from here also.

sdsetup:    adi   2                     ; save return address following br
            plo   re

            ghi   re                    ; save to use for scratch and counter
            stxd

            glo   r9                    ; save to use for subroutine call
            stxd
            ghi   r9
            stxd

            ldi   subjump.1             ; initialize r9 for subroutine call
            phi   r9
            ldi   subjump.0
            plo   r9

            sep   r9                    ; send initial spi clock pulses
            db    spiwake


          ; INITSPI initializes an SD Card into SPI mode by sending the
          ; prescribed sequence of commands. One important part of this is
          ; discovery of whether the card is high capacity (HC or XC types)
          ; because this determines whether the data on the card is addressed
          ; by byte or by block. So this information is saved during initial-
          ; ization for later reference in sending read and write commands.

spiinit:    adi   2                     ; save return address following br
            str   r2

sdretry:    sep   r9                    ; send reset command
            db    sendcmd
            db    SD_CMD0

            xri   1                     ; timeout or other than 1 is error
            bnz   sdretry

            sep   r9                    ; send host voltage support
            db    sendcmd
            db    SD_CMD8

            xri   1                     ; timeout or other than 1 is error
            bnz   get4err

            sep   r9                    ; receive 4 more bytes of response
            db    recvstk,4

            inc   r2                    ; discard response
            inc   r2
            inc   r2
            inc   r2

waitini:    sep   r9                    ; send application command escape
            db    sendcmd
            db    SD_CMD55

            xri   1                     ; timeout or other than 1 is error
            bnz   sderror

            sep   r9                    ; send host capacity support
            db    sendcmd
            db    SD_ACMD41

            shr                         ; if not 0 or 1, then error
            bnz   sderror

            bdf   waitini               ; if not 0, then repeat until so

            sep   r9                    ; get ocr register
            db    sendcmd
            db    SD_CMD58

            bnz   get4err               ; fail on error or timeout

            sep   r9                    ; 4 more bytes of response
            db    recvstk,4

            inc   r2                    ; discard last three bytes
            inc   r2
            inc   r2

            ldi   ocrreg.1              ; pointer to byte to store ocr
            phi   re
            ldi   ocrreg.0
            plo   re

            lda   r2                    ; save first byte of response
            str   re

            ldn   r2                    ; return
            plo   r3


          ; R4ERROR and R1ERROR return from an error condition, first
          ; reading any outstanding bytes that the card needs to send.

get4err:    sep   r9                    ; receive extra 4 bytes
            db    recvstk,3

            inc   r2                    ; discard from stack
            inc   r2
            inc   r2

get1err:    sep   r9                    ; receive extra 1 byte
            db    recvstk,1

            inc   r2                    ; discard from stack

          ; Make sure DF is set on return from error condition.

sderror:    smi   0                     ; set df flag to signal error

sdfinal:    sex   r3                    ; output inline data

            out   SPI_CTRL              ; de-select sd card device
            db    SPI_NONE

            out   SPI_DATA              ; send clocks after de-selecting
            db    0ffh

           #if SPI_GROUP                ; restore group if it was changed
            out   EXP_PORT
            db    NO_GROUP
           #endif

            inc   r2                    ; restore r9 from stack
            lda   r2
            phi   r9
            lda   r2
            plo   r9

            ldn   r2                    ; restore re.1 from stack
            phi   re

            sep   sret                  ; return to caller


          #if $ > 0fe00h
            #error Page FD00 overflow
          #endif

            org   0fe00h


          ; After power-on an SD Card may require up to 74 clock pulses
          ; to be able to initialize; we send 80 since we can only send 80
          ; at a time. This gets send during bus reset, but also before each
          ; initial read or write command in case the card was hot-swapped.
          ; After sending, we fall through to checking if the card is busy.

spiwake:    glo   re                    ; return from sdsetup when done
            plo   r3

            sex   r9                    ; use inline out arguments

           #if SPI_GROUP
            out   EXP_PORT              ; set port group if not default
            db    SPI_GROUP
           #endif

            ldi   80/8                  ; 80 pulses send a byte at a time

spiclks:    out   SPI_DATA              ; send eight pulses, keep MOSI high
            db    0ffh

            smi   1                     ; loop if count not zero
            bnz   spiclks

            out   SPI_CTRL              ; assert chip select to sd card
            db    SPI_CS1


          ; Check if the card is busy, meaning that the MISO line is low
          ; rather than high. We need to wait for a timeout interval before
          ; deciding because it's possible (like if the machine was reset)
          ; that a previously-ordered write operation could be completing.
          ; Sending a CMD0 during a write operation could damage the SD Card
          ; so we want to be sure to avoid this possibility.

spibusy:    ldi   5+(FREQ_KHZ/40)       ; use about a one-second timeout
            phi   re

spiwait:    sex   r9                    ; send 8 clocks to warm up receiver
            out   SPI_DATA              ;  and clock in current line state
            db    0ffh

            sex   r2                    ; get the input line state, if not
            inp   SPI_DATA              ;  high, card is busy, return df set
            sdi   0feh
            bnf   spiidle

            dec   re
            ghi   re
            bnz   spiwait

spiidle:    sep   r3

          ; Entry point of subroutine calls. This is called via SEP R9 with
          ; individual subroutine address within the page passed in D, which
          ; it simply jumps to by storing to the lsb of the program counter.
          ; This is duplicated after each subroutine return so that the R9
          ; register does not need to be reset for each call.

subjump:    lda   r3
            plo   r9


          ; Send an inline literal 6-byte command packet to the card.

sendcmd:    sex   r9                    ; send 8 clocks before command to
            out   SPI_DATA              ;  warm up receiver
            db    0ffh

            sex   r3                    ; send inline data for 6 bytes
            br    sendpkt


          ; Send a block read or write command by building the command packet
          ; on the stack including the appropriate address from R8:R7 and
          ; then sending it. The OCR register byte that is retreived during
          ; card initialization is referenced to see if the card is high
          ; capacity or not so we know what address format to use. The first
          ; byte specifying the read or write command is passed inline.

sendblk:    sex   r9                    ; send 8 clocks before command to
            out   SPI_DATA              ;  warm up receiver
            db    0ffh

            sex   r2
            dec   r2                    ; for post-out opcode increment

            ldi   1                     ; dummy zero crc with stop bit
            stxd

          ; Different types of SD cards address content differently, so we
          ; need to handle two cases here depending on what kind of card we
          ; detected during the initialization process.

            ldi   ocrreg.1              ; get saved ccs flag from card init
            phi   re
            ldi   ocrreg.0
            plo   re

            ldn   re                    ; if set, card is high-capacity
            ani   40h
            bnz   sdhcblk

          ; SDSC cards address content by byte and so the Elf/OS block address
          ; needs to be multiplied by 512, which is nine left bit shifts, or
          ; one byte shift plus one extra bit.

            stxd                        ; lowest byte is always zero, store
            glo   r7                    ;  shifted left address in next three
            shl
            stxd
            ghi   r7
            shlc
            stxd
            glo   r8
            shlc
            stxd

            br    execcmd

          ; SDHC and SDXC cards address content in 512-byte blocks, which is
          ; the same as Elf/OS so we just store the block address into the
          ; low three bytes of the address in the command packet.

sdhcblk:    glo   r7                    ; we only use the low three bytes,
            stxd                        ;  the last one is always zero
            ghi   r7
            stxd
            glo   r8
            stxd
            ldi   0
            stxd

execcmd:    lda   r3                    ; copy inline command byte to stack
            str   r2

sendpkt:    ldi   6

spiloop:    out   SPI_DATA              ; send next byte, advance pointer,
            smi   1                     ;  decrement count, loop if more
            bnz   spiloop


          ; Receive a single byte through SPI, first skiping any $FF bytes
          ; which are idle time on the line. Returns the byte in D. If no
          ; non-$FF value is seen within one second, then a timeout occured,
          ; and $FF is returned in D with DF set. Otherwise, DF is cleared.

recvspi:    ldi   5+(FREQ_KHZ/40)       ; use about a one-second timeout
            phi   re

            dec   r2                    ; preserve current top of stack

recvwait:   sex   r9                    ; send ff to clock in new byte
            out   SPI_DATA
            db    0ffh

            sex   r2                    ; get byte, if not ff then exit
            inp   SPI_DATA              ;  with df clear, else set df
            smi   0ffh
            bnf   recvbyte

            dec   re                    ; decrement count, loop if more
            ghi   re
            bnz   recvwait

recvbyte:   lda   r2                    ; recover input byte and return
            sep   r3

            lda   r3                    ; subroutine entry jump vector
            plo   r9


          ; Receive bytes through SPI, pushing them onto the stack, for
          ; a length that is stored inline to the call. This receives
          ; immediately without skipping any $FF idle bytes.

recvstk:    lda   r3                    ; get inline length to receive
            plo   re

rstkloop:   sex   r9
            out   SPI_DATA
            db    0ffh

            sex   r2                    ; save byte to buffer
            dec   r2
            inp   SPI_DATA

            dec   re                    ; decrement received bytes count,
            glo   re
            bnz   rstkloop

            sep   r3                    ; return with df clear

            lda   r3
            plo   r9


          ; Send data through SPI from memory starting at RF for 512 bytes.
          ; This also sends two dummy CRC bytes after the buffer contents and
          ; leaves RF just past the sent data.

sendbuf:    sex   r9                    ; inline arguments for out

            out   SPI_CTRL              ; so we don't start unintentionally
            db    SPI_COUNT

            out   SPI_CTRL              ; enable dma out transfer mode
            db    SPI_CS1+SPI_DMAOUT

            out   SPI_DATA              ; send data block start token
            db    0feh

            glo   r9                    ; perform the dma transfer itself
            br    dmaxfer

            out   SPI_DATA              ; output two dummy crc bytes
            db    0
            out   SPI_DATA
            db    0

            br    recvspi               ; get response token


          ; Receive bytes through SPI into memory at RF for 512 bytes. This
          ; immediately puts bytes into memory without skipping any leading
          ; $FF bytes like recvspi does. This also receives and discards
          ; the two CRC bytes that follow the block data.

recvbuf:    sex   r9                    ; inline arguments for out

            out   SPI_CTRL              ; so we don't start unintentionally
            db    SPI_COUNT

            out   SPI_CTRL              ; enable dma-in transfer mode
            db    SPI_CS1+SPI_DMAIN

            out   SPI_DATA              ; prime the pump before  dma
            db    0ffh

            glo   r9                    ; perform the dma transfer itself
            br    dmaxfer

            out   SPI_DATA              ; get second crc byte and discard
            db    0ffh

            sep   r3                    ; return to caller

            lda   r3                    ; jump to next subroutine called
            plo   r9


            ; The core DMA transfer code used by both SENDBUF and RECVBUF,
            ; transferring 512 bytes in smaller DMA bursts. This is because
            ; DMA preempts interrupts on the 1802 and so large DMA operations
            ; can cause interrupts to get missed.

dmaxfer:    adi   2                     ; adjust and save return address
            plo   re

            ghi   rf                    ; set dma pointer to buffer
            phi   r0
            glo   rf
            plo   r0

            ldi   512/SPI_BURST         ; how many bursts for 512 bytes

dmaloop:    out   SPI_CTRL              ; start burst by loading counter
            db    SPI_COUNT+SPI_BURST

            smi   1                     ; decrement count, loop until done
            bnz   dmaloop
       
            out   SPI_CTRL              ; disable dma mode when finished
            db    SPI_CS1

            ghi   r0                    ; update buffer pointer to end
            phi   rf

            glo   re                    ; return to caller
            plo   r9


          #if $ > 0ff00h
            #error Page FE00 overflow
          #endif

            org   0ff00h

f_boot:     lbr   boot
f_type:     lbr   type
f_read:     lbr   read
f_msg:      lbr   msg
f_typex:    lbr   error
f_input:    lbr   input
f_strcmp:   lbr   strcmp
f_ltrim:    lbr   ltrim
f_strcpy:   lbr   strcpy
f_memcpy:   lbr   memcpy
f_wrtsec:   lbr   0
f_rdsec:    lbr   0
f_seek0:    lbr   0
f_seek:     lbr   0
f_drive:    lbr   0
f_setbd:    lbr   setbd
f_mul16:    lbr   mul16
f_div16:    lbr   div16
f_iderst:   lbr   error
f_idewrt:   lbr   diskwr
f_ideread:  lbr   diskrd
f_initcall: lbr   initcall
f_ideboot:  lbr   ideboot
f_hexin:    lbr   hexin
f_hexout2:  lbr   hexout2
f_hexout4:  lbr   hexout4
f_tty:      lbr   type
f_mover:    lbr   error
f_minimon:  lbr   error
f_freemem:  lbr   freemem
f_isnum:    lbr   isnum
f_atoi:     lbr   atoi
f_uintout:  lbr   uintout
f_intout:   lbr   intout
f_inmsg:    lbr   inmsg
f_inputl:   lbr   inputl
f_brktest:  lbr   error
f_findtkn:  lbr   findtkn
f_isalpha:  lbr   isalpha
f_ishex:    lbr   ishex
f_isalnum:  lbr   isalnum
f_idnum:    lbr   idnum
f_isterm:   lbr   isterm
f_getdev:   lbr   getdev


          #ifdef SET_BAUD
btimalc:    ldi   (FREQ_KHZ*5)/(SET_BAUD/25)-23
          #else

btimalc:    SEMK                      ; Make output in correct state

timersrt:   ldi   0                   ; Wait to make sure the line is idle,
timeidle:   smi   1                   ;  so we don't try to measure in the
            nop                         ;  middle of a character, we need to
            BRSP  timersrt            ;  get 256 consecutive loops without
            bnz   timeidle            ;  input asserted before this exits

timestrt:   BRMK  timestrt            ; Stall here until start bit begins

            nop                         ; Burn a half a loop's time here so
            ldi   1                   ;  that result rounds up if closer

timecnt1:   phi   re                  ; Count up in units of 9 machine cycles
timecnt2:   adi   1                   ;  per each loop, remembering the last
            lbz   timedone            ;  time that input is asserted, the
            BRSP  timecnt1            ;  very last of these will be just
            br    timecnt2            ;  before the start of the stop bit

timedone:   ldi   63                  ; Pre-load this value that we will 
            plo   re                  ;  need in the calculations later

            ghi   re                  ; Get timing loop value, subtract
            smi   23                  ;  offset of 23 counts, if less than
            bnf   timersrt            ;  this, then too low, go try again
          #endif

            bz    timegood            ; Fold both 23 and 24 into zero, this
            smi   1                   ;  adj is needed for 9600 at 1.8 Mhz

timegood:   phi   re                  ; Got a good measurement, save it

            smi   63                  ; Subtract 63 from time, if less than
            bnf   timekeep            ;  this, then keep the result as-is

timedivd:   smi   3                   ; Otherwise, divide the excess part
            inc   re                  ;  by three, adding to the 63 we saved
            bdf   timedivd            ;  earlier so results are 64-126
        
            glo   re                  ; Get result of division plus 63
            phi   re                  ;  and save over raw measurement

timekeep:   ghi   re                  ; Get final result and shift left one
            shl                         ;  bit to make room for echo flag, then
            adi   2+1                 ;  add 1 to baud rate and set echo flag

            phi   re                  ;  then store formatted result and
            sep   sret                ;  return to caller



            ; The entry points call at 0FFE0h and ret at 0FFF1h are indicated
            ; in Mike Riley's bios.inc as being deprecated, but the Elf/OS
            ; boot sector at least still needs them to work properly, as it
            ; uses these addresses rather than calling f_initcall. So we will
            ; keep them, and to avoid wasted space, we'll just put the actual
            ; call and ret code here instead of branching to them. Since they
            ; need a branch anyway to reset R4 or R5 on return, they can be 
            ; aligned properly with the fixed entry points with no waste.
            ;
            ; IMPORTANT CHANGE -- these routines have had the push and pop
            ; operations changed to store the MSB at the lower address as is
            ; more usual on the 1802. This is to allow future optimization
            ; using the 1804/5/6 extended instruction set. For now this is
            ; considered as an experimental change while impact is assessed.

            org     0ffd8h

callbr:     glo   r3
            plo   r6

            lda   r6                    ; get subroutine address
            phi   r3                    ; and put into r3
            lda   r6
            plo   r3

            glo   re
            sep   r3                    ; jump to called routine

            org 0ffe0h

            ; Entry point for CALL here.

call:       plo   re                    ; Save D
            sex   r2

            glo   r6                    ; save last R[6] to stack
            stxd
            ghi   r6
            stxd

            ghi   r3                    ; copy R[3] to R[6]
            phi   r6

            br    callbr                ; transfer control to subroutine

retbr:      irx                         ; restore next-prior return address
            ldxa                        ;  to r6 from stack
            phi   r6
            ldx
            plo   r6

            glo   re                    ; restore d and jump to return
            sep   r3                    ;  address taken from r6

            org 0fff1h

            ; Entry point for RET here.

ret:        plo   re                    ; save d and set x to 2
            sex   r2

            ghi   r6                    ; get return address from r6
            phi   r3
            glo   r6
            plo   r3

            br    retbr                 ; jump back to continuation


            org   0fff9h

version:    db    2,1,0
chsum:      db    0,0,0,0

