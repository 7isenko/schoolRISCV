# RISC-V simple counter program
#
            .text

start:      addi a0, zero, 4            # a0 = b'100
shift:      srli a0, a0, 1              # a0 = a0 >> 1
            beq a0, zero, start         # if t0 == t1 then start
            beq zero, zero, shift       #             else shift
