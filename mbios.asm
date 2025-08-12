;  Copyright 2024, David S. Madole <david@madole.net>
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

;define UART_DETECT                     ; use uart if no bit-bang cable

#ifdef 1802MINI
  #define BRMK         bn2              ; branch on serial mark
  #define BRSP         b2               ; branch on serial space
  #define SEMK         seq              ; set serial mark
  #define SESP         req              ; set serial space
  #define EXP_PORT     5                ; group i/o expander port
  #define EXP_MEMORY                    ; enable expansion memory
  #define IDE_GROUP    0                ; ide interface group
  #define IDE_SECOND   4                ; ide second interface group
  #define IDE_SELECT   2                ; ide interface address port
  #define IDE_DATA     3                ; ide interface data port
  #define RTC_GROUP    1                ; real time clock group
  #define RTC_PORT     3                ; real time clock port
  #define UART_GROUP   0                ; uart port group
  #define UART_DATA    6                ; uart data port
  #define UART_STATUS  7                ; uart status/command port
  #define SPI_GROUP    2
  #define SPI_CTRL     2
  #define SPI_DATA     3
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
  #define IDE_SECOND   4                ; ide second interface group
  #define IDE_SELECT   2                ; ide interface address port
  #define IDE_DATA     3                ; ide interface data port
  #define RTC_GROUP    1                ; real time clock group
  #define RTC_PORT     3                ; real time clock port
  #define UART_GROUP   0                ; uart port group
  #define UART_DATA    6                ; uart data port
  #define UART_STATUS  7                ; uart status/command port
  #define SPI_GROUP    2
  #define SPI_CTRL     2
  #define SPI_DATA     3
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
ocrreg:     equ   003bh
devbits:    equ   003ch                 ; f_getdev device present result
clkfreq:    equ   003eh                 ; processor clock frequency in khz
lastram:    equ   0040h                 ; f_freemem last ram address result
romcurr:    equ   0042h
diskmap:    equ   0043h

scratch:    equ   0080h                 ; pre-boot scratch buffer memory
stack:      equ   00ffh                 ; top of temporary booting stack
sector:     equ   0100h                 ; address to load boot block to


            ; Elf/OS Kernel Variables

o_wrmboot:  equ   0303h                 ; kernel warm-boot reinitialization
k_clkfreq:  equ   0470h                 ; processor clock frequency in khz




            ; Bits in CF interface address port

#define IDE_A_COUNT 80h                 ; dma sector count
#define IDE_A_DMOUT 40h                 ; dma out enable
#define IDE_A_DMAIN 20h                 ; dma in enable
#define IDE_A_STOP  00h                 ; dma in enable

            ; IDE register addresses

#define IDE_R_DATA  00h
#define IDE_R_ERROR 01h
#define IDE_R_FEAT  01h
#define IDE_R_COUNT 02h
#define IDE_R_SECT  03h
#define IDE_R_CYLLO 04h
#define IDE_R_CYLHI 05h
#define IDE_R_HEAD  06h
#define IDE_R_STAT  07h
#define IDE_R_CMND  07h
#define IDE_R_DCTRL 0eh
#define IDE_R_DADDR 0fh

            ; Bits in IDE status register

#define IDE_S_ERR   01h                 ; error
#define IDE_S_IDX   02h                 ; index mark
#define IDE_S_DRQ   08h                 ; data request
#define IDE_S_DSC   10h                 ; seek complete
#define IDE_S_RDY   40h                 ; ready
#define IDE_S_BUSY  80h                 ; busy

            ; IDE head register bits

#define IDE_H_DR0   000h
#define IDE_H_DR1   010h
#define IDE_H_CHS   0a0h
#define IDE_H_LBA   0e0h

            ; IDE command code values

#define IDE_C_READ  20h                 ; read sector
#define IDE_C_WRITE 30h                 ; write sector
#define IDE_C_IDENT 0ech                ; identify drive
#define IDE_C_FEAT  0efh                ; set feature

            ; IDE features

#define IDE_F_8BIT  01h                 ; 8-bit mode



          ; Hardware definitions for the SPI card:

#define SPI_CLEAR  0                    ; reset condition
#define SPI_NONE   3                    ; select no device
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
          ; be sent using SENDPKT, the ones that are just the selector byte
          ; are to be sent using SENDBLK for read or write commands, or
          ; SENDCMD for others, either of which will create the rest.

#define SD_CMD0    sendpkt,40h,0,0,0,0,95h
#define SD_CMD8    sendpkt,48h,0,0,1,5,8fh
#define SD_CMD9    sendcmd,49h
#define SD_CMD10   sendcmd,4ah
#define SD_CMD13   sendcmd,4dh
#define SD_CMD17   sendblk,51h
#define SD_CMD24   sendblk,58h
#define SD_ACMD41  sendpkt,69h,40h,0,0,0,1
#define SD_CMD55   sendcmd,77h
#define SD_CMD58   sendcmd,7ah



#define DEV_SERIAL 1
#define DEV_NITRO  3
#define DEV_IDE    4
#define DEV_UART   8
#define DEV_RTC    16


          ; The BIOS is divided into two parts, an always-resident part
          ; from F800-FFFF that is always mapped into memory and an
          ; initialization-only part that is F000-F7FF.
          ;
          ; This initialization part is used for things that only need
          ; to happen at a hard reset and never again, so that ROM space
          ; can be paged out and replaced with RAM when booting.

            org   0f000h

            lbr   sysinit
            lbr   rominit
            lbr   anyinit


          ; Do some basic initialization. Branching to initcall will setup
          ; R4 and R5 for SCALL, R2 as stack pointer, and finally, R3 as PC
          ; when it returns via SRET.

sysinit:    ldi   IDE_H_LBA+IDE_H_DR0   ; set lba mode drive 0
            phi   r8

anyinit:    ldi   dskboot.1             ; return address for initcall
            phi   r6
            ldi   dskboot.0
            plo   r6

            lbr   initstk

rominit:    ldi   romboot.1             ; return address for initcall
            phi   r6
            ldi   romboot.0
            plo   r6

initstk:    ldi   stack.1               ; temporary boot stack
            phi   r2
            ldi   stack.0
            plo   r2

            lbr   initcall


romboot:    sep   scall
            dw    chkdevs

            ldi   diskmap.1
            phi   ra
            ldi   diskmap.0
            plo   ra

            ldi   0
            sep   scall
            dw    roprobe

            ldi   0
            sep   scall
            dw    cfprobe

            ldi   1
            sep   scall
            dw    cfprobe

            ldi   0
            sep   scall
            dw    sdprobe

            ldi   1
            sep   scall
            dw    sdprobe

            sep   scall
            dw    endprob

            lbr   anyboot


dskboot:    sep   scall
            dw    chkdevs

            ldi   diskmap.1
            phi   ra
            ldi   diskmap.0
            plo   ra

            ldi   0
            sep   scall
            dw    cfprobe

            ldi   1
            sep   scall
            dw    cfprobe

            ldi   0
            sep   scall
            dw    sdprobe

            ldi   1
            sep   scall
            dw    sdprobe

            sep   scall
            dw    endprob

            lbr   runtime


fillmap:    ldi   0
            str   ra
            inc   ra

endprob:    glo   ra
            smi   8+diskmap.0
            bnz   fillmap

            sep   scall
            dw    inmsg
            db    13,10,0

            sep   sret

copymem:    lda   r6
            phi   rd
            lda   r6
            plo   rd

            lda   r6
            phi   rf
            lda   r6
            plo   rf

            lda   r6
            phi   rc
            lda   r6
            plo   rc

cpybyte:    lda   rd
            str   rf
            inc   rf

            dec   rc
            glo   rc
            bnz   cpybyte
            ghi   rc
            bnz   cpybyte

            sep   sret


          ; Probe the ROM drive, inserting it into the drive mapping table.
          ; This also sets the top of memory to $6FFF to leave space from
          ; $7000-7FFF for the allocation unit decompression buffer. This
          ; also sets the current loaded sector to $FFFF so that the first
          ; sector accessed will need to be loaded on first access.

roprobe:    ldi   lastram.1             ; pointer to last ram variable
            phi   rf
            ldi   lastram.0
            plo   rf

            ldi   6fffh.1               ; set last ram address to $6fff
            str   rf
            inc   rf
            ldi   6fffh.0
            str   rf

            inc   rf                    ; set current rom au to $ffff
            str   rf
            inc   rf
            str   rf

            ldi   1                     ; set drive number into map table
            str   ra
            inc   ra

            ldi   8003h.1               ; get address of rom image
            phi   rf
            ldi   8003h.0
            plo   rf

            ldn   rf                    ; get rom image size, multiply
            shl
            shl
            plo   rd
            ldi   0
            shlc
            phi   rd

            ldi   scratch.1             ; pointer to scratch buffer
            phi   rf
            ldi   scratch.0
            plo   rf

            sep   scall                 ; convert size to ascii integer
            dw    uintout

            ldi   0                     ; zero terminate size string
            str   rf

            ldi   scratch.0             ; reset pointer to start of size
            plo   rf

            sep   scall                 ; output header of dks line
            dw    inmsg
            db    'Disk: ',0

            sep   scall                 ; output size of the rom disk
            dw    msg

            sep   scall                 ; output remainder of line
            dw    inmsg
            db    ' KB ROM (Uncompressed)',13,10,0

            sep   sret                  ; return 


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

            ldi   DEV_NITRO+DEV_IDE     ; serial and disk always present
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
            sex   r3                    ; select uart group if not zero
            out   EXP_PORT
            db    UART_GROUP
            sex   r2
          #endif

            inp   UART_STATUS           ; clear status flags
            inp   UART_DATA

            inp   UART_STATUS           ; check for psi and da bits low
            ani   %11100001
            xri   %11000000
            bnz   findrtc

            ldn   ra                    ; looks like uart is present
            ori   DEV_UART
            str   ra


            ; Check for the RTC by looking for XXXX000X at the RTC month
            ; tens digit. Since it can only be 0 or 1 those zero bits will
            ; always be present even if the clock is not setup right.

findrtc:    sex   r3                    ; select rtc month msd register

          #if RTC_GROUP != UART_GROUP
            out   EXP_PORT              ; select rtc group if different
            db    RTC_GROUP
          #endif

            out   RTC_PORT              ; set address
            db    29h

            sex   r2                    ; look for xxxx000x data
            inp   RTC_PORT
            ani   0eh
            bnz   savefrq


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
            plo   re


          ; First syncronize to the falling edge of a FLAG pulse. Apply
          ; a timeout so we don't get stuck if the RTC is not working or
          ; if something else is at this port.

            sex   r2                    ; needed for inp to be safe

            ldi   7                     ; timeout limit
            plo   rd
            phi   rd

freqlp1:    dec   rd                    ; if timeout then give up
            ghi   rd
            bz    savefrq

            inp   RTC_PORT              ; wait for low signal to sync
            ani   4
            bnz   freqlp1

freqlp2:    dec   rd                    ; if timeout then give up
            ghi   rd
            bz    savefrq

            inp   RTC_PORT              ; wait for high signal to sync
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
            dec   re
            glo   re
            bnz   freqlp3


            ; Multiply the result by 16/25 to get the final answer, but do
            ; it by multiplying by 4/5 twice so we don't overflow 16 bits.
            ; The calculated result will be stored after all devices are
            ; probed in case another device wants to override the result.

            ldi   2                     ; multiply by 4/5 twice
            plo   r9

hzratio:    ghi   rb                    ; get value for multiple
            phi   rf
            glo   rb
            plo   rf

            ldi   4.1                   ; multiply by 4
            phi   rd
            ldi   4.0
            plo   rd

            sep   scall                 ; use bios multiply
            dw    mul16

            ghi   rb                    ; get value for divide
            phi   rf
            glo   rb
            plo   rf

            ldi   5.1                   ; divide by 5
            phi   rd
            ldi   5.0 
            plo   rd

            sep   scall                 ; use bios divide
            dw    div16

            dec   r9                    ; loop the 4/5 multiply twice
            glo   r9
            bnz   hzratio

            ldn   ra                    ; looks like rtc is present
            ori   DEV_RTC
            str   ra


            ; Store the processor clock frequency to it's memory variable.

savefrq:    inc   ra                    ; move on from device map

            ghi   rb                    ; save processor frequency
            str   ra
            inc   ra
            glo   rb
            ani   %11111110
            str   ra
            inc   ra

          #if RTC_GROUP
            sex   r3                    ; make sure default expander group
            out   EXP_PORT
            db    NO_GROUP
          #endif

            sep   scall
            dw    setbd

 sep   scall
 dw    f_inmsg
 db    13,10,10
 db    "Mini/ROM for 1802/Mini Reset..."
 db    13,10,10,0

          ; Calculate the checksum of the ROM from $8000-FFFF

            ldi   8000h.1               ; pointer to start of rom
            phi   ra
            ldi   8000h.0
            plo   ra

            ldi   0                     ; clear sum accumulator
            str   r2
            plo   rc
            phi   rc

cheksum:    lda   ra                    ; add next byte into lsb on stack
            add
            str   r2

            ghi   rc

            bnf   nocarry               ; increment msb if carry occurred
            inc   rc

nocarry:    add
            phi   rc

            ghi   ra                    ; loop until address rolls over
            bnz   cheksum


          ; Move the MSB and LSB into RD.1 and RD.0 where they need to be,
          ; then convert to hex string for output.

            dec   ra                    ; display checksum from rom
            ldn   ra
            plo   rd
            dec   ra
            ldn   ra
            phi   rd

            ldi   scratch.1             ; pointer to string buffer
            phi   rf
            ldi   scratch.0
            plo   rf

            sep   scall                 ; convert to four hex digits
            dw    f_hexout4

            ldi   0                     ; zero terminate the string
            str   rf

            ldi   scratch.0             ; reset pointer to beginning
            plo   rf


          ; Output the fixed part of the message, then check the checksum
          ; to determine which trailing part to display, OK or FAIL.

            sep   scall                 ; output fixed prefix of message
            dw    f_inmsg
            db    'ROM:  V.4.8.2 (Checksum ',0

            sex   ra                    ; compare against m(ra)

            glo   rc                    ; check that plain sum msb matches
            sm
            lbnz  chekbad

            ghi   rc                    ; check that fletcher sum is zero
            lbnz  chekbad

            sep   scall                 ; if both match, display checsum
            dw    f_msg

            sep   scall                 ; and then success string
            dw    f_inmsg
            db    ' OK)',13,10,0

            br    chekcpu               ; check the processor type

chekbad:    sep   scall                 ; if mismatch, display checksum
            dw    f_msg

            sep   scall                 ; and then failure string
            dw    f_inmsg
            db    ' FAIL)',13,10,0


          ; Identify the processor type by executing an opcode sequence that
          ; different on the 1802 than the 1805. 68 C0 XX XX on the 1802 is
          ; an INP 0 followed by LBR XXXX, but on the 1805 it is RLDI R0.

chekcpu:    sep   scall
            dw    f_inmsg
            db    'BIOS: V.2.3.1 (Mini/BIOS)',13,10,0

            db    68h                   ; will only jump on 1802
            lbr   cdp1802

            sep   scall                 ; output 1804/5/6 type
            dw    inmsg
            db    'CPU:  CDP1806 (',0

            br    getfreq               ; get clock frequency

cdp1802:    sep   scall                 ; output 1802 type
            dw    inmsg
            db    'CPU:  CDP1802 (',0


          ; Display the actual clock frequency if we were abe to measure by
          ; using the RTC, otherwise use an assumed default.

getfreq:    ldi   clkfreq.1
            phi   ra
            ldi   clkfreq.0
            plo   ra

            lda   ra
            bnz   hasfreq
            ldn   ra
            bnz   hasfreq

            sep   scall
            dw    inmsg
            db    '4 MHz Assumed)',13,10,0

            ldi   4000.0
            str   ra
            dec   ra
            ldi   4000.1
            str   ra

            br    uartout

hasfreq:    ldn   ra
            adi   10000.0
            plo   rd

            dec   ra
            ldn   ra
            adci  10000.1
            phi   rd

            ldi   scratch.1
            phi   rf
            ldi   scratch.0
            plo   rf

            sep   scall
            dw    uintout

            ldi   0
            str   rf

            ldi   scratch.0
            plo   rf

            inc   rf
            ldn   rf

            dec   rf
            str   rf
            inc   rf

            ldi   '.'
            str   rf
            dec   rf

            sep   scall
            dw    msg

            sep   scall
            dw    inmsg
            db    ' MHz Clock)'13,10,0

uartout:    ldi   devbits.1
            phi   ra
            ldi   devbits.0
            plo   ra

            inc   ra

            ldn   ra
            ani   DEV_UART
            bz    notuart

            sep   scall
            dw    inmsg
            db    'UART: CDP1854',13,10,0

notuart:    ldn   ra
            ani   DEV_RTC
            lbz   notrtc

            sep   scall
            dw    inmsg
            db    'RTC:  MSM6242',13,10,0

notrtc:     sep   scall
            dw    testram


            ; Initialize the jump vectors for the BIOS API calls that have
            ; been moved to loadable modules. Install for each one a LBR
            ; instruction to O_WRMBOOT which the module will overwrite the
            ; address when its loaded. This will at least fail gracefully
            ; if they are called when the module is not loaded.

            sep   scall
            dw    copymem
            dw    vecinit
            dw    findtkn
            dw    veclast-vecinit

            sep   sret

vecinit:    lbr   o_wrmboot
            lbr   o_wrmboot
veclast:

            ; It's not safe to run the expansion memory enable and memory
            ; scan code from ROM for two reasons: we are running from part
            ; of the ROM that will disappear once RAM is switched in, and
            ; attempting to write the EEPROM will cause a write cycle that
            ; makes it temporarily unreadable, even when software protected.
            ;
            ; So copy these routines to RAM in the boot sector page first,
            ; then run it from there.

testram:    sep   scall
            dw    copymem
            dw    ramscan
            dw    sector+ramscan.0
            dw    ramlast-ramscan

            sep   scall
            dw    sector+ramscan.0

            ldi   lastram.1
            phi   ra
            ldi   lastram.0
            plo   ra

            ghi   rf
            smi   1
            str   ra

            inc   ra
            ldi   0ffh
            str   ra

            ghi   rf
            shr
            shr
            plo   rd

            ldi   0
            phi   rd

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
            dw    inmsg
            db    'RAM:  ',0

            sep   scall
            dw    msg

            sep   scall
            dw    inmsg
            db    ' KB',13,10,0

            sep   sret


          ; Check to see if a drive is present. We will do this thoroughly
          ; and remember the result so that the actual driver can take some
          ; shortcuts. This is fine since drive hot-swap is not supported.

cfprobe:    plo   r8
            bz    pridisk

            sex   r3
            out   EXP_PORT              ; set group for second disk
            db    IDE_SECOND

            sex   r2
            inp   EXP_PORT
            xri   IDE_SECOND
            ani   0fh
            bnz   nodrive


          ; We can quickly detect if there is no drive by outputing a zero
          ; to the drive control register. Because the bus is buffered, the
          ; zero will be held by capacitance and will read back zero again
          ; if there is no drive to pull any lines high.
          ;
          ; It is allowed to write the register even when the controller is
          ; busy, so this is always safe to do. The same address reads back
          ; as the alternate status register, and at least one bit should be
          ; set in it if there is a drive present.
          ;
          ; To detect whether there is a controller present, command a DMA
          ; IN operation from the device control register. If there is no
          ; controller, then no DMA will happen.
 
pridisk:    ldi   sector.1              ; set dma target address
            phi   r0
            ldi   sector.0
            plo   r0

            sex   r3
            out   IDE_SELECT            ; start dma of drive control
            db    IDE_A_COUNT+1
            out   IDE_SELECT
            db    IDE_A_DMAIN+IDE_R_DCTRL

            ldi   240                   ; delay for dma, set timeout
            phi   rd

            ghi   r0                    ; if no change, no controller
            smi   sector.1
            bz    nodrive

          ; To detect whether there is no disk, write zero to the drive
          ; control register. Capacitance will cause the zero to read back
          ; if there is no drive, otherwise at least one bit wil be set.

            out   IDE_SELECT            ; output zero to drive control
            db    IDE_R_DCTRL
            out   IDE_DATA
            db    0

            sex   r2                    ; if reads back zero, no drive
            inp   IDE_DATA
            bz    nodrive

          ; Now that we know there is a drive, make sure busy is not set,
          ; then select drive zero which is the only one supported.

            sep   scall                 ; wait until controller not busy
            dw    waitbs2
            bdf   nodrive

            sex   r3                    ; select lba mode and drive
            out   IDE_SELECT
            db    IDE_R_HEAD
            out   IDE_DATA
            db    IDE_H_LBA+IDE_H_DR0

            sep   scall                 ; wait until drive ready
            dw    waitrd2
            bdf   nodrive

            ani   IDE_S_DRQ+IDE_S_IDX   ; these should not be set
            bnz   nodrive


          ; Now that we think there is a working drive here, set it to
          ; 8-bit mode, which is necessary as the hardware does not support
          ; the high 8 data bits of the bus.

            sex   r3                    ; enable feature 8 bit mode
            out   IDE_SELECT
            db    IDE_R_FEAT
            out   IDE_DATA
            db    IDE_F_8BIT

            out   IDE_SELECT            ; send set feature command
            db    IDE_R_CMND
            out   IDE_DATA
            db    IDE_C_FEAT

            sep   scall                 ; wait until drive ready
            dw    waitrd2
            bdf   nodrive

            ani   IDE_S_DRQ+IDE_S_ERR   ; these should not be set
            bnz   nodrive


          ; Send an identify command as a further test that the drive works,
          ; to test whether DMA is supported, and to get some information
          ; about the drive to display, including size and model.

            sex   r3                    ; send identify command
            out   IDE_SELECT
            db    IDE_R_CMND
            out   IDE_DATA
            db    IDE_C_IDENT

            sep   scall                 ; wait until drive ready
            dw    waitrd2
            bdf   nodrive

            ani   IDE_S_DRQ+IDE_S_ERR   ; should have drq but not err
            xri   IDE_S_DRQ
            bnz   nodrive

            ldi   sector.1              ; setup dma buffer pointer
            phi   r0
            ldi   sector.0
            plo   r0

            sex   r3                    ; enable dma of one sector
            out   IDE_SELECT
            db    IDE_A_COUNT+1
            out   IDE_SELECT
            db    IDE_A_DMAIN+IDE_R_DATA

            sep   scall                 ; wait for busy clear and rdy set
            dw    waitrd2
            bdf   nodrive

            ani   IDE_S_DRQ+IDE_S_ERR   ; if set then something is wrong
            bnz   nodrive


          ; Check that the number of heads is between 1 and 16 as a sanity
          ; test of the identity data read.

            ldi   sector.1              ; address of number of heads
            phi   rb
            ldi   6+sector.0
            plo   rb

            lda   rb                    ; lsb should be 1-16
            bz    nodrive

            sdi   16
            bnf   nodrive

            lda   rb                    ; msb should always be zero
            bnz   nodrive

            sex   r3
            out   EXP_PORT              ; reset back to default group
            db    NO_GROUP

            sep   scall                 ; display drive info
            dw    driveid

            glo   r8
            adi   2
            str   ra
            inc   ra


          ; Advance our counter and pointer and go back and check for the
          ; next drive if not at the end of controller list.

nodrive:    sex   r3
            out   EXP_PORT              ; reset back to default group
            db    NO_GROUP

            sep   sret

          ; Now that we have found a drive and gotten identity data, format
          ; and output some information about it.

driveid:    ldi   scratch.1
            phi   rf
            ldi   scratch.0
            plo   rf


          ; Next output the size. Do so in gigabytes for larger disks or
          ; in megabytes for smaller disks.

            ldi   123+sector.0          ; get pointer to sector count msb
            plo   rb

            ldn   rb                    ; check if display in gigs
            smi   8
            lbnf  notgigs

            ldi   'G'                   ; size suffix
            phi   rc

            ldi   5
            plo   re

            ldi   0                     ; highest byte always zero
            br    midbyte

notgigs:    ldi   'M'                   ; size suffix
            phi   rc

            ldi   3
            plo   re

            ldn   rb                    ; get high byte
            dec   rb                    ; get middle byte
midbyte:    plo   rc

            ldn   rb
            dec   rb                    ; get low byte, set third bit from
            phi   rd

            ldn   rb                    ;  right to shift three times
            plo   rd

doshift:    glo   rc                    ; shift to divide size
            shr
            plo   rc
            ghi   rd
            shrc
            phi   rd
            glo   rd
            shrc
            plo   rd

            dec   re
            glo   re
            lbnz  doshift               ; repeat until set bit comes out

            sep   scall                 ; output size
            dw    uintout

            ldi   ' '                   ; output space
            str   rf
            inc   rf

            ghi   rc                    ; output g or m prefix
            str   rf
            inc   rf

            ldi   0
            str   rf
            inc   rf


          ; Output the model number of the drive. Because of the ordering in
          ; the table and the way 8-bit mode works, the even and odd pairs
          ; of bytes are swapped inthe buffer, so we need to undo that.

            ldi   54+sector.0           ; get pointer to model number
            plo   rb

            ldi   40/2                  ; count of number of swaps
            plo   re

cpmodel:    lda   rb
            inc   rf
            str   rf
            lda   rb
            dec   rf
            str   rf
            inc   rf
            inc   rf

            dec   re                    ; repeat for all of model name
            glo   re
            bnz   cpmodel

truncat:    dec   rf                    ; find last non-space character
            ldn   rf
            sdi   ' '
            bdf   truncat

            ldi   0                     ; terminate at first space
            inc   rf
            str   rf


            ldi   scratch.0             ; back to beginning
            plo   rf

            sep   scall                 ; output prefix
            dw    inmsg
            db    'Disk: ',0

            sep   scall                 ; output size
            dw    msg

            sep   scall                 ; output middle
            dw    inmsg
            db    'B CF (',0

            sep   scall                 ; output model
            dw    msg

            sep   scall                 ; output suffix
            dw    inmsg
            db    ')',13,10,0

            sep   sret







waitrd2:    sex   r3                    ; select status register
            out   IDE_SELECT
            db    IDE_R_STAT
            sex   r2

looprd2:    inp   IDE_DATA              ; wait for busy clear and ready set
            smi   IDE_S_RDY
            smi   IDE_S_RDY
            lbnf  exitrd2

            dec   rd                    ; use remainder of busy timeout
            ghi   rd
            lbnz  looprd2

exitrd2:    ldx
            sep   sret


waitbs2:    sex   r3                    ; select status register
            out   IDE_SELECT
            db    IDE_R_STAT

loopbs2:    sex   r2
            inp   IDE_DATA              ; wait for busy clear and ready set
            smi   IDE_S_BUSY
            lbnf  exitbs2

            dec   rd                    ; use remainder of busy timeout
            ghi   rd
            lbnz  loopbs2

exitbs2:    ldx
            sep   sret




sdprobe:    plo   r8

            sex   r3
            out   EXP_PORT              ; set group for second disk
            db    SPI_GROUP

            sex   r2
            inp   EXP_PORT
            xri   SPI_GROUP
            ani   0fh
            lbnz  sdclear


            ldi   sector.1              ; set dma target address
            phi   r0
            ldi   sector.0
            plo   r0

            sex   r3
            out   SPI_CTRL              ; start dma of drive control
            db    SPI_COUNT+1
            out   SPI_CTRL
            db    SPI_NONE+SPI_DMAIN

            sex   r3
            sex   r3

            out   SPI_CTRL
            db    SPI_NONE

            glo   r0                    ; if no change, no controller
            smi   sector.0
            lbz   sdclear



            ldi   scratch.1
            phi   rf
            ldi   scratch.0
            plo   rf

            glo   r8
            sep   scall
            dw    sdident
            lbdf  notpres

            sep   scall
            dw    inmsg
            db    'Disk: ',0



            ldi   scratch.1
            phi   rf
            ldi   scratch.0
            plo   rf

            lda   rf
            lbz   csdsdsc



            ldi   7+scratch.0
            plo   rf

            lda   rf
            lbz   csdsdhc

            phi   rd
            lda   rf
            plo   rd

            ldi   3
            plo   re

sdxcdiv:    ghi   rd
            shr
            phi   rd
            glo   rd
            shrc
            plo   rd

            dec   re
            glo   re
            lbnz  sdxcdiv

            ldi   scratch.0
            plo   rf

            sep   scall
            dw    f_uintout

            ldi   0
            str   rf

            ldi   scratch.0
            plo   rf

            sep   scall
            dw    msg

            sep   scall
            dw    inmsg
            db    ' GB SDXC (',0

            lbr   sdmodel




csdsdhc:    lda   rf
            phi   rd
            lda   rf
            plo   rd

            ghi   rd
            shr
            phi   rd
            glo   rd
            shrc
            plo   rd

            ldi   scratch.0
            plo   rf

            sep   scall
            dw    f_uintout

            ldi   0
            str   rf

            ldi   scratch.0
            plo   rf

            sep   scall
            dw    msg

            sep   scall
            dw    inmsg
            db    ' GB SDHC (',0

            lbr   sdmodel





csdsdsc:    ldi   5+scratch.0           ; move to bits 87:80
            plo   rf

            lda   rf                    ; get read_bl_len @ bits 83:80
            ani   15
            sdi   24
            str   r2

            lda   rf                    ; get c_size @ bits 73:72
            ani   3
            plo   re

            lda   rf                    ; get c_size @ bits 71:64
            phi   rd

            lda   rf                    ; get c_size @ bits 63:62
            ani   192
            plo   rd

            inc   rf                    ; get c_size_mult bit 47 into df
            ldn   rf
            shlc

            dec   rf                    ; get c_size_mult bits 49:48
            ldn   rf
            shlc
            ani   7

            sex   r2
            sd
            plo   rc

sdscdiv:    glo   re
            shr
            plo   re
            ghi   rd
            shrc
            phi   rd
            glo   rd
            shrc
            plo   rd

            glo   rd
            adci  0
            plo   rd
            ghi   rd
            adci  0
            phi   rd

            dec   rc
            glo   rc
            lbnz  sdscdiv

            ldi   scratch.0
            plo   rf

            sep   scall
            dw    f_uintout

            ldi   0
            str   rf

            ldi   scratch.0
            plo   rf

            sep   scall
            dw    msg

            sep   scall
            dw    inmsg
            db    ' MB SDSC (',0


sdmodel:    ldi   scratch.0
            plo   rf

            ldi   scratch.1
            phi   rb
            ldi   17+scratch.0
            plo   rb

            lda   rb
            str   rf
            inc   rf

            lda   rb
            str   rf
            inc   rf

            ldi   ' '
            str   rf
            inc   rf

            ldi   5
            plo   re

pnmloop:    lda   rb
            str   rf
            inc   rf

            dec   re
            glo   re
            lbnz  pnmloop

            ldi   ' '
            str   rf
            inc   rf



            ldn   rb
            plo   rd

            sep   scall
            dw    hexout2

            dec   rf
            lda   rf
            str   rf

            inc   rf
            ldi   0
            str   rf

            dec   rf
            dec   rf

            ldi   '.'
            str   rf

            ldi   scratch.0
            plo   rf

            sep   scall
            dw    msg

            sep   scall
            dw    inmsg
            db    ')',13,10,0



            glo   r8
            adi   4
            str   ra
            inc   ra

notpres:    sep   sret

sdclear:
           #if SPI_GROUP                ; restore group if it was changed
            sex   r3
            out   EXP_PORT
            db    NO_GROUP
           #endif

            sep   sret


sdident:    plo   re

            dec   r2
            dec   r2

            ghi   re
            stxd

            glo   ra
            stxd
            ghi   ra
            stxd

            ldi   sdinctl.1
            phi   ra

            glo   re
            shl
            shl
            shl
            adi   sdinctl.0
            plo   ra

            sep   scall                 ; save and intialize registers
            dw    sdsetup-2
            lbdf  sdfinal

            sep   scall                 ; initialize sd card to spi mode
            dw    spiinit-2
            lbdf  sdfinal

            sep   r9                    ; send csd command
            db    SD_CMD9
            lbnz  sderror

            sep   r9                    ; receive data block start token
            db    recvspi

            xri   0feh                  ; other than 11111110 is an error,
            lbnz  sderror               ;  including a timeout

            sep   r9                    ; get 16 data bytes plus crc
            db    recvbuf
            db    1,SPI_COUNT+16

            sep   r9                    ; send cid command
            db    SD_CMD10
            lbnz  sderror

            sep   r9                    ; receive data block start token
            db    recvspi

            xri   0feh                  ; other than 11111110 is an error,
            lbnz  sderror               ;  including a timeout

            sep   r9                    ; get 16 data bytes plus crc
            db    recvbuf
            db    1,SPI_COUNT+16

            adi   0
            lbr   sdfinal






roread:     glo   r8                    ; sector number too high
            smi   1
            lbdf  diskret

            ghi   r7                    ; sector number still too high
            smi   8
            lbdf  diskret


          ; Get the AU number from the sector number by dividing by 8,
          ; leaving the result on the stack.

            glo   r7                    ; move to result and set stop bit
            ani   -4
            ori    4
            str   r2
            ghi   r7

sect2au:    shr                         ; shift three times until stop bit
            plo   re
            ldn   r2
            shrc
            str   r2
            glo   re
            bnf   sect2au


          ; See if the requested AU is already loaded in the decompression
          ; buffer. If so, then there is no need to decompress again.

            ldi   romcurr.1
            phi   r9
            ldi   romcurr.0
            plo   r9

            ldn   r9                    ; if already loaded dont decompress
            sm
            bz    copysec

            ldn   r2                    ; update loaded au to requested
            str   r9


          ; Test is the AU is past the end of what is in the image. If it
          ; is, act like the read worked but don't actually read any data.

            ldi   8003h.0               ; get pointer to macimum au
            plo   r9
            ldi   8003h.1
            phi   r9

            lda   r9                    ; if not over max then proceed
            sm
            bdf   roentry

            ghi   rf                    ; else fix pointer, return success
            adi   2
            phi   rf
            lbr   diskret


          ; Since the AU is valid but not already in the buffer, find the
          ; offset into the AU offset table.

roentry:    glo   r9
            add
            add
            plo   r9
            ghi   r9
            adci  0
            phi   r9


          ; Decompression will take several more working registers.

            glo   ra
            stxd
            ghi   ra
            stxd

            glo   rb
            stxd
            ghi   rb
            stxd

            glo   rc
            stxd
            ghi   rc
            stxd

            glo   rd
            stxd
            ghi   rd
            stxd


          ; Add offset entry into base of disk image to get AU address.

            lda   r9                    ; save msb and move to lsb
            str   r2

            ldn   r9                    ; add offset to base address
            adi   8003h.0
            plo   rd
            ldi   0
            adci  8003h.1
            add
            phi   rd


          ; RD now has a pointer to compressed AU, set decompression buffer
          ; address into R9 and then decompress the AU.

            ldi   7000h.0     ; get address of buffer
            plo   r9
            ldi   7000h.1
            phi   r9
            

            sep   scall
            dw    decompr

          ; Restore registers needed only for decompression.

            irx

            ldxa
            phi   rd
            ldxa
            plo   rd

            ldxa
            phi   rc
            ldxa
            plo   rc

            ldxa
            phi   rb
            ldxa
            plo   rb

            ldxa
            phi   ra
            ldx
            plo   ra


          ; The decompressed AU data is now in the buffer, either from
          ; decompressing now or because it was previously decompressed.
          ; Copy the needed sector from it into the user buffer.

copysec:    glo   r7                     ; get offset to needed sector
            ani   7
            shl
            str   r2

            adi   7000h.1      ; and offset to buffer
            phi   r9
            ldi   7000h.0
            plo   r9

            ldi   255                    ; count 256 as loop is unrolled
            plo   re
            inc   re

secloop:    lda   r9                     ; copy two bytes per loop
            str   rf
            inc   rf
            lda   r9
            str   rf
            inc   rf

            dec   re                     ; loop until done
            glo   re
            bnz   secloop


          ; The sector has been copied, so restore registers and return.

            lbr   diskret


            org   0f700h

          ; The decompression algorithm is that from Einar Saukas's standard
          ; Z80 ZX1 decompressor, but is completely rewriten due to how very
          ; different the 1802 instruction set and architecture is.
          ;
          ; For background please see https://github.com/einar-saukas/ZX1
          ;
          ; Note that while the ZX1 algorithm is used here, the actual code
          ; is an original work, and so the original license does not apply.
          ;
          ; R9   - Destination pointer
          ; RA   - Last offset
          ; RB   - Copy offset
          ; RC   - Block length
          ; RD   - Source pointer
          ; RE.0 - Single bit buffer

decompr:    ldi   -1                    ; last offset defaults to one
            phi   rb
            plo   rb

            ldi   80h                   ; prime the pump for elias
            plo   re


          ; The first block in a stream is always a literal block so the type
          ; bit is not even sent, and we can jump in right at that point.

literal:    glo   r3                    ; get literal block length
            br    elias

copylit:    lda   rd                    ; copy byte from input stream
            str   r9
            inc   r9

            dec   rc                    ; loop until all bytes copied
            glo   rc
            bnz   copylit
            ghi   rc
            bnz   copylit


          ; After a literal block must be a copy block and the next bit
          ; indicates if is is from a new offset or the same offset as last.

            glo   re                    ; get next bit, see if new offset
            shl
            plo   re
            bdf   newoffs


          ; Next block is from the same offset as last block.

            glo   r3                    ; get same offset block length
            br    elias

copyblk:    glo   rb                    ; offset plus position is source
            str   r2
            glo   r9
            add
            plo   ra
            ghi   rb
            str   r2
            ghi   r9
            adc
            phi   ra

copyoff:    lda   ra                     ; copy byte from source
            str   r9
            inc   r9

            dec   rc                     ; repeat for all bytes
            glo   rc
            bnz   copyoff
            ghi   rc
            bnz   copyoff


          ; After a copy from same offset, the next block must be either a
          ; literal or a copy from new offset, the next bit indicates which.

            glo   re                     ; check if literal next
            shl
            plo   re
            bnf   literal


          ; Next block is to be coped from a new offset value.

newoffs:    ldi   -1                     ; msb for one-byte offset
            phi   rb

            lda   rd                     ; get lsb of offset, drop low bit
            shrc                         ;  while setting highest bit to 1
            plo   rb

            bnf   msbskip                ; if offset is only one byte

            lda   rd                     ; get msb of offset, drop low bit
            shrc                         ;  while seting highest bit to 1
            phi   rb

            glo   rb                     ; replace lowest bit from msb into
            shlc                         ;  the lowest bit of lsb
            plo   rb

            ghi   rb                     ; high byte is offset by one
            adi   1
            phi   rb

            bz    endfile                ; if not end of file marker

msbskip:    glo   r3                     ; get length of block
            br    elias

            inc   rc                     ; new offset is one less

            br    copyblk                ; do the copy

endfile:    sep   sret


          ; Subroutine to read an interlaced Elias gamma coded number from
          ; the bit input stream. This keeps a one-byte buffer in RE.0 and
          ; reads from the input pointed to by RF as needed, returning the
          ; resulting decoded number in RC.

elias:      adi   2
            stxd

            ldi   1                     ; set start value at one
            plo   rc
            shr

eliloop:    phi   rc                    ; save result msb of value

            glo   re                    ; get control bit from buffer
            shl

            bnz   eliskip               ; if buffer is not empty

            lda   rd                    ; else get another byte
            shlc

eliskip:    bnf   elidone               ; if bit is zero then end

            shl                         ; get a data bit from buffer
            plo   re

            glo   rc                    ; shift data bit into result
            shlc
            plo   rc
            ghi   rc
            shlc

            br    eliloop               ; repeat until done

elidone:    plo   re                    ; save back to buffer

            irx                         ; return
            ldx
            plo   r3


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

ramscan:    ldi   3fh                   ; we must have at least 16K
            phi   rf

          ; Enable expander card memory (this code runs from low RAM).
          ; If the expander card is not present, this does nothing.

          #ifdef EXP_MEMORY
            sex   r3                    ; enable banked ram
          #if RTC_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    RTC_GROUP
          #endif
            out   RTC_PORT
            db    81h
          #endif

            sex   rf                    ; rf is pointer to search address

scnloop:    glo   rf                    ; randomize address within page
            xor
            plo   rf

            ghi   rf                    ; advance pointer to next page
            adi   1
            phi   rf

            ldn   rf                    ; get contents of memory, save it,
            plo   re                    ;  then complement it
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

          #ifdef EXP_MEMORY
            sex   r3
            out   RTC_PORT
            db    80h
          #if RTC_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    NO_GROUP
          #endif
          #endif

            sep   sret

ramlast:  ; End of block copied to low memory.


            ; Initialize CDP1854 UART port and set RE to indicate UART in use.
            ; This was written for the 1802/Mini but is generic to the 1854
            ; since it doesn't access the extra control register that the
            ; 1802/Mini has. This means it runs at whatever baud rate the
            ; hardware has setup since there isn't any software control on
setbd:      ; a generic 1854 implementation.

          #if UART_GROUP
            sex   r3
            out   EXP_PORT              ; make sure default expander group
            db    UART_GROUP
            sex   r2
          #endif

            inp   UART_STATUS           ; clear intertupt and data available
            inp   UART_DATA

            inp   UART_STATUS           ; check status bits for the uart
            ani   %11100001
            xri   %11000000

            sex   r3                    ; 8 data bits, 1 stop bit, no parity
            out   UART_STATUS
            db    19h

          #if UART_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    NO_GROUP
          #endif

            sex   r2                    ; if zero then there is a uart
            phi   re

            BRMK  btimalc               ; use bit-bang if a cable or no uart
            bnz   btimalc

            ldi   1                     ; else always use uart
            phi   re
            sep   sret


          #ifdef SET_BAUD
            ldi   (FREQ_KHZ*5)/(SET_BAUD/25)-23
          #endif


          ; If we are going to consider using the bit-banged port, then start
          ; out by first setting the output to the correct idle state.

btimalc:    SEMK                      ; Make output in correct state

          ; Before waiting for a character, make sure that the line is idle
          ; by waiting for it to stay high for at least 10x255 cycles which
          ; would be a character time at the slowest baud rate we support.
          ; This way we avoid timing starting in the middle of a character.

timrset:    ldi   255                 ; reset count to maximum loops

timidle:    plo   re                  ; decrement (inefficiently for delay)
            dec   re
            glo   re

            BRSP  timrset             ; if goes low before zero, start over
            bnz   timidle

          ; If a UART was not detected, then we only need to wait for input
          ; on the bit-banged EF line.

            BRSP  timstrt
            ghi   re

timbang:    BRSP  timstrt
            bnz   timbang

          ; Else wait for either a start bit on the EF line or a character
          ; at the UART, whichever comes first. Then we'll use that port.
          ; Check the bit-banged input every-other instruction to minimize
          ; the uncertainty so the timing is as accurate as possible.

timwait:    BRSP  timstrt             ; if ef asserted, the use bit-banged

            inp   UART_STATUS         ; get the uart status (check ef again)
            BRSP  timstrt

            shr                       ; move da bit to df (check ef again)
            BRSP  timstrt

            bdf   timuart             ; use uart if da set (check ef again)
            BRMK  timwait

          ; We have now seen an assertion on the bit-bang input EF line, so
          ; start timing in units of 9 machine cycles, looking for the last
          ; time the line is asserted before the count reaches 255. This will
          ; be at just before the stop bit, meaning 9 bits after we started.
          ;
          ; Since we have counted in units of 9 cycles, the count will be
          ; how many cycles each bit was. If we overflow the count, something
          ; went wrong, probably the baud rate is too low, so try again.
          ;
          ; Note that this works on any ASCII character, all it requires is
          ; that the highest bit is a zero (and that the format is 8 bits).

timstrt:    ldi   1                   ; delay slightly to round up result
            nop

timcnt1:    phi   re                  ; save count, increment until overflow
timcnt2:    adi   1
            lbz   timdone

            BRSP  timcnt1             ; save if asserted, else just count
            br    timcnt2

          ; We count the bit timing with a range of 8 bits, but only 7 bits
          ; are availablein RE.1 to store it, so we use a compression scheme
          ; that sacrifices resolution at higher counts for a larger range.
          ;
          ; This works by storing values of 0-62 as they are, but counts of
          ; 63-255 are stored as 63-127. This gives single-count resolution
          ; from 0-63, but resolution to 3 counts for 64 and above. This is
          ; fine since more inaccuracy is tolerable at slower baud rates.

timdone:    ldi   63                  ; Pre-load this value that we will 
            plo   re                  ;  need in the calculations later

            ghi   re                  ; Get timing loop value, subtract
            smi   23                  ;  offset of 23 counts, if less than
            bnf   timrset             ;  this, then too low, go try again

            lsz                       ; Fold both 23 and 24 into zero, this
            smi   1                   ;  adj is needed for 9600 at 1.8 Mhz

            phi   re                  ; Got a good measurement, save it

            smi   63                  ; Subtract 63 from time, if less than
            bnf   timkeep             ;  this, then keep the result as-is

timdiv3:    smi   3                   ; Otherwise, divide the excess part
            inc   re                  ;  by three, adding to the 63 we saved
            bdf   timdiv3             ;  earlier so results are 64-126
        
            glo   re                  ; Get result of division plus 63
            phi   re                  ;  and save over raw measurement

timkeep:    ghi   re                  ; Get final result and shift left one
            shl                         ;  bit to make room for echo flag, then
            adi   2+1                 ;  add 1 to baud rate and set echo flag

            phi   re                  ;  then store formatted result and
            sep   sret                ;  return to caller


timuart:    inp   UART_DATA           ; discard port detection character

            ldi   1                   ; set echo and baud=0 meaning uart
            phi   re

            sep   sret                ; return



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
            ghi   rd
            adci  0
            phi   rd

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

           
            ; Trim leading whitespace (space or any control characters)
            ; from zero-terminated string pointed to by RF. Updates RF to
            ; first non- whitespace character, or terminating null.

ltrim:      lda   rf
            bz    trimret

            sdi   ' '
            bdf   ltrim

trimret:    dec   rf
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

cfread:     sex   r3
            bz    priread

            out   EXP_PORT              ; select drive 1 port group
            db    IDE_SECOND

priread:    glo   r3                    ; subroutine to setup command
            br    precmnd

            out   IDE_DATA              ; send read sector command
            db    IDE_C_READ

            glo   r3                    ; subroutine to setup data transfer
            br    prexfer


          ; On systems that are overclocked or have slow busses, the end of
          ; the DMA operation may lag by a cycle, causing 513 bytes to be
          ; transferred instead of 512. This causes the byte following the
          ; buffer to be overwritten, so we save that byte first, then check
          ; for an overrun condition and restore the byte if needed.

            ldn   rf                    ; save byte just past buffer

            out   IDE_SELECT            ; start dma input operation
            db    IDE_A_DMAIN+IDE_R_DATA

            sex   r2
            plo   re

            glo   r0                    ; what end address is supposed to be
            xor 
            bz    restret

            glo   re                    ; else, fix overrun byte then done
            str   rf


          ; After the completion of data transfer, we need to check for any
          ; error and reset the port group to the default if it was changed.

restret:    sex   r3                    ; select status register
            out   IDE_SELECT
            db    IDE_R_STAT

            sex   r2
            inp   IDE_DATA              ; move err flag into df to return
            shr

cfreturn:   sex   r3
            out   EXP_PORT
            db    NO_GROUP

            lbr   diskret



          ; A write operation is mostly just like a read except for the
          ; direction of data transfer. For a write though, a DMA overrun
          ; is harmless, the drive just ignores the extra byte, so no special
          ; handling is needed like it is for read.

cfwrite:    sex   r3
            bz    priwrit

            out   EXP_PORT              ; select drive 1 port group
            db    IDE_SECOND

priwrit:    glo   r3                    ; subroutine to setup command
            br    precmnd

            out   IDE_DATA              ; write sector command
            db    IDE_C_WRITE

            glo   r3                    ; subroutine to setup data transfer
            br    prexfer


          ; All that needs to be done for the DMA write now is trigger the
          ; hardware to start the transfer, which will interrupt execution.

            out   IDE_SELECT            ; trigger dma out operation
            db    IDE_A_DMOUT+IDE_R_DATA

            br    restret


          ; Most of the controller interaction is the same whether its for
          ; a read or write so this subroutine is common setup for sending
          ; a block I/O command.

precmnd:    adi   2                     ; save return address
            plo   re

            out   IDE_SELECT            ; select status register
            db    IDE_R_STAT

            sex   r2
loopdr1:    inp   IDE_DATA              ; wait until drive not busy
            ani   IDE_S_BUSY
            bnz   loopdr1

            sex   r3
            out   IDE_SELECT            ; select head register
            db    IDE_R_HEAD
            out   IDE_DATA
            db    IDE_H_LBA+IDE_H_DR0

            out   IDE_SELECT            ; select status register
            db    IDE_R_STAT

            sex   r2
loopdr2:    inp   IDE_DATA              ; wait until drive ready
            ani   IDE_S_RDY
            bz    loopdr2

            dec   r2                    ; push lba onto the stack
            glo   r8
            stxd
            ghi   r7
            stxd
            glo   r7
            str   r2

            sex   r3
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

            sex   r3                    ; set sector count to one
            out   IDE_SELECT
            db    IDE_R_COUNT
            out   IDE_DATA
            db    1

            out   IDE_SELECT            ; execute read or write command
            db    IDE_R_CMND

            glo   re                    ; return to ideread or idewrite
            plo   r3


          ; Similar to the prior, much of the preparation for data transfer
          ; is the same for both read and write to it's collected in this
          ; subroutine used for both.

prexfer:    adi   2                     ; save return address
            plo   re

            sex   r2
loopdr3:    inp   IDE_DATA              ; wait until drive not busy
            ani   IDE_S_BUSY
            bnz   loopdr3

            ldn   r2                    ; if an error, skip transfers
            shr
            bdf   cfreturn

            glo   rf
            plo   r0
            str   r2

            ghi   rf                    ; set dma pointer, advance buffer
            phi   r0
            adi   2
            phi   rf

            sex   r3                    ; set dma count to one sector
            out   IDE_SELECT
            db    IDE_A_COUNT+1

            glo   re                    ; return to ideread or idewrite
            plo   r3




boot:       ldi   stack.1               ; setup stack for mark opcode
            phi   r2
            ldi   stack.0
            plo   r2

            ldi   ideboot.1             ; setup stack for mark opcode
            phi   r6
            ldi   ideboot.0
            plo   r6

            lbr   initcall              ; jump to initialization



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


btest:      adi   0                   ; if no break, return df clear
            BRMK  nobreak

            smi   0                   ; return df set, wait for end
break:      BRSP  break

nobreak:    sep   sret                ; return result


; Set baud rate and character format for the 1854 UART. This does a bunch
; of conversions and shifts since the original BIOS call is based on the
; 8250 UART registers, and we want to be compatible with that.

usetbd:     ani   8                     ; move bit 3 into df
            adi   256-8

            glo   re                    ; keep as zero if zero
            ani   7
            bz    baud300

            inc   re                    ; else add one to adjust
            glo   re

            ani   7                     ; if overflow rate too high
            lbz   error

baud300:    shlc                        ; double and add bit 3
            ori   32

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



          #if $ > 0fb00h
            #error Page FA00 overflow
          #endif


            org   0fb00h


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
            xri   90h                   ;  thre is set and es- is cleared,
            ani   90h                   ;  if not, wait until it is so
            bnz   uecho
          #else
utype:      inp   UART_STATUS
            xri   90h                   ;  thre is set and es- is cleared,
            ani   90h                   ;  if not, wait until it is so
            bnz   utype
          #endif

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

            inc   r2
            ldn   r2
            sep   sret


idewrite:   ldi   writvec
            lskp

ideread:    ldi   readvec
            plo   re

            glo   r9
            stxd
            ghi   r9
            stxd

            ghi   r8
            ani   31

            smi   8
            bdf   diskret

            adi   (diskmap+8).0
            plo   r9
            ldi   (diskmap+8).1
            phi   r9

            glo   re
            plo   r3

readvec:    ldn   r9
            smi   4
            lbdf  sdread

            adi   2
            lbdf  cfread

            adi   1
            lbdf  roread

            br    idenone

writvec:    ldn   r9
            smi   4
            lbdf  sdwrite

            adi   2
            lbdf  cfwrite

idenone:    smi   0

diskret:    inc   r2
            lda   r2
            phi   r9
            ldn   r2
            plo   r9

            sep   sret



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

            adi   32-21
            bz    bs

            adi   21-13
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

            glo   re
            stxd

            sep   scall
            dw    inmsg
            db    8,32,8,0

            irx
            ldx
            plo   re

            smi   21
            bz    bs

            br    inloop


runtime:    sex   r3                    ; enable banked ram

          #ifdef EXP_MEMORY
          #if RTC_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    RTC_GROUP
          #endif
            out   RTC_PORT
            db    81h
          #if RTC_GROUP
            out   EXP_PORT              ; make sure default expander group
            db    NO_GROUP
          #endif
          #endif

            br    anyboot

ideboot:    ldi   IDE_H_LBA+IDE_H_DR0   ; set lba mode drive 0
            phi   r8

anyboot:    ldi   sector.1              ; load boot sector to $0100
            phi   rf
            ldi   sector.0
            plo   rf

            plo   r7                    ; set lba sector number to 0
            phi   r7
            plo   r8

            sep   scall                 ; read boot sector
            dw    ideread

            lbr   sector+6              ; jump to entry point




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


sdsret:     sep   sret


          ; SDREAD reads a block from the SD Card; the block address is passed
          ; in R8:R7 and the pointer to the data buffer is in RF. If the read
          ; is successful, DF is cleared, otherwise it is set. If the initial
          ; read command times out or returns a card busy status, it means
          ; that the card is not in SPI mode and was probably just inserted,
          ; so the card is initialized and the read then re-tried.

sdread:     plo   re

            ghi   re                    ; save to use for scratch and counter
            stxd

            glo   ra
            stxd
            ghi   ra
            stxd

            ldi   sdrdctl.1
            phi   ra

            glo   re
            shl
            shl
            shl
            adi   sdrdctl.0
            plo   ra

            glo   r3                    ; if busy then initialize card
            br    sdsetup
            bdf   reinit

            sep   r9                    ; read the block from disk
            db    SD_CMD17
            bz    rdblock
            bnf   sderror

reinit:     glo   r3                    ; if timeout, initialize sd card
            br    spiinit
            bdf   sderror

            sep   r9                    ; resend block read command
            db    SD_CMD17
            bnz   sderror

rdblock:    sep   r9                    ; if block start not fe then error
            db    recvspi
            xri   0feh
            bnz   sderror

            sep   r9                    ; get 512 data bytes to buffer
            db    recvbuf
            db    512/SPI_BURST
            db    SPI_COUNT+SPI_BURST

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
 
sdwrite:    plo   re

            ghi   re                    ; save to use for scratch and counter
            stxd

            glo   ra
            stxd
            ghi   ra
            stxd

            ldi   sdwrctl.1
            phi   ra

            glo   re
            shl
            shl
            shl
            adi   sdwrctl.0
            plo   ra

            glo   r3                    ; save and initialize registers
            br    sdsetup               ;  if busy then it's an error
            bdf   sderror

            sep   r9                    ; send block write command
            db    SD_CMD24
            bnz   sderror

            sep   r9                    ; send 512 bytes from buffer
            db    sendbuf
            db    512/SPI_BURST
            db    SPI_COUNT+SPI_BURST

            ani   1fh                   ; response other than xxx00101 is
            xri   05h                   ;  error, including a timeout
            bnz   sderror

            sep   r9                    ; wait while write completes, if
            db    spibusy               ;  not within timeout, then error
            bdf   sderror

            sep   r9                    ; send get device status command
            db    SD_CMD13
            bnz   get1err

            sex   r3                    ; get second byte of r2 response
            out   SPI_DATA
            db    0ffh

            sex   r2
            inp   SPI_DATA              ; not zero is an error
            bnz   sderror

            adi   0                     ; return with df clear
            br    sdfinal


          ; SDSETUP saves the registers we use and presets R9 for subroutine
          ; calls in the other page. RE is used for temporary storage of the
          ; return address since we are pushing to the stack here. This
          ; calls SPIWAKE which actually performs the return from here also.

            ldi   sdsret-2

sdsetup:    adi   2                     ; save return address following br
            plo   re

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

            ldi   sdsret-2

spiinit:    adi   2                     ; save return address following br
            str   r2

            sep   r9                    ; send reset command, expect 1
            db    SD_CMD0
            xri   1
            bz    spimode

            sep   r9                    ; try reset again if not
            db    SD_CMD0
            xri   1
            bnz   sdinerr

spimode:    sep   r9                    ; send host voltage, expect 1
            db    SD_CMD8
            xri   1
            bnz   get4err

            sep   r9                    ; receive 4 more bytes of response
            db    recvskp,4

waitini:    sep   r9                    ; send application escape, expect 1
            db    SD_CMD55
            xri   1
            bnz   sdinerr

            sep   r9                    ; send host capacity, expect 0 or 1
            db    SD_ACMD41
            shr
            bnz   sdinerr

            bdf   waitini               ; if 1, then repeat last commands

            sep   r9                    ; get ocr register
            db    SD_CMD58
            bnz   get4err

            ldi   ocrreg.1              ; pointer to byte to store ocr
            phi   re
            ldi   ocrreg.0
            plo   re

            sex   r3                    ; clock first response byte in
            out   SPI_DATA
            db    0ffh

            sex   re                    ; save the ocr register value
            inp   SPI_DATA

            sep   r9                    ; skip 3 more bytes of response
            db    recvskp,3

            ldn   r2                    ; return
            plo   r3

get4err:    sep   r9                    ; receive extra 4 bytes
            db    recvskp,4

sdinerr:    smi   0

            ldn   r2                    ; return
            plo   r3


          ; R4ERROR and R1ERROR return from an error condition, first
          ; reading any outstanding bytes that the card needs to send.

get1err:    sex   r3                    ; receive extra 1 byte
            out   SPI_DATA
            db    0ffh


          ; Make sure DF is set on return from error condition.

sderror:    smi   0                     ; set df flag to signal error

sdfinal:    sex   r3                    ; de-select sd card device
            out   SPI_CTRL
            db    SPI_NONE

            out   SPI_DATA              ; send clocks after de-selecting
            db    0ffh

           #if SPI_GROUP                ; restore group if it was changed
            out   EXP_PORT
            db    NO_GROUP
           #endif

            inc   r2                    ; restore re.1 from stack
            lda   r2
            phi   ra
            lda   r2
            plo   ra

            ldn   r2
            phi   re

            lbr   diskret



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

            sex   ra
            out   SPI_CTRL              ; assert chip select to sd card


          ; Check if the card is busy, meaning that the MISO line is low
          ; rather than high. We need to wait for a timeout interval before
          ; deciding because it's possible (like if the machine was reset)
          ; that a previously-ordered write operation could be completing.
          ; Sending a CMD0 during a write operation could damage the SD Card
          ; so we want to be sure to avoid this possibility.

spibusy:    ldi   5+(FREQ_KHZ/160)      ; use about a 250 ms timeout
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

sendpkt:    sex   r9                    ; send 8 clocks before command to
            out   SPI_DATA              ;  warm up receiver
            db    0ffh

            sex   r3                    ; send inline data for 6 bytes
            ldi   6

            br    spiloop

sendcmd:    sex   r2
            dec   r2

            ldi   1
            stxd
            shr
            stxd
            stxd
            stxd
            stxd

            br    execcmd


          ; Send a block read or write command by building the command packet
          ; on the stack including the appropriate address from R8:R7 and
          ; then sending it. The OCR register byte that is retreived during
          ; card initialization is referenced to see if the card is high
          ; capacity or not so we know what address format to use. The first
          ; byte specifying the read or write command is passed inline.

sendblk:    sex   r2
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
            stxd

            ldi   0ffh                  ; 8 clocks to warm up the card
            str   r2

            ldi   7

spiloop:    out   SPI_DATA              ; send next byte, advance pointer,
            smi   1                     ;  decrement count, loop if more
            bnz   spiloop


          ; Receive a single byte through SPI, first skiping any $FF bytes
          ; which are idle time on the line. Returns the byte in D. If no
          ; non-$FF value is seen within one second, then a timeout occured,
          ; and $FF is returned in D with DF set. Otherwise, DF is cleared.

recvspi:    ldi   5+(FREQ_KHZ/400)      ; use about a 100 ms timeout
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


          ; Discard bytes through SPI for a length that is stored inline
          ; to the call. The last byte can still be read from the port.

recvskp:    lda   r3                    ; get inline length to receive

            sex   r9
rskploop:   out   SPI_DATA
            db    0ffh

            smi   1                     ; decrement received bytes count,
            bnz   rskploop

            shr                         ; return with df clear
            sep   r3

            lda   r3
            plo   r9


          ; Send data through SPI from memory starting at RF for 512 bytes.
          ; This also sends two dummy CRC bytes after the buffer contents and
          ; leaves RF just past the sent data.

sendbuf:    sex   r9                    ; inline arguments for out

            out   SPI_CTRL              ; so we don't start unintentionally
            db    SPI_COUNT

            sex   ra
            out   SPI_CTRL              ; enable dma out transfer mode

            sex   r9
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

            sex   ra
            out   SPI_CTRL              ; enable dma-in transfer mode

            sex   r9
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

            lda   r3                    ; how many bursts to transfer

            sex   r3
dmaloop:    out   SPI_CTRL              ; start burst by loading counter
            dec   r3

            smi   1                     ; decrement count, loop until done
            bnz   dmaloop
       
            inc   r3                    ; skip burst count

            sex   ra
            out   SPI_CTRL              ; disable dma mode when finished
            sex   r9

            ghi   r0                    ; update buffer pointer to end
            phi   rf
            glo   r0
            plo   rf

            glo   re                    ; return to caller
            plo   r9


sdinctl:    db    SPI_NONE+SPI_CS1
            db    SPI_NONE+SPI_CS1+SPI_DMAIN
sdrdctl:    db    SPI_NONE+SPI_CS1
            db    SPI_NONE+SPI_CS1+SPI_DMAIN
sdwrctl:    db    SPI_NONE+SPI_CS1
            db    SPI_NONE+SPI_CS1+SPI_DMAOUT
            db    SPI_NONE+SPI_CS1

            db    0

            db    SPI_NONE+SPI_CS0
            db    SPI_NONE+SPI_CS0+SPI_DMAIN
            db    SPI_NONE+SPI_CS0
            db    SPI_NONE+SPI_CS0+SPI_DMAIN
            db    SPI_NONE+SPI_CS0
            db    SPI_NONE+SPI_CS0+SPI_DMAOUT
            db    SPI_NONE+SPI_CS0


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
f_setbd:    lbr   return
f_mul16:    lbr   mul16
f_div16:    lbr   div16
f_iderst:   lbr   return
f_idewrt:   lbr   idewrite
f_ideread:  lbr   ideread
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

return:     adi   0
            sep   sret


error:      smi   0
            sep   sret


          ; The entry points call at 0FFE0h and ret at 0FFF1h are indicated in
          ; Mike Riley's bios.inc as being deprecated, but the Elf/OS boot
          ; sector at least still needs them to work properly, as it uses
          ; these addresses rather than calling f_initcall. So we will keep
          ; them, and to avoid wasted space, we'll just put the actual call
          ; and ret code here instead of branching to them. Since they need a
          ; a branch anyway to reset R4 or R5 on return, they can be  aligned
          ; properly with the fixed entry points with no waste of space.
          ;
          ; In these routines, the push and pop operations store the MSB at
          ; the low address as is common on the 1802. Besides consistency,
          ; this allows for interoperability with the 1804/5/6 extended
          ; instruction set. While this is opposite of what Mike Riley's BIOS
          ; does, it should not be a problem, and none have been reported.

            org   0ffd8h

callbr:     glo   r3
            plo   r6

            lda   r6                    ; get subroutine address
            phi   r3                    ; and put into r3
            lda   r6
            plo   r3

            glo   re
            sep   r3                    ; jump to called routine

          #if $ != 0ffe0h
          #error call is not at 0ffe0h
          #endif

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

          #if $ != 0fff1h
          #error ret is not at 0fff1h
          #endif

ret:        plo   re                    ; save d and set x to 2
            sex   r2

            ghi   r6                    ; get return address from r6
            phi   r3
            glo   r6
            plo   r3

            br    retbr                 ; jump back to continuation

          #if $ != 0fff9h
          #error version is not at 0fff9h
          #endif

version:    db    2,2,3
            db    0,0,0,0               ; checksum

            end   start

