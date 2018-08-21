	.equ	AUDIO,	0xFF203040
	.equ	PS2,	0xFF200100
	.equ	TIMER,	0xFF202000
	.equ	LEDS,	0xFF200000
	.equ	VGA,	0x08000000
	.equ	HEX,	0xFF200020

.section .data
	.global state
			state:        .word 0
	.global tempo
			tempo:        .word 60
	.global hex_current
			hex_current:  .word 0
	.global beat_current
			beat_current: .word 0x8000
	.global play
			play:	      .word 0
	.global break_key
			break_key: 	  .word 0
	.global ext_key
			ext_key:	  .word 0
	.global ext_current
			ext_current:  .word 0

	.global snare_beat
			snare_beat: .word 0x0000
	.global kick_beat
			kick_beat:  .word 0x0000
	.global clap_beat
			clap_beat:  .word 0x0000
	.global clap2_beat
			clap2_beat: .word 0x0000
	.global bell_beat
			bell_beat:  .word 0x0000
	.global hihat_beat
			hihat_beat: .word 0x0000
	.global rim_beat
			rim_beat:   .word 0x0000
	.global tom_beat
			tom_beat:   .word 0x0000

	background: .incbin "TR-808.bmp"

.section .text

	.global _start
	.global FSM
	.global INTERRUPT_END

_start:
	br INITIALIZE

INITIALIZE:

	movia r10, TIMER
	movi r8, 4
	stwio r0, 0(r10)
	stwio r8, 4(r10)

	# enable IRQ lines (timer:IRQ0, PS/2:IRQ7)
	movi r8, 0x081
	wrctl ctl3, r8
	

# clear the PS2 FIFO
CLEAR_PS2_FIFO:
	movia r9, PS2
	ldwio r9, 0(r9)
	srli r9, r9, 16 # get bits 31:16
	bne r9, r0, CLEAR_PS2_FIFO


	# enable interrupts from PS2 (write 1 to bit0 of base+4)
	movi r8, 0x01
	movia r9, PS2
	stwio r8, 4(r9)	 	

	# turn on PIE master ENABLE - enable interrupts
	movi r8, 0b0001
	wrctl ctl0, r8
	br DRAW


DRAW:

	movia r10, VGA
	#subi r10, r10, 2
	movia r13, background
	addi r13, r13, 68

	movi r11, -1

DRAWLOOP1: #y
	addi r11, r11, 1
	movi r12, -1
	
	movi r9, 240
	beq r9, r11, FSM


DRAWLOOP2: #x
	addi r12, r12, 1

	movi r9, 320
	beq r9, r12, DRAWLOOP1

	muli r14, r12, 2
	muli r15, r11, 1024

	add r15, r10, r15
	add r15, r14, r15

	addi r13, r13, 2
	ldh r8, 0(r13)

	#addi r10, r10, 2
	sthio r8, 0(r15)

	br DRAWLOOP2


FSM:
	movia r10, play
	ldw r8, 0(r10)
	bne r8, r0, _playback

	movia r10, state
	ldw r8, 0(r10)

	addi r8, r8, 1
	movia r10, LEDS
	stwio r8, 0(r10)

	br SET_HEX

	br FSM


################################################################################
  

.section .exceptions, "ax"
INTERRUPT_START:

	rdctl et, ctl2

	addi sp, sp, -68
	stw r2,  0(sp)
	stw r3,  4(sp)
	stw r4,  8(sp)
	stw r5,  12(sp)
	stw r6,  16(sp)
	stw r7,  20(sp)
	stw r8,  24(sp)
	stw r9,  28(sp)
	stw r10, 32(sp)
	stw r11, 36(sp)
	stw r12, 40(sp)
	stw r13, 44(sp)
	stw r14, 48(sp)
	stw r15, 52(sp)
	stw et,  56(sp)
	stw ea,  60(sp)
	stw ra,  64(sp)

	br INTERRUPT_HANDLER

INTERRUPT_HANDLER:

	rdctl r8, ctl4

	andi r9, r8, 0x01 # IRQ line 0
	bne r9, r0, TIMER_INTERRUPT

	andi r9, r8, 0x080 # IRQ line 7
	bne r9, r0, PS2_INTERRUPT

	br INTERRUPT_END


INTERRUPT_END:

	ldw r2,  0(sp)
	ldw r3,  4(sp)
	ldw r4,  8(sp)
	ldw r5,  12(sp)
	ldw r6,  16(sp)
	ldw r7,  20(sp)
	ldw r8,  24(sp)
	ldw r9,  28(sp)
	ldw r10, 32(sp)
	ldw r11, 36(sp)
	ldw r12, 40(sp)
	ldw r13, 44(sp)
	ldw r14, 48(sp)
	ldw r15, 52(sp)
	ldw et,  56(sp)
	ldw ea,  60(sp)
	ldw ra,  64(sp)
	addi sp, sp, 68
  
	wrctl ctl2, et
	addi ea, ea, -4
	eret

TIMER_INTERRUPT:

	# if FSM state == 2
		# play beat_current beat of the bar
		# maybe do this is _playback subroutines

	movia r10, TIMER
	#ldwio r9, 0(r10)
	#movi r8, 0xFE
	#and r9, r9, r8
	#stwio r9, 0(r10)
	stwio r0, 0(r10)
	
	movi r9, 2
	movia r10, state
	ldw r8, 0(r10)
	beq r8, r9, SET_PLAY
	br INTERRUPT_END

SET_PLAY:
	movia r10, play
	movi r8, 1
	stw r8, 0(r10)
	br INTERRUPT_END


####################################
########## PS2 INTERRRUPT ##########
####################################
PS2_INTERRUPT:

	movia r10, ext_current
	stw r0, 0(r10)

# read data from PS2 FIFO (& mask lower bits [7:0])
	movia r10, PS2
	ldw r8, 0(r10)
	andi r8, r8, 0x0FF 

	movi r9, 0xF0
	beq r8, r9, SET_BREAK

	movi r9, 0xE0
	beq r8, r9, SET_EXT

	movia r10, break_key
	ldw r9, 0(r10)
	beq r9, r0, STRAY_KEY

	movia r10, ext_key
	ldw r9, 0(r10)
	movia r10, ext_current
	stw r9, 0(r10)
	
	movia r10, ext_key
	stw r0, 0(r10)
	movia r10, break_key
	stw r0, 0(r10)

	br PS2_CHECK_STATE

SET_BREAK:
	movia r10, break_key
	movi r9, 1
	stw r9, 0(r10)
	br INTERRUPT_END

SET_EXT:
	movia r10, ext_key
	movi r9, 1
	stw r9, 0(r10)
	movia r10, break_key
	stw r0, 0(r10)
	br INTERRUPT_END

STRAY_KEY:
	movia r10, ext_key
	stw r0, 0(r10)
	movia r10, break_key
	stw r0, 0(r10)
	br INTERRUPT_END
	

PS2_CHECK_STATE:

	movia r10, state

# if FSM state == 0 goto PS2_STATE0
	ldw r9, 0(r10)
	beq r9, r0, PS2_STATE0

# else if FSM state == 1 goto PS2_STATE1
	movi r10, 1
	beq r9, r10, PS2_STATE1

# else if FSM state == 2 goto PS2_STATE2
	movi r10, 2
	beq r9, r10, PS2_STATE2
	
	br INTERRUPT_END


PS2_STATE0:
	# inputs can be a) numbers 1-8 (each is a drum - snare, kick, etc), 
	#		        b) up/down for tempo, 
	#               c) spacebar for start playback (update to state 2)
	# pressing numbers 1-8 goes to state 1 and sets hex_current to whichever you pressed

# REMEMBER R8 is THE VALUE FROM THE PS2

	movia r10, ext_current
	ldw r9, 0(r10)
	bne r9, r0, STATE0_EXT
	
# a) numbers 1-8 (each is a drum - snare, kick, etc)
	# if (r8 == [keys 1-8]) goto KEY[n]
	movi r9, 0x16 # 1
	beq r9, r8, KEY1
	movi r9, 0x1E # 2
	beq r9, r8, KEY2
	movi r9, 0x26 # 3
	beq r9, r8, KEY3
	movi r9, 0x25 # 4
	beq r9, r8, KEY4
	movi r9, 0x2E # 5
	beq r9, r8, KEY5
	movi r9, 0x36 # 6
	beq r9, r8, KEY6
	movi r9, 0x3D # 7
	beq r9, r8, KEY7
	movi r9, 0x3E # 8
	beq r9, r8, KEY8

# c) spacebar (play) change to state 2 	
	movi r9, 0x29 #SPACE - 29(F029)
	beq r9, r8, KEYSPACE
	
# else exit
	br INTERRUPT_END

STATE0_EXT:
# b )up/down (E0) for tempo
	# if r8 == up/down goto ...
	movi r9, 0x75 # UP - E075(E0F075)
	beq r9, r8, KEYUP
	movi r9, 0x72 # DOWN - E072 (E0F072)
	beq r9, r8, KEYDOWN
	br INTERRUPT_END
	

KEY1:
	# update hex_current
	movia r10, hex_current
	movi r8, 1
	stw r8, 0(r10)
	movia r10, LEDS
	movi r9, 0b01000000010
	stw r9, 0(r10)
	br GOTO_STATE1

KEY2:
	# update hex_current
	movia r10, hex_current
	movi r8, 2
	stw r8, 0(r10)
	movia r10, LEDS
	movi r9, 0b00100000010
	stw r9, 0(r10)
	br GOTO_STATE1

KEY3:
	# update hex_current
	movia r10, hex_current
	movi r8, 3
	stw r8, 0(r10)
	movia r10, LEDS
	movi r9, 0b00010000010
	stw r9, 0(r10)
	br GOTO_STATE1

KEY4:
	# update hex_current
	movia r10, hex_current
	movi r8, 4
	stw r8, 0(r10)
	movia r10, LEDS
	movi r9, 0b00001000010
	stw r9, 0(r10)
	br GOTO_STATE1

KEY5:
	# update hex_current
	movia r10, hex_current
	movi r8, 5
	stw r8, 0(r10)
	movia r10, LEDS
	movi r9, 0b00000100010
	stw r9, 0(r10)
	br GOTO_STATE1

KEY6:
	# update hex_current
	movia r10, hex_current
	movi r8, 6
	stw r8, 0(r10)
	movia r10, LEDS
	movi r9, 0b00000010010
	stw r9, 0(r10)
	br GOTO_STATE1

KEY7:
	# update hex_current
	movia r10, hex_current
	movi r8, 7
	stw r8, 0(r10)
	movia r10, LEDS
	movi r9, 0b00000001010
	stw r9, 0(r10)
	br GOTO_STATE1

KEY8:
	# update hex_current
	movia r10, hex_current
	movi r8, 8
	stw r8, 0(r10)
	movia r10, LEDS
	movi r9, 0b00000000110
	stw r9, 0(r10)
	br GOTO_STATE1


GOTO_STATE1:
	movia r10, state
	movi r8, 1
	stw r8, 0(r10)
	br _display


KEYUP:
	# update tempo
	movia r10, tempo
	ldw r8, 0(r10)
	addi r8, r8, 10
	movi r9, 210
	beq r8, r9, INTERRUPT_END
	stw r8, 0(r10)
	br INTERRUPT_END


KEYDOWN:
	# update tempo
	movia r10, tempo
	ldw r8, 0(r10)
	subi r8, r8, 10
	movi r9, 30
	beq r8, r9, INTERRUPT_END
	stw r8, 0(r10)
	br INTERRUPT_END




KEYSPACE:

	# set state = 2
	movi r8, 2
	movia r10, state
	stw r8, 0(r10)
	br INITIALIZE_TIMER


PS2_STATE1:

	# load address of beat bar
	movia r10, hex_current
	ldw r9, 0(r10)
	subi r9, r9, 1
	muli r9, r9, 4
	movia r10, snare_beat
	add r10, r10, r9
	mov r11, r10

	movia r10, ext_current
	ldw r9, 0(r10)
	bne r9, r0, STATE1_EXT

	movi r9, 0x05 # 1
	beq r9, r8, KEYF1
	movi r9, 0x06 # 2
	beq r9, r8, KEYF2
	movi r9, 0x04 # 3
	beq r9, r8, KEYF3
	movi r9, 0x0C # 4
	beq r9, r8, KEYF4
	movi r9, 0x03 # 5
	beq r9, r8, KEYF5
	movi r9, 0x0B # 6
	beq r9, r8, KEYF6
	movi r9, 0x83 # 7
	beq r9, r8, KEYF7
	movi r9, 0x0A # 8
	beq r9, r8, KEYF8
	movi r9, 0x01 # 9
	beq r9, r8, KEYF9
	movi r9, 0x09 # 10
	beq r9, r8, KEYF10
	movi r9, 0x78 # 11
	beq r9, r8, KEYF11
	movi r9, 0x07 # 12
	beq r9, r8, KEYF12

	movi r9, 0x77 # Num Lock
	beq r9, r8, KEYNUMLOCK

	movi r9, 0x7C # key: *
	beq r9, r8, KEYSTAR
	movi r9, 0x7B # key: -
	beq r9, r8, KEYDASH

	movi r9, 0x5A # Enter - return to state 0
	beq r9, r8, KEYENTER

	br INTERRUPT_END

STATE1_EXT:
	movi r9, 0x4A # SLASH
	beq r9, r8, KEYSLASH
	br INTERRUPT_END

KEYF1:

	ldw r8, 0(r11)
	xori r8, r8, 0x8000
	stw r8, 0(r11)
	br _display

KEYF2:

	ldw r8, 0(r11)
	xori r8, r8, 0x4000
	stw r8, 0(r11)
	br _display

KEYF3:

	ldw r8, 0(r11)
	xori r8, r8, 0x2000
	stw r8, 0(r11)
	br _display

KEYF4:

	ldw r8, 0(r11)
	xori r8, r8, 0x1000
	stw r8, 0(r11)
	br _display

KEYF5:

	ldw r8, 0(r11)
	xori r8, r8, 0x0800
	stw r8, 0(r11)
	br _display

KEYF6:

	ldw r8, 0(r11)
	xori r8, r8, 0x0400
	stw r8, 0(r11)
	br _display

KEYF7:

	ldw r8, 0(r11)
	xori r8, r8, 0x0200
	stw r8, 0(r11)
	br _display

KEYF8:

	ldw r8, 0(r11)
	xori r8, r8, 0x0100
	stw r8, 0(r11)
	br _display

KEYF9:

	ldw r8, 0(r11)
	xori r8, r8, 0x0080
	stw r8, 0(r11)
	br _display

KEYF10:

	ldw r8, 0(r11)
	xori r8, r8, 0x0040
	stw r8, 0(r11)
	br _display

KEYF11:

	ldw r8, 0(r11)
	xori r8, r8, 0x0020
	stw r8, 0(r11)
	br _display

KEYF12:

	ldw r8, 0(r11)
	xori r8, r8, 0x0010
	stw r8, 0(r11)
	br _display

KEYNUMLOCK:

	ldw r8, 0(r11)
	xori r8, r8, 0x0008
	stw r8, 0(r11)
	br _display

KEYSLASH:

	ldw r8, 0(r11)
	xori r8, r8, 0x0004
	stw r8, 0(r11)
	br _display

KEYSTAR:

	ldw r8, 0(r11)
	xori r8, r8, 0x0002
	stw r8, 0(r11)
	br _display

KEYDASH:

	ldw r8, 0(r11)
	xori r8, r8, 0x0001
	stw r8, 0(r11)
	br _display

KEYENTER:
	movia r10, state
	stw r0, 0(r10)
	br _display

PS2_STATE2:
	# inputs can be a) spacebar to stop playback
	
	# if r8 == spacebar goto ... 
	movi r9, 0x29 #SPACE 
	beq r9, r8, KEYSPACE2
	br INTERRUPT_END
	

KEYSPACE2:
	# set state = 0
	movia r10, state
	stw r0, 0(r10)

	br END_TIMER


######################################
########## INITIALIZE TIMER ##########
######################################
.section .text

INITIALIZE_TIMER:

	# load tempo to r8
	movia r10, tempo
	ldw r8, 0(r10)

	# Set Timer Period: clks/beat = (100000000clk_per_sec) / (tempo/60beats_per_sec)
	movhi r9,   %hi(100000000)
	ori r9, r9, %lo(100000000)
	divu r8, r9, r8
	muli r8, r8, 60

	# store period in timer device
	movia r10, TIMER
	stwio r8, 8(r10) # store lower bits of period
	srli r8, r8, 16
	stwio r8, 12(r10) # store upper bits of timer period

	# clear timer
	stwio r0, 0(r10)

	# set control reg bits 0-2: enable interrupt, continue, and start
	movi r8, 0b0111
	stwio r8, 4(r10)

	br INTERRUPT_END
	
END_TIMER:
	# set control reg bits 0-2: enable interrupt, continue, and start
	movia r10, TIMER
	movi r8, 0b1000
	stwio r8, 4(r10)
	br INTERRUPT_END
	

SET_HEX:
	movia r10, tempo
	ldw r8, 0(r10)

	movi r9, 40
	beq r8, r9, HEX40
	movi r9, 50
	beq r8, r9, HEX50
	movi r9, 60
	beq r8, r9, HEX60
	movi r9, 70
	beq r8, r9, HEX70
	movi r9, 80
	beq r8, r9, HEX80
	movi r9, 90
	beq r8, r9, HEX90
	movi r9, 100
	beq r8, r9, HEX100
	movi r9, 110
	beq r8, r9, HEX110
	movi r9, 120
	beq r8, r9, HEX120
	movi r9, 130
	beq r8, r9, HEX130
	movi r9, 140
	beq r8, r9, HEX140
	movi r9, 150
	beq r8, r9, HEX150
	movi r9, 160
	beq r8, r9, HEX160
	movi r9, 170
	beq r8, r9, HEX170
	movi r9, 180
	beq r8, r9, HEX180
	movi r9, 190
	beq r8, r9, HEX190
	movi r9, 200
	beq r8, r9, HEX200

	br INTERRUPT_END

HEX40:
	movia r10, HEX
	movi r8, 0x00663F
	stw r8, 0(r10)
	br FSM

HEX50:
	movia r10, HEX
	movi r8, 0x006D3F
	stw r8, 0(r10)
	br FSM

HEX60:
	movia r10, HEX
	movi r8, 0x007D3F
	stw r8, 0(r10)
	br FSM

HEX70:
	movia r10, HEX
	movi r8, 0x00073F
	stw r8, 0(r10)
	br FSM

HEX80:
	movia r10, HEX
	movi r8, 0x007F3F
	stw r8, 0(r10)
	br FSM

HEX90:
	movia r10, HEX
	movi r8, 0x06F3F
	stw r8, 0(r10)
	br FSM

HEX100:
	movia r10, HEX
	movhi r8, 0x06
	addi r8, r8, 0x3F3F
	stw r8, 0(r10)
	br FSM

HEX110:
	movia r10, HEX
	movhi r8, 0x06
	addi r8, r8, 0x063F
	stw r8, 0(r10)
	br FSM

HEX120:
	movia r10, HEX
	movhi r8, 0x06
	addi r8, r8, 0x5B3F
	stw r8, 0(r10)
	br FSM

HEX130:
	movia r10, HEX
	movhi r8, 0x06
	addi r8, r8, 0x4F3F
	stw r8, 0(r10)
	br FSM

HEX140:
	movia r10, HEX
	movhi r8, 0x06
	addi r8, r8, 0x663F
	stw r8, 0(r10)
	br FSM

HEX150:
	movia r10, HEX
	movhi r8, 0x06
	addi r8, r8, 0x6D3F
	stw r8, 0(r10)
	br FSM

HEX160:
	movia r10, HEX
	movhi r8, 0x06
	addi r8, r8, 0x7D3F
	stw r8, 0(r10)
	br FSM

HEX170:
	movia r10, HEX
	movhi r8, 0x06
	addi r8, r8, 0x073F
	stw r8, 0(r10)
	br FSM

HEX180:
	movia r10, HEX
	movhi r8, 0x06
	addi r8, r8, 0x7F3F
	stw r8, 0(r10)
	br FSM

HEX190:
	movia r10, HEX
	movhi r8, 0x06
	addi r8, r8, 0x6F3F
	stw r8, 0(r10)
	br FSM

HEX200:
	movia r10, HEX
	movhi r8, 0x05B
	addi r8, r8, 0x3F3F
	stw r8, 0(r10)
	br FSM

# end file
.end
