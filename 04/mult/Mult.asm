// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// Put your code here.
@i
M=0 // i = 0

@result
M=0 // result = 0

(LOOP)
  @i
  D=M
  @R1
  D=D-M
  @STOP
  D;JEQ // if i = b goto STOP

  @result
  D=M
  @R0
  D=D+M
  @result
  M=D // result = result + b

  @i
  M=M+1 // i = i + 1
  @LOOP
  0;JMP

(STOP)
  @result
  D=M
  @R2
  M=D // R2 = result

(END)
  @END
  0;JMP



