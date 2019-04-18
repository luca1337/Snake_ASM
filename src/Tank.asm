SECTION "Tank", ROM0

; define constants here

Load_tank_sprite:
    LD A, 20
	LD [posY], A
	LD [posX], A

    ; first sprite
    LD A, [posY]
	LD [_OAMRAM], A
	LD A, [posX]
	LD [_OAMRAM+1], A
	LD A, 4
	LD [_OAMRAM+2], A
	LD A, 0
	LD [_OAMRAM+3], A

    ; second sprite
    LD A, 20
	LD [$fe04], A
	LD A, [posX]
	LD [$fe04+1], A
	LD A, 6
	LD [$fe04+2], A
	LD A, 0
	LD [$fe04+3], A
    ret

Tank_Update:
    ; pos y for the left part
    ld a, [posY]
    ld [$fe00], a
    ; pos x for the left part
    ld a, [posX]
	ld [$fe00+$01], a

    ; pos y for the left part
    ld a, [posY]
    ld [$fe04], a
    ; pos x for the right part With offset 
    ld a, [posX]
    adc a, $04           ; this is the offset for the second sprite assembled
	ld [$fe04+$01], a
    ret

Check_Out_Of_Screen_X:
    ld a, [posX]
    ld d, $9C
    cp a, d
    jp nz, Check_Out_Of_Screen_XNEG
    call reset_pos_positive
    ret 

Check_Out_Of_Screen_XNEG:
    ld a, [posX]
    scf 
    sbc a, $04
    ld [$fe04+$01], a
    ld d, $00
    cp a, d
    jp z, reset_pos_negative
    ret 

reset_pos_negative:
    ld a, 10
    ld [posX], a
    ret

reset_pos_positive:
    ld a, [posX]
    scf 
    sbc a, 5
    ld [posX], a
    ret 