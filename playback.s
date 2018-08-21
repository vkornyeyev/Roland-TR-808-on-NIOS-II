.equ	AUDIO,		0xFF203040
.equ	TIMER,		0xFF202000

.data

	snare: .incbin "Sounds/808-Snare23.wav"
	snare_end: .hword 0
	kick:  .incbin "Sounds/808-Kicks16.wav"
	kick_end:  .hword 0
	clap:  .incbin "Sounds/808-Clap03.wav"
	clap_end:  .hword 0
	clap2: .incbin "Sounds/808-Clap04.wav"
	clap2_end: .hword 0
	bell:  .incbin  "Sounds/808-Cowbell2.wav"
	bell_end:  .hword 0
	hihat: .incbin "Sounds/808-OpenHiHats06.wav"
	hihat_end: .hword 0
	rim:   .incbin "Sounds/808-Rim4.wav"
	rim_end:   .hword 0
	tom:   .incbin "Sounds/808-Tom1.wav"
	tom_end:   .hword 0

.text

	.global _playback

_playback:

	movia r10, play
	stw r0, 0(r10)
	
	br WRITE_AUDIO

WRITE_AUDIO:

	# r15 is the counter of how far through the sound file it is, increments by 4
	mov r15, r0
# r13 is a boolean: 0 if all files are done playing, 1 if still playing sound
	mov r13, r0
	
	br WRITE_AUDIO_LOOP


WRITE_AUDIO_LOOP:

	movia r10, play
	ldw r9, 0(r10)
	bne r9, r0, END_BEAT

	movia r10, AUDIO
  ldwio r8, 4(r10) # read how much space is free from fifospace register
  andhi r9, r8, 0xff00
  beq r9, r0, WRITE_AUDIO_LOOP # check if  LEFT read space is empty
  andhi r9, r8, 0xff
  beq r9, r0, WRITE_AUDIO_LOOP # check if RIGHT read space is empty

	mov r8, r0
br WRITE_SNARE

	
WRITE_SNARE:
# checks if this file is done yet
	movia r11, snare
	movia r12, snare_end
	add r11, r11, r15
	bge r11, r12, WRITE_KICK
	
# checks if current_beat of this drum is played
	movia r10, snare_beat
	ldw r9, 0(r10)
	movia r10, beat_current
	ldw r12, 0(r10)
	and r9, r9, r12
	slli r9, r9, 16
	beq r9, r0, WRITE_KICK

# writes sound
	movi r13, 1
	ldw r9, 0(r11)
	add r8, r8, r9
	

WRITE_KICK:
	movia r11, kick
	movia r12, kick_end
	add r11, r11, r15
	bge r11, r12, WRITE_CLAP

	movia r10, kick_beat
	ldw r9, 0(r10)
	movia r10, beat_current
	ldw r10, 0(r10)
	and r9, r9, r10
	slli r9, r9, 16
	beq r9, r0, WRITE_CLAP
	
	movi r13, 1
	ldw r9, 0(r11)
	add r8, r8, r9


WRITE_CLAP:
	movia r11, clap
	movia r12, clap_end
	add r11, r11, r15
	bge r11, r12, WRITE_CLAP2
	
	movia r10, clap_beat
	ldw r9, 0(r10)
	movia r10, beat_current
	ldw r10, 0(r10)
	and r9, r9, r10
	slli r9, r9, 16
	beq r9, r0, WRITE_CLAP2

	movi r13, 1
	ldw r9, 0(r11)
	add r8, r8, r9
	

WRITE_CLAP2:
	movia r11, clap2
	movia r12, clap2_end
	add r11, r11, r15
	bge r11, r12, WRITE_BELL

	movia r10, clap2_beat
	ldw r9, 0(r10)
	movia r10, beat_current
	ldw r10, 0(r10)
	and r9, r9, r10
	slli r9, r9, 16
	beq r9, r0, WRITE_BELL
	
	movi r13, 1
	ldw r9, 0(r11)
	add r8, r8, r9
	

WRITE_BELL:
	movia r11, bell
	movia r12, bell_end
	add r11, r11, r15
	bge r11, r12, WRITE_HIHAT

	movia r10, bell_beat
	ldw r9, 0(r10)
	movia r10, beat_current
	ldw r10, 0(r10)
	and r9, r9, r10
	slli r9, r9, 16
	beq r9, r0, WRITE_HIHAT
	
	movi r13, 1
	ldw r9, 0(r11)
	add r8, r8, r9
	

WRITE_HIHAT:
	movia r11, hihat
	movia r12, hihat_end
	add r11, r11, r15
	bge r11, r12, WRITE_RIM

	movia r10, hihat_beat
	ldw r9, 0(r10)
	movia r10, beat_current
	ldw r10, 0(r10)
	and r9, r9, r10
	slli r9, r9, 16
	beq r9, r0, WRITE_RIM
	
	movi r13, 1
	ldw r9, 0(r11)
	add r8, r8, r9
	

WRITE_RIM:
	movia r11, rim
	movia r12, rim_end
	add r11, r11, r15
	bge r11, r12, WRITE_TOM

	movia r10, rim_beat
	ldw r9, 0(r10)
	movia r10, beat_current
	ldw r10, 0(r10)
	and r9, r9, r10
	slli r9, r9, 16
	beq r9, r0, WRITE_TOM
	
	movi r13, 1
	ldw r9, 0(r11)
	add r8, r8, r9


WRITE_TOM:
	movia r11, tom
	movia r12, tom_end
	add r11, r11, r15
	bge r11, r12, WRITE_SAMPLES

	movia r10, tom_beat
	ldw r9, 0(r10)
	movia r10, beat_current
	ldw r10, 0(r10)
	slli r9, r9, 16
	and r9, r9, r10
	beq r9, r0, WRITE_SAMPLES
	
	movi r13, 1
	ldw r9, 0(r11)
	add r8, r8, r9
	

WRITE_SAMPLES:

	beq r13, r0, END_BEAT

	movia r10, AUDIO
	stwio r8, 8(r10)
	stwio r8, 12(r10) # store in l/r fifo channels

	addi r15, r15, 4
	mov r13, r0
	
	br WRITE_AUDIO_LOOP

END_BEAT:
# store current beat in r8
	movia r10, beat_current
	ldw r8, 0(r10)
# store lowest bit (to be "pushed" off) in r7
	andi r7, r8, 0x01
# shift (pushed off) bit0 to bit15
	slli r7, r7, 15
# push off lowest bit	
	srli r8, r8, 1
# make most sig bit equal to pushed off bit
	or r8, r8, r7
# update beat_current
	stw r8, 0(r10)

	br FSM
	


# end file
.end
