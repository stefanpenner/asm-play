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
  // write(stdout, "Banana!\n", 14)
  mov x0, #\std                // File descriptor: stdout (1st argument)
  adrp x1, \string@PAGE        // Load page-aligned address of the string
  add x1, x1, \string@PAGEOFF  // Add offset to get the full address (2nd argument)
  mov x2, #\len                // Length of the string (3rd argument)
  bl write                     // Call the write function
.endm

.macro syscall num
  movz x16, #0x2000, lsl #16  // Load syscall base: 0x20000000
  orr x16, x16, #\num         // Set syscall number: write (0x20000004)
  svc #0                      // Perform the syscall
.endm

.globl _main
_main:
  bl print_hello
  bl print_banana

  // exit(0)
  mov x0, #EXIT_SUCCESS
  bl exit
  // no real point in restoring the frame, process just gets torn down

print_banana:
  frame
    write_string STDOUT, banana, 7
  unframe
  ret

print_hello:
  frame
    write_string STDOUT, hello_world, 14
  unframe
  ret

// write(fd x0, buffer x1, length x2)
write:
  syscall 0x4
  ret

// exit(status x0)
exit:
  syscall 0x1
  ret                               // Return to caller

.section __TEXT,__cstring,cstring_literals
hello_world:
  .asciz "Hello, World!\n"
banana:
  .asciz "Banana\n"
