.section __TEXT,__text,regular,pure_instructions
.align 2

// System constants
.equ STDOUT, 1
.equ STDERR, 2
.equ EXIT_SUCCESS, 0
.equ EXIT_FAILURE, 1

// System calls
.equ SYS_exit, 0x1
.equ SYS_write, 0x4
.equ SYS_CLASS, 0x2000000

.macro push_pair reg1, reg2
    stp \reg1, \reg2, [sp, #-16]!
.endm

.macro pop_pair reg1, reg2
    ldp \reg1, \reg2, [sp], #16
.endm

.macro frame_setup
    push_pair x29, x30    // Save frame pointer and link register
    mov x29, sp           // Set up frame pointer
    push_pair x19, x20    // Save callee-saved registers
.endm

.macro frame_teardown
    pop_pair x19, x20      // Restore callee-saved registers
    pop_pair x29, x30      // Restore frame pointer and link register
.endm

.macro exit code
    mov x0, #\code         // Exit code
    mov x16, #SYS_CLASS    // System call class
    orr x16, x16, #SYS_exit // Exit system call
    svc #0
.endm

.macro write fd, string, len
    mov x0, #\fd                // File descriptor
    adrp x1, \string@PAGE      // Load string address (page)
    add x1, x1, \string@PAGEOFF // Add page offset
    mov x2, #\len              // String length
    mov x16, #SYS_CLASS        // System call class
    orr x16, x16, #SYS_write   // Write system call
    svc #0
    cmn x0, #1                 // Check for error
    b.eq write_error           // Branch if error
.endm

.globl _main
_main:
    frame_setup

    write STDOUT, hello_world, 14
    write STDOUT, banana, 7

    bl print_loop

    frame_teardown
    exit EXIT_SUCCESS

print_loop:
    frame_setup

    // Initialize loop counter
    mov x19, 5

1:  // Loop
    cbz x19, 2f              // Exit if counter is zero
    write STDOUT, banana, 7
    sub x19, x19, #1         // Decrement counter
    b 1b                     // Continue loop

2:  // loop done
    frame_teardown 
    ret

write_error:
    write STDERR, error_msg, 13
    exit EXIT_FAILURE

.section __TEXT,__const
hello_world:
    .asciz "Hello, World!\n"
banana:
    .asciz "Banana\n"
error_msg:
    .asciz "Write error!\n"

.section __TEXT,__cstring,cstring_literals
