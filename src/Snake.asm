
; define here snake constant values

SECTION "Snake", ROM0

; TileBegin   equ 151
; TileEnd     equ 170

Snake_Load:

    LD A, $20 ; 80 in decimal
	LD [posY], A
    ld a, $10 ; 16 in decimal
	LD [posX], A

    ld a, 0
    ld [snake_frames], a

    ; load sprite
    LD A, [posY]
	LD [_OAMRAM], A
	LD A, [posX]
	LD [_OAMRAM+1], A
	LD A, 2
	LD [_OAMRAM+2], A
	LD A, 0
	LD [_OAMRAM+3], A

    ld a, [posY]
    scf
    ccf 
    adc a, $08           ; this is the offset for the second sprite assembled
	ld [posY], a

    ; tail sprite 1
    LD A, [posY]
	LD [$fe04], A
	LD A, [posX]
	LD [$fe04+1], A
	LD A, 3
	LD [$fe04+2], A
	LD A, 0
	LD [$fe04+3], A

    ld a, [snake_frames]
    inc a
    ld [snake_frames], a

    ld a, [posY]
    scf
    ccf 
    adc a, $08           ; this is the offset for the second sprite assembled
	ld [posY], a

    ; tail sprite 2
    LD A, [posY]
	LD [$fe08], A
	LD A, [posX]
	LD [$fe08+1], A
	LD A, 3
	LD [$fe08+2], A
	LD A, 0
	LD [$fe08+3], A

    ld a, [snake_frames]
    inc a
    ld [snake_frames], a

    ld a, [posY]
    scf
    ccf 
    adc a, $08           ; this is the offset for the second sprite assembled
	ld [posY], a

    ; tail sprite 2
    LD A, [posY]
	LD [$fe0c], A
	LD A, [posX]
	LD [$fe0c+1], A
	LD A, 3
	LD [$fe0c+2], A
	LD A, 0
	LD [$fe0c+3], A

    ld a, [snake_frames]
    inc a
    ld [snake_frames], a

    ld a, [posY]
    scf
    ccf 
    adc a, $08           ; this is the offset for the second sprite assembled
	ld [posY], a

    ; tail sprite 2
    LD A, [posY]
	LD [$fe10], A
	LD A, [posX]
	LD [$fe10+1], A
	LD A, 3
	LD [$fe10+2], A
	LD A, 0
	LD [$fe10+3], A

    ld a, [snake_frames]
    inc a
    ld [snake_frames], a
    ld a, [posY]
    scf
    ccf 
    adc a, $08           ; this is the offset for the second sprite assembled
	ld [posY], a

    ; tail sprite 2
    LD A, [posY]
	LD [$fe14], A
	LD A, [posX]
	LD [$fe14+1], A
	LD A, 3
	LD [$fe14+2], A
	LD A, 0
	LD [$fe14+3], A

    ld a, [snake_frames]
    inc a
    ld [snake_frames], a

    ret

Get_Sprite_Position:
    ld a, c
    ; scf 
    sbc a, $04
    ld c, a
	ld a, [bc]
    ld e, a
    ld a, c
    scf
    ccf 
    adc $04
    ld c, a
    ld a, e
    ld [bc], a

	ld a, c
    ; scf 
    sbc a, $03
    ld c, a
	ld a, [bc]
    ld e, a
    ld a, c
    scf
    ccf 
    adc $04
    ld c, a
    ld a, e
    ld [bc], a

    ret

Snake_Input:
move_left:
	LD A, $20
	LD [$FF00], A
	LD A, [$FF00]
	BIT 1, A
	JP NZ, move_right
	call Move_snake_left
    ret
move_right:
    bit 0, a
    jp nz, move_up
	ld a, [posX]
	call Move_snake_right
    ret
move_up:
    bit 2, a
    jp nz, move_down
    call Move_snake_up
    ret
move_down:
    bit 3, a
    jp z, Move_snake_down
    ld a, 0
    ld [is_pressed], a
    ret

end_input:
    ret

Move_snake_up:

    ld a, [is_pressed]
    cp $0
    ret nz

    ld a, [snake_frames]
    ld [tail_cnt], a
    call Tail_Loop

    ld a, [$fe00]
    ld h, $08
    ; scf 
    sbc a, h
    ld [$fe00], a


    ld a, 1
    ld [is_pressed], a

    ret

Move_snake_down:

    ld a, [is_pressed]
    cp $0
    ret nz

    ld a, [snake_frames]
    ld [tail_cnt], a
    call Tail_Loop

    ld hl, $fe00
    ld a, $08
    scf
    ccf 
    adc a, [hl]
    ld [$fe00], a

    ld a, 1
    ld [is_pressed], a

    jp end_input

Move_snake_left:

    ld a, [is_pressed]
    cp $0
    ret nz

    ld a, [snake_frames]
    ld [tail_cnt], a
    call Tail_Loop

    ld a, [$fe00+1]
    ld h, $08
    ; scf 
    sbc a, h
    ld [$fe00+1], a

    ld a, 1
    ld [is_pressed], a

    ret

Move_snake_right:

    ld a, [is_pressed]
    cp $0
    ret nz

    ld a, [snake_frames]
    ld [tail_cnt], a
    call Tail_Loop
    
    ld hl, $fe00+1
    ld a, $08
    scf
    ccf 
    adc a, [hl]
    ld [$fe00+1], a

    ld a, 1
    ld [is_pressed], a

    ret

Tail_Loop:

    ld a, [tail_cnt]

    sla a
    sla a

    ld c, a

    ld b, $fe

    call Get_Sprite_Position

    ld a, [tail_cnt]
    dec a
    ld [tail_cnt], a
    cp a, $0
    jp nz, Tail_Loop

    ret 