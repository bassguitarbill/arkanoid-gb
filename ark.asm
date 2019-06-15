INCLUDE "hardware.inc"

SECTION "vblank",ROM0[$40]
    jp VBlankHandler

SECTION "Header", ROM0[$100]

EntryPoint:
;	di ; disable interrupts
	jp Start ; This area is too smol

REPT $150 - $104
	db 0
ENDR

Section "Game code", ROM0

Start:
	; Turn off the LCD
.waitVBlank
	ld a, [rLY]
	cp 144 ; is the LCD past VBlank?
	jr c, .waitVBlank

	xor a ; reset bit 7 (and all other bits) or LCDC
	ld [rLCDC], a
	; okay we're in VBlank, let's get to work

	ld hl, $8000
    ld a, $FF
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a

    ld a, $FF
    ld [hli], a
    cpl
    ld [hli], a
    cpl
    ld [hli], a
    cpl
    ld [hli], a
    cpl
    ld [hli], a
    cpl
    ld [hli], a
    cpl
    ld [hli], a
    cpl
    ld [hli], a
    cpl
    ld [hli], a
    cpl
    ld [hli], a
    cpl
    ld [hli], a
    cpl
    ld [hli], a
    cpl
    ld [hli], a
    cpl
    ld [hli], a
    cpl
    ld [hli], a
    cpl
    ld [hli], a
    cpl

	; init display registers
	ld a, %11100100
	ld [rBGP], a

	xor a
	ld [rSCY], a
	ld [rSCX], a

	; shut sound down
	ld [rNR52], a

	; turn screen on, show BG
	ld a, %10000011
	ld [rLCDC], a

    ld a, %00000001
    ld [$FFFF], a

.lockup
    ei
    halt
	jr .lockup

VBlankHandler:
    call Draw
    call Update
    reti

Draw:
.drawPaddle
    ld hl, $FE00 ; Sprite 0
    
ld a, [$FF80]

    ld [hl], a
    inc hl
    ld [hl], $24
    inc hl
    ld [hl], $0
    inc hl
    ld [hl], $0
    inc hl

    ld [hl], $24; Sprite 1
    inc hl
    ld [hl], $2C
    inc hl
    ld [hl], $1
    inc hl
    ld [hl], $0
    inc hl

    ld [hl], $34; Sprite 2
    inc hl
    ld [hl], $24
    inc hl
    ld [hl], $0
    inc hl
    ld [hl], $0
    inc hl
    
.drawBall
    ld hl, $FF80
    ld a, [hl]
    inc a
    ld [$FF80], a
    ret

Update:
    ret
    

SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr"
FontTilesEnd:


SECTION "Hello World string", ROM0

HelloWorldStr:
	db "Hello World!", 0
UpStr:
    db "Up!", 0
DownStr:
    db "Down!", 0
