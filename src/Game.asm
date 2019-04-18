include "Hardware.asm"
include "Header.asm"
; include "Tank.asm"
include "Snake.asm"

SECTION "Setup", ROM0[$0100]

JP Start

SECTION "Main", ROM0[$0150]

Start:
    ei 
    ld sp, $FFFE    ; setup stack pointer to the top

    call TurnOffLcd

    ; XOR A
	; LD [$FF42], A
	; LD [$FF43], A

    ; define the pattern table from the darkest to the lightest
    ld a, %11100100
    ldh [rBGP], a 
    ldh [rOCPD], a
    ldh [rOBP0], a
    ldh [rOBP1], a

    ; clear everything before writing
    call ClearVram
    call ClearOam
    call ClearRam


    ld hl, _VRAM            ; vram is where we write our tiles

    ld bc, WhiteQuad
    ld e, $10
    call SetTile

    ld bc, BlackQuad
    ld e, $10
    call SetTile

    ld bc, Snake_Head
    ld e, $10
    call SetTile

    ld bc, Snake_Tail
    ld e, $10
    call SetTile

    ld bc, Map
    ld de, 1024
    ld hl, $9C00
    call LoadMap

    call Snake_Load

    ;call Dma_Copy           ; begin dma copy transfer


    call TurnOnLCD          ; turn back on the lcd 

    call AdjustWindowPosition
    ; ld hl, 0
GameLoop:

    call Wait_vBlank

    ld a, 0
    ld [newPosX], a
    ld bc, newPosX+1
    ld [bc], a

    ld a, 0
    ld [newPosY], a
    ld bc, newPosY+1
    ld [bc], a

    call Get_Tile
    ld bc, $9C00
    scf 
    ccf 
    add hl, bc
    ld a, [hl]
    cp $02
    jp nz, continue

    ld [hl], 0

continue:
    call Snake_Input

    ;call _HRAM          ; call dma subroutine at 0xff80, which then copies the bytes to the OAM and sprites begin to draw
    jp GameLoop

;-----------------
; subroutines
;----------------
include "Utils.asm"

TurnOffLcd:
	call Wait_vBlank
	xor a
	ld [rLCDC], a
	ret

; -- THIS IS OUR PATTERN TABLE DEFINED ABOVE:
; --
; -- DB $FF, $FF = darkest color            [ ◻ ◻ ◻ ◼ ]
; --
; -- DB $00, $FF = middle dark color        [ ◻ ◻ ◼ ◻ ]
; --
; -- DB $FF, $00 = middle clear color       [ ◻ ◼ ◻ ◻ ]
; --
; -- DB $00, $00 = lightest color           [ ◼ ◻ ◻ ◻ ]
; --
_Palettes_Table_NOCALL EQU $0000000000

BlackQuad:
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

Snake_Head:
DB $FF,$FF,$81,$81,$81,$81,$99,$99,$99,$99,$81,$81,$81,$81,$FF,$FF

Snake_Tail:
DB $FF,$FF,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$FF,$FF

WhiteQuad:
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; Cross:
; DB $00,$18,$00,$18,$00,$18,$00,$FF,$00,$FF,$00,$18,$00,$18,$00,$18

; Cross2:
; DB $18,$18,$18,$18,$18,$18,$00,$FF,$00,$FF,$18,$18,$18,$18,$18,$18

; Cross3:
; DB $FF,$FF,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$FF,$FF

; Quad:
; DB $FF,$FF,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$FF,$FF

; WhiteQuad:
; DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; BlackQuad:
; DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

; Tank_left:
; db $00,$00,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$1F,$00
; db $3F,$00,$78,$07,$70,$01,$70,$01,$70,$01,$7F,$00,$3F,$00,$1F,$00

; Tank_right: 
; db $00,$00,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$F8,$00
; db $FC,$00,$1E,$D0,$0E,$F0,$0F,$0F,$0F,$F0,$FE,$00,$FC,$00,$F8,$00

Map:
DB 0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2

SECTION "RAM", WRAM0[$C000]

; stand here all work ram varibles

posX: ds 1
posY: ds 1

newPosX: ds 2
newPosY: ds 2

stack_ptr: ds 2

snake_frames: ds 1

snake_frame_offset: ds 16

tail_cnt: ds 1

Tank_Sprite: ds 4*4

is_pressed: ds 1

player_index: ds 2

SECTION "OAM", WRAM0[$C100]

Snake ds 1