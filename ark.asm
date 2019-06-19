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

SECTION "Speed Table",ROM0[$1000]
XSpeedTable:
    db $01,$02,$03,$04
YSpeedTable:
    db $04,$03,$02,$01

Section "Game code", ROM0[$0400]

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

    ld a, $50 ; Middle of the screen or so
    ld [$FF83], a

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
    ld a, $84
    ld [$FE00], a
    ld [$FE04], a
    ld [$FE08], a

    ld a, [$FF83]
    ld [$FE01], a
    add 8
    ld [$FE05], a
    add 8
    ld [$FE09], a

    xor a
    ld [$FE02], a
    ld [$FE03], a

    ; ld [$FE06], $1
    ld [$FE07], a

    ld [$FE0A], a
    ld [$FE0B], a

    inc a
    ld [$FE06], a
    
.timer
    ld hl, $FF80
    ld a, [hl]
    inc a

.drawBall
    ld hl, $FF84
    ld a, [$FF85] ; x
    srl a
    bit 7, [hl]
    jr nz, .go1
    add $80
.go1
    srl a
    ld [$FE0C], a
    
    ld a, [$FF86] ; y
    srl a
    bit 6, [hl]
    jr nz, .go2
    add $80
.go2
    srl a
    ld [$FE0D], a

    xor a
    ld [$FE0E], a
    ld [$FE0F], a
    
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
    ld b, a

.movePaddle
    ld a, b
    and %00000010
    jr nz, .moveLeft
    ld a, b
    and %00000001
    jr nz, .moveRight
    jr .doneMovingPaddle

.moveLeft
    ld a, [$FF83]
    sub 1
    cp $08
    jr c, .doneMovingPaddle
    ld [$FF83], a
    jr .doneMovingPaddle
.moveRight
    ld a, [$FF83]
    add 1
    cp $92
    jr nc, .doneMovingPaddle
    ld [$FF83], a

.doneMovingPaddle    
    ; great

.calculateBallSpeed
    xor a
    ld c, a
    ld a, [$FF84] ; ball info
    and $0F ; Just get the lower 4
    cp $08
    jr c, .goingUp
    ld b, a
    ld a, $0F
    sub b
.goingUp
    ; a is now between 0 and 7
    and $0F
    cp $04
    jr c, .goingRight
    ld b, a
    ld a, $08
    sub b
.goingRight
    ; horizSpeed = [SpeedTable + a]
    ; vertSpeed = [EndSpeedTable - a]
    ld hl, XSpeedTable
    ld d, $00
    ld e, a
    add de
    ld b, [hl] ; b is our horizontal velocity!
    ld hl, YSpeedTable
    add de
    ld c, [hl] ; c is our vertical velocity!!
.moveBall
.moveX
    ld a, [$FF85] ; Ball x position
    add b
    ld [$FF85], a
    jr nc, .moveY
    ld hl, $FF84
    bit 7, [hl] ; z is set if the high x bit is NOT set
    jr nz, .collideX
    set 7, [hl] ; we're now in the right half
    jr .moveY
.collideX
    ;ld a, [$FF84]
    ;and $0F
    ;neg a
    ;add 7
    
.moveY
    ld a, [$FF86] ; Ball y position
    add c
    ld [$FF86], a
    jr nc, .doneMovingBall
    ld hl, $FF84
    ld c, [hl]
    bit 6, [hl] ; z is set if the high x bit is NOT set
    jr nz, .collideY
    set 6, [hl] ; we're now in the right half
    jr .doneMovingBall
.collideY
    
.doneMovingBall
    ret




