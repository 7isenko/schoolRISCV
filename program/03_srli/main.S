# RISC-V simple srli program
#
            .text

start:      addi a0, zero, 16           # a0 = 3'b10000
shift:      srli a0, a0, 2              # a0 = a0 >> 2
            beq a0, zero, start         # if a0 == 0 then start
            beq zero, zero, shift       #             else shift
