.section __TEXT,__text,regular,pure_instructions
.globl _main
.align 2

_main:
    // write(stdout, "Hello, World!\n", 14);
    mov x0, #1                   // first arg
    // second ary
    // note: macos is picky, so we need to carefully deal with "Hello, World!"
    adrp x1, message@PAGE        // 1. Load page-aligned address of message
    add x1, x1, message@PAGEOFF  // 2. Add offset to get full address
    mov x2, #14                  // 3rd arg
    bl write                     // invoke write function

    // exit(0)
    mov x0, #0                   // first arg
    bl exit                      // invoke exit function

// write(fd x0, buffer x1, length x2)
write:
    movz x16, #0x2000, lsl #16   // 32bit syscall in 64bit is annoying, so we doit in 2 steps.
    orr x16, x16, #4             // update last value to 4 -> 0x20000004
    svc #0                       // syscall
    ret                          // Return

// exit(status x0)
exit:
    movz x16, #0x2000, lsl #16   // 32bit syscall in 64bit is annoying, so we doit in 2 steps.
    orr x16, x16, #1             // update last value to 4 -> 0x20000001
    svc #0                       // syscall
    ret                          // Return 

.section __TEXT,__cstring,cstring_literals
message:
    .asciz "Hello, World!\n"
