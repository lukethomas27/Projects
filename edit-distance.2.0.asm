 
 ;computes the edit distance between two bytes
 ;that is computing how many differences they each have
 ;If the first byte is:
 ;    0b10101111
 ; and the second byte is:
 ;    0b10011010
 ; then the edit distance -- that is, the number of corresponding
 ; bits whose values are not equal -- would be 4 (i.e., here bits 5, 4,
 ; 2 and 0 are different, where bit 0 is the least-significant bit).
 .cseg
    .org 0



	ldi r16, 0xa7
	ldi r17, 0x9a






_start:

    ldi r25, 0        ; Initialize counter for edit distance

calculate_distance:
    eor r18, r16         ; Calculate difference
    eor r18, r17

count_bits:
    tst r18              ; Test if result is zero
    brne increment       ; If not zero, there is at least one set bit, increment count
    rjmp end_calculation ; If result is zero, finish counting

increment:
    lsr r18              ; Shift right to test the next bit
    bst r18, 0           ; Test the carry flag
    breq count_bits      ; If not set, continue counting
    inc r25              ; If set, increment count
    rjmp count_bits      ; Continue counting

end_calculation:
    ; At this point, r25 contains the count of set bits
    ; which represents the edit distance
    ; You can use r25 as needed

    ; Exit the program
    ldi r16, 0           ; Syscall number for exit
    ldi r17, 0           ; Exit code 0
    rcall _exit          ; Perform syscall

_exit:
   
	           

edit_distance_stop:
    rjmp edit_distance_stop
