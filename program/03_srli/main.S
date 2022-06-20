# RISC-V simple srli program
#
            .text

start:      addi a0, zero, 1024         # a0 = 2^10
shift:      srli a0, a0, 1              # a0 = a0 >> 1
            beq zero, zero, shift       # shift
