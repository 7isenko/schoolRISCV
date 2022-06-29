# RISC-V hypo program
#
        .text

        li      a0, 0          ## calculation result
init:   li      a1, 255       
        li      a2, 255  
hypo2:  rem     a0, a1, a2     ## z = 360
        li      a1, 3 
        li      a2, 4  
        rem     a0, a1, a2     ## z = 360
        beq zero, zero, init  
        

