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
	ld [rOBP0], a
	ld [rOBP1], a

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
    ld hl, $FE02 ; Sprite 0
    
    ld a, [$FF82]
    ld [$FE00], a
    ld a, [$FF83]
    ld [$FE01], a
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
    ;ld [$FF80], a
    ret

Update:
.getJoypad
    ld hl, $FF00
    ld [hl], %0001000 ; read arrows
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    cpl
    ld [$FF81], a

.moveBlock
    ld b, a
    and %00001000
    jr nz, .moveDown
    ld a, b
    and %00000100
    jr nz, .moveUp
    ld a, b
    and %00000010
    jr nz, .moveLeft
    ld a, b
    and %00000001
    jr nz, .moveRight
    jr .doneMovingBlock

.moveDown
    ld a, [$FF82]
    add 2
    ld [$FF82], a
    jr .doneMovingBlock
.moveUp
    ld a, [$FF82]
    sub 2
    ld [$FF82], a
    jr .doneMovingBlock
.moveLeft
    ld a, [$FF83]
    sub 2
    ld [$FF83], a
    jr .doneMovingBlock
.moveRight
    ld a, [$FF83]
    add 2
    ld [$FF83], a

.doneMovingBlock    
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
