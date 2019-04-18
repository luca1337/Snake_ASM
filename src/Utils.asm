ClearVram:
ld hl, _SCRNMAX
xor a
ClearTiles:
    ld [hl-], a
    bit 7, h
    jp nz, ClearTiles
    ret

ClearOam:
	ld hl, _OAMRAM
clear_oam_loop:
	XOR A
	LD [HL+], A
	LD A, $A0
	CP A, L
	JP NZ, clear_oam_loop
	RET

ClearRam:
    ld hl, $C100
    ld bc, $A0
clear_ram_loop:
    ld a, $0
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, clear_ram_loop
    ret

LoadMap:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec de
    ld a, d
    or e
    jp nz, LoadMap
    ret

LoadCHRTable:
    ; load the custom chr table
    ret

SetTile:
	LD D, 0
set_tile_loop:
	LD A, [BC]
	LD [HL+], A
	INC BC
	INC D
	LD A, D
	CP e
	JP NZ, set_tile_loop
	ret

Dma_Copy:
    ld de,$FF80       ; load de with the HRAM destination address
    rst $28
    db $00,$0D       ; the amount of data we want to copy into HRAM, $000D which is 13 bytes
    db $F5, $3E, $C1, $EA, $46, $FF, $3E, $28, $3D, $20, $FD, $F1, $D9 ; assembled opcodes which is faster?
    ret

Wait_vBlank:
    ld a, [rLY]
    cp $90
    jp nz, Wait_vBlank
    ret

Wait_hBlank:
	LD A, [rSTAT]
	AND $03
	JP NZ, Wait_hBlank
	RET

TurnOnLCD:
    ld hl,rLCDC
    ld [hl], $DB
    ret

SpritePaletteZ:
	ld a, $E4
	ld [rOBP0], a
	ret

AdjustWindowPosition:
    ld a, [$FF4A]
    dec a
    ld [$FF4A], a
    ret

AdjustWindowPositionH:
    ld a, [$FF4B]
    dec a
    dec a
    ld [$FF4B], a
    ret

JOY_RIGHT:
  and %00010000
  cp  %00010000
  jp  nz,JOY_FALSE
  ld  a,$1
  ret
JOY_LEFT:
  and %00100000
  cp  %00100000
  jp  nz,JOY_FALSE
  ld  a,$1
  ret
JOY_UP:
  and %01000000
  cp  %01000000
  jp  nz,JOY_FALSE
  ld  a,$1
  ret
JOY_DOWN:
  and %10000000
  cp  %10000000
  jp  nz,JOY_FALSE
  ld  a,$1
  ret
JOY_A:
  and %00000001
  cp  %00000001
  jp  nz,JOY_FALSE
  ld  a,$1
  ret
JOY_B:
  and %00000010
  cp  %00000010
  jp  nz,JOY_FALSE
  ld  a,$1
  ret
JOY_SELECT:
  and %00000100
  cp  %00000100
  jp  nz,JOY_FALSE
  ld  a,$1
  ret
JOY_START:
  and %00001000
  cp  %00001000
  jp  nz,JOY_FALSE
  ld  a,$1
  ret
JOY_FALSE:
  ld  a,$0
  ret

Wait_Frame:
    ld a, 0
wait_frame_loop:
    inc a
    cp 120
    jp nz, wait_frame_loop
    ret

Get_Tile:
    ; find y
    ld a, [$fe00]
    scf
    ccf
    sbc $10
    sra a
    sra a
    sra a
    bit 7, a
    jr z, contin_y
    call is_neg
contin_y:
    ld [newPosY], a

    ; find x
    ld a, [$fe00+1]
    scf
    ccf
    sbc $08
    sra a
    sra a
    sra a
    bit 7, a
    jr z, contin_x
    call is_neg
contin_x:
    ld [newPosX], a

    ld hl, 0
    ld a, 0
    ld [hl], a

    ; here the carry can be set even in the first multiply..
    ld hl, newPosY
    sla [hl]
    sla [hl]
    sla [hl]
    sla [hl]
    jp nc, off_shft
    push af
    pop de
    call complem
    push de
    pop af
    jp cont_last_shift_nxt
off_shft:
    sla [hl]
    jp nc, next
    push af
    pop de
    jp nz, cont_last_shift
    call complem

cont_last_shift:
    swap e
    inc hl
    ld [hl], e
    dec hl
    jp next

cont_last_shift_nxt:
    swap e
    ld a, e
    ld d, a
    scf 
    ccf 
    adc a, 1
    ld d, a
    inc hl
    ld [hl], d
    dec hl

next:
    ld bc, 00
    ld de, 00
    ld a, [hl]
    ld e, a
    inc hl
    ld a, [hl]
    ld d, a

sum_invert:
    ld a, e
    ld l, a
    ld a, d
    ld h, a
    
    ld a, [newPosX]
    ld b, 0
    ld c, a
    scf 
    ccf 
    add hl, bc
    ret


complem:
    res 7, e
    res 6, e
    ret

invert_bits:
    cpl 
    adc a, 1
    ret

is_neg:
    res 7, a
    res 6, a
    res 5, a
    ret