// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, the
// program clears the screen, i.e. writes "white" in every pixel.

// Put your code here.

(LOOP)
  @SCREEN
  D=A
  @address
  M=D // set address to the base address of Hack's screen

  @KBD
  D=M
  
  @KEYUP
  D;JEQ // if no key is pressed goto KEYUP

  @KEYDOWN // if any key is pressed goto KEYDOWN
  0;JMP

(DRAW)
  @address
  D=M
  @KBD // end of the screen 
  D=D-A
  @LOOP
  D;JEQ

  @color
  D=M
  @address
  A=M
  M=D // color the screen 
  
  @address
  M=M+1
  
  @DRAW
  0;JMP

(KEYUP)
  @color
  M=0 // set color to white
  @DRAW
  0;JMP

(KEYDOWN)
  @color
  M=-1 // set color to black
  @DRAW
  0;JMP

