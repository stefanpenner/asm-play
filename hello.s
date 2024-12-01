.section __TEXT,__text,regular,pure_instructions
.align 2

.equ STDOUT, 1
.equ EXIT_SUCCESS, 0
.equ FAILURE, 1

.macro frame
  stp x29, x30, [sp, #-16]!
  mov x29, sp
.endm

.macro unframe
  ldp x29, x30, [sp], #16
.endm

.macro write_string std, string, len
  // write(stdout, "String\n", len)
  mov x0, #\std                // File descriptor: stdout (1st argument)
  adrp x1, \string@PAGE        // Load page-aligned address of the string
  add x1, x1, \string@PAGEOFF  // Add offset to get the full address (2nd argument)
  mov x2, #\len                // Length of the string (3rd argument)
  syscall 0x4                  // Call write syscall
.endm

.macro syscall num
  movz x16, #0x2000, lsl #16  // Load syscall base: 0x20000000
  orr x16, x16, #\num         // Set syscall number: write (0x20000004)
  svc #0                      // Perform the syscall
.endm

.globl _main
_main:
  write_string STDOUT, hello_world, 14 // Print "Hello, World!"
  write_string STDOUT, banana, 7       // Print "Banana"

  mov x0, 5             // Set the loop counter to 5
  bl loop               // Call the loop function

  mov x0, #EXIT_SUCCESS // Exit code
  syscall 0x1           // Exit syscall

loop:
  cmp x0, 0             // Compare counter to 0
  beq done_loop         // If counter == 0, exit loop
  sub x0, x0, 1         // Decrement counter
  write_string STDOUT, banana, 7 // Print "Banana"
  b loop                // Repeat loop

done_loop:
  ret                   // Return to caller (_main)

.section __TEXT,__cstring,cstring_literals
hello_world:
  .asciz "Hello, World!\n"
banana:
  .asciz "Banana\n"
