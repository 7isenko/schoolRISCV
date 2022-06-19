/*
 * schoolRISCV - small RISC-V CPU 
 *
 * originally based on Sarah L. Harris MIPS CPU 
 *                   & schoolMIPS project
 * 
 * Copyright(c) 2017-2020 Stanislav Zhelnio 
 *                        Aleksandr Romanov 
 */ 

module sm_register // регистр с асинхронным сбросом
(
    input                 clk,
    input                 rst,
    input      [ 31 : 0 ] d,
    output reg [ 31 : 0 ] q
);
    always @ (posedge clk or negedge rst)
        if(~rst)
            q <= 32'b0;
        else
            q <= d;
endmodule


module sm_register_we // we - write enable 
(
    input                 clk,
    input                 rst,
    input                 we,
    input      [ 31 : 0 ] d,
    output reg [ 31 : 0 ] q
);
    always @ (posedge clk or negedge rst)
        if(~rst)
            q <= 32'b0;
        else
            if(we) q <= d;
endmodule

module sm_register_we_n // we - write enable 
(
    input                 clk,
    input                 rst,
    input                 we,
    input      [ 31 : 0 ] d,
    output reg [ 31 : 0 ] q
);
    always @ (negedge clk or negedge rst)
        if(~rst)
            q <= 32'b0;
        else
            if(we) q <= d;
endmodule
