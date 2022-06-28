# RISC-V hypo program
#
        .text

init:   li      a0, 0          ## calculation result
        li      a3, 0          ## calculation result
        
        li      a1, 255       
        li      a2, 255  
hypo2:  rem     a3, a1, a2     ## z = 360
        add     a0, zero, a3

