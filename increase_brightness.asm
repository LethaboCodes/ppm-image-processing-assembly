.data
  str:   .space 100000        # bytes for string version of the number
  newline: .asciiz "\n"
  fileName: .asciiz "C:\Users\lethabo\OneDrive - University of Cape Town\CSC2002S\arch_assignment\sample_images\jet_64_in_ascii_crlf.ppm"
  outputFileName:  .asciiz "C:\Users\lethabo\OneDrive - University of Cape Town\CSC2002S\arch_assignment\brightoutput.ppm"
  .align 2
  buffer: .space 1
  .align 8
  message1: .asciiz "Average pixel value of the original image:\n"
  message2: .asciiz "Average pixel value of new image:\n"

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
    move $s2, $v0     # Save the file descriptor in $t5

    li $t7, 0
    li $s6, 19

    li $t5, 12293

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

      # Write to the file
        li $v0, 15         # syscall code for write (15)
        move $a0, $s2     # File descriptor to write to
        la $a1, buffer  # Load the address of the text to write
        li $a2, 1          # Length of the text to write (excluding null terminator)
        syscall

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

        add $s5, $s5, $t6

        addi $t6, $t6, 10 

        # maximum ascii value      
        li $t0, 255

        ble $t6, $t0, isLessOrEqual

        li $t6, 255

        isLessOrEqual:

        add $s7, $s7, $t6

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
                
        j readloop

        twoDigitz:
        beqz $t2, oneDigit 

        addi $t1, $t1, -48
        addi $t2, $t2, -48
        
        li $t3, 10

        mul $t1, $t1, $t3
        add $t6, $t1, $t2

        add $s5, $s5, $t6

        addi $t6, $t6, 10

        add $s7, $s7, $t6

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

        li $t0, 0
        li $t1, 0
        li $t2, 0
        li $t3, 0
                
        j readloop

        oneDigit:
        addi $t1, $t1, -48

        add $s5, $s5, $t6

        addi $t6, $t1, 10

        add $s7, $s7, $t6

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

  mtc1 $s5, $f0
  cvt.d.w $f0, $f0

  mtc1 $s7, $f2
  cvt.d.w $f2, $f2  

  # Load floating-point constant
  li $t0, 3133440
  mtc1 $t0, $f4
  cvt.d.w $f4, $f4

  div.d $f6, $f0, $f4

  div.d $f8, $f2, $f4

  li $v0, 4
  la $a0, message1
  syscall

  # Then we print the old average 
  li $v0, 3  # syscall code for print_double
  mov.d $f12, $f6  # move the double-precision floating-point number to $f12
  syscall

  li $v0, 4
  la $a0, newline
  syscall

  li $v0, 4
  la $a0, message2
  syscall    

  # Print the new average
  li $v0, 3  # syscall code for print_double
  mov.d $f12, $f8  # move the double-precision floating-point number to $f12
  syscall

  li $v0, 4
  la $a0, newline
  syscall

li $v0, 10
syscall