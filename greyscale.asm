.data
  str:   .space 100000        # bytes for string version of the number
  newline: .asciiz "\n"
  fileName: .asciiz "C:\Users\lethabo\OneDrive - University of Cape Town\CSC2002S\arch_assignment\sample_images\jet_64_in_ascii_crlf.ppm"
  outputFileName:  .asciiz "C:\Users\lethabo\OneDrive - University of Cape Town\CSC2002S\arch_assignment\greyoutput.ppm"
  .align 2
  buffer: .space 1
  .align 8
  P2: .asciiz "P2"

.text

  int2str:
  addi $sp, $sp, -4         # to avoid headaches save $t- registers used in this procedure on stack
  sw   $t0, ($sp)           # so the values don't change in the caller. We used only $t0 here, so save that.
  bltz $a0, neg_num         # is num < 0 ?
  j    next0                # else, goto 'next0'

  neg_num:                  # body of "if num < 0:"
  li   $t0, '-'
  sb   $t0, ($a1)           # *str = ASCII of '-' 
  addi $a1, $a1, 1          # str++
  li   $t0, -1
  mul  $a0, $a0, $t0        # num *= -1

  next0:
  li   $t0, -1
  addi $sp, $sp, -4         # make space on stack
  sw   $t0, ($sp)           # and save -1 (end of stack marker) on MIPS stack

  push_digits:
  blez $a0, next1           # num < 0? If yes, end loop (goto 'next1')
  li   $t0, 10              # else, body of while loop here
  div  $a0, $t0             # do num / 10. LO = Quotient, HI = remainder
  mfhi $t0                  # $t0 = num % 10
  mflo $a0                  # num = num // 10  
  addi $sp, $sp, -4         # make space on stack
  sw   $t0, ($sp)           # store num % 10 calculated above on it
  j    push_digits          # and loop

  next1:
  lw   $t0, ($sp)           # $t0 = pop off "digit" from MIPS stack
  addi $sp, $sp, 4          # and 'restore' stack

  bltz $t0, neg_digit       # if digit <= 0, goto neg_digit (i.e, num = 0)
  j    pop_digits           # else goto popping in a loop

  neg_digit:
  li   $t0, '0'
  sb   $t0, ($a1)           # *str = ASCII of '0'
  addi $a1, $a1, 1          # str++
  j    next2                # jump to next2

  pop_digits:
  bltz $t0, next2           # if digit <= 0 goto next2 (end of loop)
  addi $t0, $t0, '0'        # else, $t0 = ASCII of digit
  sb   $t0, ($a1)           # *str = ASCII of digit
  addi $a1, $a1, 1          # str++
  lw   $t0, ($sp)           # digit = pop off from MIPS stack 
  addi $sp, $sp, 4          # restore stack
  j    pop_digits           # and loop

  next2:
  sb  $zero, ($a1)          # *str = 0 (end of string marker)

  lw   $t0, ($sp)           # restore $t0 value before function was called
  addi $sp, $sp, 4          # restore stack
  jr  $ra                   # jump to caller

  
  main:
    # Open the file for reading
    li $v0, 13          # syscall code for open file
    la $a0, fileName   # address of the filename
    li $a1, 0           # flag for read-only mode
    li $a2, 0           # mode not used for read
    syscall
    move $s0, $v0

    # Open the file for writing
    li $v0, 13         # syscall code for open (13)
    la $a0, outputFileName  # Load the address of the filename
    li $a1, 1          # Flags: 1 for write
    li $a2, 0          # Mode: 0 (use default permissions)
    syscall
    move $s2, $v0     # Save the file descriptor in $s2

    li $t7, 0
    li $s6, 19

    li $s4, 1
    j stillinit


    readloop:
      li $s4, 1

      stillinit:

      # read line from file
      li $v0, 14     # syscall for read file
      move $a0, $s0  # file descriptor 
      la $a1, buffer  # address of dest buffer
      li $a2, 1   # buffer length
      syscall       # read byte from file

      beq $t7, $s6, cont
        li $s7, 3
        li $t9, 0
        blt $s7, $t7, body
        bgt $s5, $t9, p2       
        # Write to the file
        li $v0, 15         # syscall code for write (15)
        move $a0, $s2     # File descriptor to write to
        la $a1, P2  # Load the address of the text to write
        li $a2, 2          # Length of the text to write (excluding null terminator)
        syscall

        p2:
        addi $s5, $s5, 1
        blt $s5, $s7, seven

        body:
      # Write to the file
        li $v0, 15         # syscall code for write (15)
        move $a0, $s2     # File descriptor to write to
        la $a1, buffer  # Load the address of the text to write
        li $a2, 1          # Length of the text to write (excluding null terminator)
        syscall

        seven:

        addi $t7, $t7, 1

      blt $t7, $s6, stillinit

      cont:

      # Check if read was successful (end of file)
      
      beqz $v0, convertor

      #load buffer address
      la $s1, buffer

      # Check if character is not \n
      lb $t0, 0($s1)
      beq  $t0, 13, convertor
      beq  $t0, 10, convertor

      beq $s4, 1, isOne
      beq $s4, 2, isTwo
      lb $t3, 0($s1)      
      addi $s4, $s4, 1
      j stillinit 

      isOne:
      lb $t1, 0($s1)      
      addi $s4, $s4, 1
      j stillinit

      isTwo:
      addi $s4, $s4, 1
      lb $t2, 0($s1)
      j stillinit

      convertor:
      beqz $v0, end
      beqz $t1, readloop
      

      #converting to int and increasing brightness      
        beqz $t3, twoDigitz   
        addi $t3, $t3, -48
        addi $t2, $t2, -48
        addi $t1, $t1, -48

        li $t0, 10
        li $s3, 100

        mul $t2, $t2, $t0

        mul $t1, $t1, $s3

        add $t6, $t3, $t2
        add $t6, $t6, $t1

        addi $t6, $t6, 10 

        # maximum ascii value      
        li $t0, 255

        ble $t6, $t0, isLessOrEqual

        li $t6, 255

        isLessOrEqual:

        beqz $t4, first3
        beqz $t5, second3
        
        move $t8, $t6
        j full3

        first3:
        move $t4, $t6
        j readloop

        second3:
        move $t5, $t6
        j readloop

        full3:
        add $t4, $t4, $t5
        add $t4, $t4, $t8
        li $t5, 3
        div $t6, $t4, $t5

        move   $a0, $t6           # $a0 = int to convert
        la   $a1, str             # $a1 = address of string where converted number will be kept
        jal  int2str


        # Write to the file
        li $v0, 15         # syscall code for write (15)
        move $a0, $s2     # File descriptor to write to
        la $a1, str  # Load the address of the text to write
        li $a2, 3         # Length of the text to write (excluding null terminator)
        syscall

        # Write a newline character to the file
        li $v0, 15           # syscall code for write (15)
        move $a0, $s2         # File descriptor to write to
        la $a1, newline       # Load the address of the newline character
        li $a2, 1             # Length of the text to write (including newline and null terminator)
        syscall

        addi $s1, $s1, 4

        addi $s4, 1

        li $t1, 0
        li $t2, 0
        li $t3, 0
        li $t0, 0
        li $t4, 0
        li $t5, 0
        li $t8, 0
                
        j readloop

        twoDigitz:
        beqz $t2, oneDigit 

        addi $t1, $t1, -48
        addi $t2, $t2, -48
        
        li $t3, 10

        mul $t1, $t1, $t3
        add $t6, $t1, $t2

        addi $t6, $t6, 10

        beqz $t4, first2
        beqz $t5, second2
        
        move $t8, $t6
        j full2

        first2:
        move $t4, $t6
        j readloop

        second2:
        move $t5, $t6
        j readloop

        full2:
        add $t4, $t4, $t5
        add $t4, $t4, $t8
        li $t5, 3
        div $t6, $t4, $t5

        move   $a0, $t6           # $a0 = int to convert
        la   $a1, str             # $a1 = address of string where converted number will be kept
        jal  int2str

        # Write to the file
        li $v0, 15         # syscall code for write (15)
        move $a0, $s2      # File descriptor to write to
        la $a1, str # Load the address of the text to write
        li $a2, 2        # Length of the text to write (excluding null terminator)
        syscall   

        # Write a newline character to the file
        li $v0, 15           # syscall code for write (15)
        move $a0, $s2        # File descriptor to write to
        la $a1, newline       # Load the address of the newline character
        li $a2, 1             # Length of the text to write (including newline and null terminator)
        syscall 

        addi $s1, $s1, 4

        addi $s4, 1

        li $t1, 0
        li $t2, 0
        li $t3, 0
        li $t0, 0
        li $t4, 0
        li $t5, 0
        li $t8, 0
                
        j readloop

        oneDigit:
        addi $t1, $t1, -48

        addi $t6, $t1, 10

        beqz $t4, first1
        beqz $t5, second1
        
        move $t8, $t6
        j full1

        first1:
        move $t4, $t6
        j readloop

        second1:
        move $t5, $t6
        j readloop

        full1:
        add $t4, $t4, $t5
        add $t4, $t4, $t8
        li $t5, 3
        div $t6, $t4, $t5

        move   $a0, $t6           # $a0 = int to convert
        la   $a1, str             # $a1 = address of string where converted number will be kept
        jal  int2str

        # Write to the file
        li $v0, 15         # syscall code for write (15)
        move $a0, $s2     # File descriptor to write to
        la $a1, str  # Load the address of the text to write
        li $a2, 2         # Length of the text to write (excluding null terminator)
        syscall

        # Write a newline character to the file
        li $v0, 15           # syscall code for write (15)
        move $a0, $s2         # File descriptor to write to
        la $a1, newline       # Load the address of the newline character
        li $a2, 1             # Length of the text to write (including newline and null terminator)
        syscall

        addi $s1, $s1, 4

        addi $s4, 1

        li $t1, 0
        li $t2, 0
        li $t3, 0
        li $t0, 0
        li $t4, 0
        li $t5, 0
        li $t8, 0
                
        j readloop


  end:

  # Close the file
  li $v0, 16         # syscall code for close (16)
  move $a0, $s2    # File descriptor to close
  syscall

  # close file
  li $v0, 16     
  move $a0, $s0  
  syscall   


li $v0, 10
syscall