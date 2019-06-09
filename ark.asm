INCLUDE "hardware.inc"


SECTION "Header", ROM0[$100]

EntryPoint:
	di ; disable interrupts
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

	ld hl, $9000
	ld de, FontTiles
	ld bc, FontTilesEnd - FontTiles
.copyFont
	ld a, [de] ; grab a single byte from the source
	ld [hli], a ; put it at the destination, $9000
	inc de
	dec bc
	ld a, b ; dec bc doesn't update flags
	or c
	jr nz, .copyFont

	ld hl, $9800
	ld de, HelloWorldStr
.copyString
	ld a, [de]
	ld [hli], a
	inc de
	and a ; was the last byte $0?
	jr nz, .copyString

	; init display registers
	ld a, %11100100
	ld [rBGP], a

	xor a
	ld [rSCY], a
	ld [rSCX], a

	; shut sound down
	ld [rNR52], a

	; turn screen on, show BG
	ld a, %10000001
	ld [rLCDC], a

.leftOrRight
    ld a, $20 ; Setting bit 4 to 0 lets you read arrows
    ld [$FF00], a
    ld a, [$FF00]
    ld a, [$FF00]
    ld a, [$FF00]
    ld a, [$FF00]
    ld a, [$FF00]
    ld a, [$FF00]
    ld a, [$FF00]
    cpl
    and a, $01
    or a
    ld de, UpStr
    jr z, .left
    ld de, DownStr
.left
    jr .copyString

.lockup
	jr .lockup

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
