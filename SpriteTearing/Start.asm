
	device ZXSPECTRUM48

	org 8000h
	jr loop

pattern:db 1

loop:	halt

	// Introduce some delay. 255 causes tearing, 1 doesn't.
	// While debugging, this simulator shows you the location of the CRT beam, so that
	// you can see what's going on and tweak your timing to avoid tearing and flickering.
	ld b, 255
wait:	ld a, (ix+1)
	djnz wait

	ld b, 8  ; top line
	ld c, 8  ; left col
	ld d, 21 ; bottom line
	ld e, 30 ; right col
	ld a, (pattern)
	call fill_rect

	// shift pattern left, repeat
	ld a, (pattern)
	rlca
	ld (pattern), a
	jr loop

; Fills a rectangle with a pattern byte.
; Expects:
;   B - top line    -- 0..23
;   C - left col    -- 0..31
;   D - bottom line -- 0..23 (0 means 24)
;   E - right col   -- 0..31 (0 means 32)
;   A - pattern byte
fill_rect:
	ex af, af'
line:	ld a, b
	and 18h
	or 40h
	ld h, a
	ld a, b
	add a
	add a
	add a
	add a
	add a
	or c
	ld l, a
	
	// If you place a breakpoint on this instruction and do Debug -> Continue (F5) repeatedly,
	// you will see the rectangle as it is being drawn. Depending on the state of the
	// Show CRT Snapshot button, you will either see a picture of the video memory, or a picture
	// of the CRT screen (this one lags behind due to the finite speed of the CRT beam).
square:	ex af, af'
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	ld (hl), a
	ex af, af'

	ld a, l
	and 7
	out (0feh), a

	ld a, h
	sub 7
	ld h, a

	; next col
	inc l
	ld a, l
	and 31
	cp e
	jr c, square
	
	; next line
	inc b
	ld a, b
	cp d
	jr c, line
	
	ret

