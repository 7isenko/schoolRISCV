# RISC-V sqrt program
#
# Stanislav Zhelnio, 2020
#

## unsigned isqrt (unsigned x) {
##     unsigned m, y, b;
##     m = 0x40000000;
##     y = 0;
##     while (m != 0) { // Do 16 times
##         b = y |  m;
##         y >>= 1;
##         if (x >= b) {
##             x -= b;
##             y |= m;
##         }
##         m >>= 2;
##     }
##     return y;
## }

        .text

init:   li      a0, 0          ## calculation result reset
        li      a1, 8          ## x = 8
        li      a2, 16         ## y = 16

mul:    mul     a0, a1, a2

end:    bnez     a0, init  
