# RISC-V hypo program
#
        .text

init:   li      a0, 0          ## calculation result
        li      a3, 0          ## calculation result
        li      a4, 0          ## calculation result
        li      a5, 0          ## calculation result

        li      a1, 3         
        li      a2, 4  
hypo1:  rem     a3, a1, a2     ## z = 5
        add     a0, zero, a3
        li      a1, 255       
        li      a2, 255  
hypo2:  rem     a4, a1, a2     ## z = 360
        add     a0, zero, a4
        li      a1, 0         
        li      a2, 0   
hypo3:  rem     a5, a1, a2     ## z = 0
        add     a0, zero, a5

