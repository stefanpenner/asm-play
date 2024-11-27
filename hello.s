.section __TEXT,__text,regular,pure_instructions
.globl _main
.align 2

_main:
    // write(stdout, "Hello, World!\n", 14)
    mov x0, #1                   // File descriptor: stdout (1st argument)
    adrp x1, message@PAGE        // Load page-aligned address of message
    add x1, x1, message@PAGEOFF  // Add offset to get the full address (2nd argument)
    mov x2, #14                  // Length of the message (3rd argument)
    bl write                     // Call the write function

    // exit(0)
    mov x0, #0                   // Exit status: 0 (1st argument)
    bl exit                      // Call the exit function

// write(fd x0, buffer x1, length x2)
write:
    movz x16, #0x2000, lsl #16   // Load syscall base: 0x20000000
    orr x16, x16, #4             // Set syscall number: write (0x20000004)
    svc #0                       // Perform the syscall
    ret                          // Return to caller

// exit(status x0)
exit:
    movz x16, #0x2000, lsl #16   // Load syscall base: 0x20000000
    orr x16, x16, #1             // Set syscall number: exit (0x20000001)
    svc #0                       // Perform the syscall
    ret                          // Return to caller

.section __TEXT,__cstring,cstring_literals
message:
    .asciz "Hello, World!\n"
