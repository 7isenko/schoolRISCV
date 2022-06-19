# RISC-V sqrt program
#
# Stanislav Zhelnio, 2020
#

        .text

init:   li      a0, 0          ## calculation result reset
        li      a1, 3         
        li      a2, 4         
        li      a3, 255       
        li      a4, 255       
        li      a5, 0         
        li      a6, 0         

hypo1:  rem     a0, a1, a2     ## z = 5
hypo2:  rem     a0, a3, a4     ## z = 360
hypo3:  rem     a0, a5, a6     ## z = 0

