.equ	AUDIO,		0xFF203040
.equ	TIMER,		0xFF202000
.equ	VGA,		0x08000000

.section .data

.global _display
.global DRAW_BEAT_SQUARE

.section .text
_display:

	# get hex_current
	movia r10, hex_current	
	ldw r10, 0(r10)
	
	movi r11, 1
	beq r10, r11, DISPLAY_SNARE
	
	movi r11, 2
	beq r10, r11, DISPLAY_KICK

	movi r11, 3
	beq r10, r11, DISPLAY_CLAP

	movi r11, 4
	beq r10, r11, DISPLAY_CLAP2

	movi r11, 5
	beq r10, r11, DISPLAY_BELL

	movi r11, 6
	beq r10, r11, DISPLAY_HIHAT

	movi r11, 7
	beq r10, r11, DISPLAY_RIM

	movi r11, 8
	beq r10, r11, DISPLAY_TOM

	br INTERRUPT_END

DISPLAY_SNARE:
	movia r10, snare_beat
	ldw r8, 0(r10)
	br SET_SWITCH1

DISPLAY_KICK:
	movia r10, kick_beat
	ldw r8, 0(r10)
	br SET_SWITCH1

DISPLAY_CLAP:
	movia r10, clap_beat
	ldw r8, 0(r10)
	br SET_SWITCH1

DISPLAY_CLAP2:
	movia r10, clap2_beat
	ldw r8, 0(r10)
	br SET_SWITCH1

DISPLAY_BELL:
	movia r10, bell_beat
	ldw r8, 0(r10)
	br SET_SWITCH1

DISPLAY_HIHAT:
	movia r10, hihat_beat
	ldw r8, 0(r10)
	br SET_SWITCH1

DISPLAY_RIM:
	movia r10, rim_beat
	ldw r8, 0(r10)
	br SET_SWITCH1

DISPLAY_TOM:
	movia r10, tom_beat
	ldw r8, 0(r10)
	br SET_SWITCH1

SET_SWITCH1:
	movi r6, 0x0000
	# beat 1.1
	andi r9, r8, 0x8000
	bne r9, r0, BLUE1
	br draw1

BLUE1:
	call BLUE
	mov r6, r2

draw1:
	movi r4, 83
	movi r5, 185
	call DRAW_BEAT_SQUARE
	
SET_SWITCH2:
	movi r6, 0x0000
	# beat 1.2
	andi r9, r8, 0x4000
	bne r9, r0, BLUE2
	br draw2

BLUE2:
	call BLUE
	mov r6, r2

draw2:
	movi r4, 96
	movi r5, 185
	call DRAW_BEAT_SQUARE

SET_SWITCH3:
	movi r6, 0x0000
	# beat 1.3
	andi r9, r8, 0x2000
	bne r9, r0, BLUE3
	br draw3

BLUE3:
	call BLUE
	mov r6, r2

draw3:
	movi r4, 108
	movi r5, 185
	call DRAW_BEAT_SQUARE

SET_SWITCH4:
	movi r6, 0x0000
	# beat 1.4
	andi r9, r8, 0x1000
	bne r9, r0, BLUE4
	br draw4

BLUE4:
	call BLUE
	mov r6, r2

draw4:
	movi r4, 119
	movi r5, 185
	call DRAW_BEAT_SQUARE

SET_SWITCH5:
	movi r6, 0x0000
	# beat 1.4
	andi r9, r8, 0x0800
	bne r9, r0, BLUE5
	br draw5

BLUE5:
	call BLUE
	mov r6, r2

draw5:
	movi r4, 131
	movi r5, 185
	call DRAW_BEAT_SQUARE

SET_SWITCH6:
	movi r6, 0x0000
	# beat 1.4
	andi r9, r8, 0x0400
	bne r9, r0, BLUE6
	br draw6

BLUE6:
	call BLUE
	mov r6, r2

draw6:
	movi r4, 143
	movi r5, 185
	call DRAW_BEAT_SQUARE

SET_SWITCH7:
	movi r6, 0x0000
	# beat 1.4
	andi r9, r8, 0x0200
	bne r9, r0, BLUE7
	br draw7

BLUE7:
	call BLUE
	mov r6, r2

draw7:
	movi r4, 155
	movi r5, 185
	call DRAW_BEAT_SQUARE

SET_SWITCH8:
	movi r6, 0x0000
	# beat 1.4
	andi r9, r8, 0x0100
	bne r9, r0, BLUE8
	br draw8

BLUE8:
	call BLUE
	mov r6, r2

draw8:
	movi r4, 167
	movi r5, 185
	call DRAW_BEAT_SQUARE

SET_SWITCH9:
	movi r6, 0x0000
	# beat 1.4
	andi r9, r8, 0x0080
	bne r9, r0, BLUE9
	br draw9

BLUE9:
	call BLUE
	mov r6, r2

draw9:
	movi r4, 178
	movi r5, 185
	call DRAW_BEAT_SQUARE

SET_SWITCH10:
	movi r6, 0x0000
	# beat 1.4
	andi r9, r8, 0x0040
	bne r9, r0, BLUE10
	br draw10

BLUE10:
	call BLUE
	mov r6, r2

draw10:
	movi r4, 190
	movi r5, 185
	call DRAW_BEAT_SQUARE

SET_SWITCH11:
	movi r6, 0x0000
	# beat 1.4
	andi r9, r8, 0x0020
	bne r9, r0, BLUE11
	br draw11

BLUE11:
	call BLUE
	mov r6, r2

draw11:
	movi r4, 201
	movi r5, 185
	call DRAW_BEAT_SQUARE

SET_SWITCH12:
	movi r6, 0x0000
	# beat 1.4
	andi r9, r8, 0x0010
	bne r9, r0, BLUE12
	br draw12

BLUE12:
	call BLUE
	mov r6, r2

draw12:
	movi r4, 213
	movi r5, 185
	call DRAW_BEAT_SQUARE

SET_SWITCH13:
	movi r6, 0x0000
	# beat 1.4
	andi r9, r8, 0x0008
	bne r9, r0, BLUE13
	br draw13

BLUE13:
	call BLUE
	mov r6, r2

draw13:
	movi r4, 225
	movi r5, 185
	call DRAW_BEAT_SQUARE

SET_SWITCH14:
	movi r6, 0x0000
	# beat 1.4
	andi r9, r8, 0x0004
	bne r9, r0, BLUE14
	br draw14

BLUE14:
	call BLUE
	mov r6, r2

draw14:
	movi r4, 237
	movi r5, 185
	call DRAW_BEAT_SQUARE

SET_SWITCH15:
	movi r6, 0x0000
	# beat 1.4
	andi r9, r8, 0x0002
	bne r9, r0, BLUE15
	br draw15

BLUE15:
	call BLUE
	mov r6, r2

draw15:
	movi r4, 248
	movi r5, 185
	call DRAW_BEAT_SQUARE

SET_SWITCH16:
	movi r6, 0x0000
	# beat 1.4
	andi r9, r8, 0x0001
	bne r9, r0, BLUE16
	br draw16

BLUE16:
	call BLUE
	mov r6, r2

draw16:
	movi r4, 260
	movi r5, 185
	call DRAW_BEAT_SQUARE
	br INTERRUPT_END


DRAW_BEAT_SQUARE:
	addi sp, sp, -56
	stw r3,  0(sp)
	stw r4,  4(sp)
	stw r5,  8(sp)
	stw r6,  12(sp)
	stw r7,  16(sp)
	stw r8,  20(sp)
	stw r9,  24(sp)
	stw r10, 28(sp)
	stw r11, 32(sp)
	stw r12, 36(sp)
	stw r13, 40(sp)
	stw r14, 44(sp)
	stw r15, 48(sp)
	stw ra,  52(sp)

	mov r11, r5
	movia r10, VGA

BLUE_LOOP:
	addi r11, r11, 1
	mov r12, r4
	addi r9, r5, 5
	beq r11, r9, END_SQUARE

BLUE_LOOP2:

	mov r9, r6

	muli r14, r12, 2
	muli r15, r11, 1024

	add r15, r10, r15
	add r15, r14, r15

	sthio r9, 0(r15)
	
	addi r12, r12, 1
	addi r9, r4, 3
	bne r12, r9, BLUE_LOOP2
	br BLUE_LOOP

END_SQUARE:
	ldw r3,  0(sp)
	ldw r4,  4(sp)
	ldw r5,  8(sp)
	ldw r6,  12(sp)
	ldw r7,  16(sp)
	ldw r8,  20(sp)
	ldw r9,  24(sp)
	ldw r10, 28(sp)
	ldw r11, 32(sp)
	ldw r12, 36(sp)
	ldw r13, 40(sp)
	ldw r14, 44(sp)
	ldw r15, 48(sp)
	ldw ra,  52(sp)
	addi sp, sp, 56
	ret

	
BLUE:
	addi sp, sp, -56
	stw r3,  0(sp)
	stw r4,  4(sp)
	stw r5,  8(sp)
	stw r6,  12(sp)
	stw r7,  16(sp)
	stw r8,  20(sp)
	stw r9,  24(sp)
	stw r10, 28(sp)
	stw r11, 32(sp)
	stw r12, 36(sp)
	stw r13, 40(sp)
	stw r14, 44(sp)
	stw r15, 48(sp)
	stw ra,  52(sp)

	movui r2, 0x8EFF

	ldw r3,  0(sp)
	ldw r4,  4(sp)
	ldw r5,  8(sp)
	ldw r6,  12(sp)
	ldw r7,  16(sp)
	ldw r8,  20(sp)
	ldw r9,  24(sp)
	ldw r10, 28(sp)
	ldw r11, 32(sp)
	ldw r12, 36(sp)
	ldw r13, 40(sp)
	ldw r14, 44(sp)
	ldw r15, 48(sp)
	ldw ra,  52(sp)
	addi sp, sp, 56
	ret

	