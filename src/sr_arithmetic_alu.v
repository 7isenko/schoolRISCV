module hypotenuse_alu(
    input clk_i,
    
    input start_i,
    input [7:0] a_bi,
    input [7:0] b_bi,
    input [31:0] resALU,
    
    output reg [2:0] operationALU = 3'b000,
    output reg [31:0] argA,
    output reg [31:0] argB,
    output wire [8:0] c_bo,
    output reg  ready_o = 1'b0
    );
    
    reg[17:0] sum;
    
    localparam IDLE             = 3'b000;
    localparam WORK_MULT        = 3'b001;
    localparam END_MULT         = 3'b010;
    localparam PREP_SQRT        = 3'b011;
    localparam START_SQRT       = 3'b100;
    localparam WORK_SQRT        = 3'b101;
    reg[2:0] state = IDLE;
    
    wire sqrt_start, sqrt_busy;
    wire[8:0] sqrt_rez;
    wire[17:0] argA_ALU_sqrt;
    wire[17:0] argB_ALU_sqrt;
    sqrt_alu my_sqrt(clk_i, sqrt_start, sum, resALU, argA_ALU_sqrt, argB_ALU_sqrt, sqrt_rez, sqrt_busy);
    
    wire mult_start;
    wire multa_busy;
    wire multb_busy;
    wire[15:0] multa_rez;
    wire[15:0] multb_rez;
    wire[15:0] argA_ALU_mult;
    wire[15:0] argB_ALU_mult;
    
    mult my_multa(clk_i, mult_start, a_bi, a_bi, multa_rez, multa_busy);
    mult_alu my_multb(clk_i, mult_start, b_bi, b_bi, resALU, argA_ALU_mult, argB_ALU_mult, multb_rez, multb_busy);
    
    assign c_bo = sqrt_rez;
    assign sqrt_start = (state == START_SQRT);
    assign mult_start = (state == IDLE && start_i);
     
    always @(posedge clk_i)
        begin
            case(state)
            IDLE:
                if(start_i) 
                begin
                    state <= WORK_MULT;
                    operationALU <= 3'b000;
                    argA <= {16'b0, argA_ALU_mult};
                    argB <= {16'b0, argB_ALU_mult};
                    ready_o <= 0;
                end
            WORK_MULT:
                begin
                    if (!multa_busy && !multb_busy) begin
                        state <= END_MULT;
                    end
                    operationALU <= 3'b000;
                    argA <= {16'b0, argA_ALU_mult};
                    argB <= {16'b0, argB_ALU_mult};
                end
            END_MULT:
                begin
                    argA <= multa_rez;
                    argB <= multb_rez;
                    operationALU <= 3'b000;
                    state <= PREP_SQRT;
                end
            PREP_SQRT:
                begin                  
                    sum <= resALU;
                    state <= START_SQRT;
                    operationALU <= 3'b100;
                    argA <= resALU;
                    argB <= {14'b0, argB_ALU_sqrt};
                end
            START_SQRT:
                begin
                    state <= WORK_SQRT;
                    operationALU <= 3'b100;
                    argA <= {14'b0, argA_ALU_sqrt};
                    argB <= {14'b0, argB_ALU_sqrt};
                end
            WORK_SQRT:
                begin
                    if (!sqrt_busy) begin 
                        state <= IDLE;
                        ready_o <= 1;
                    end
                    operationALU <= 3'b100;
                    argA <= {14'b0, argA_ALU_sqrt};
                    argB <= {14'b0, argB_ALU_sqrt};
                end
            endcase
        end
endmodule

module sqrt_alu(
    input clk_i,
    input start_i,
    input [17:0] x_bi,
    input [17:0] alu_res,

    output reg [17:0] x,
    output reg [17:0] b = 0,
    output reg [8:0] y_bo = 0,
    output busy_o
);
    localparam IDLE = 2'h0;
    localparam WORK = 2'b01;
    localparam RECALC_X = 2'b10;
    reg [17:0] part_result;
    reg [16:0] m;
    reg [1:0] state = IDLE;
    reg pause = 1'b1;
    wire end_step; 
    wire x_above_b;
    assign end_step = (m == 0);
    assign busy_o = |state;
    assign x_above_b = x>=b;
    always @(posedge clk_i)
        begin
            case (state)
                IDLE:
                    if (start_i) begin
                        state <= WORK;
                        part_result <= 0;
                        x <= x_bi;
                        m <= 1 << 16;
                    end
                WORK:
                    begin
                        if (!end_step) begin
                           b <= part_result | m;
                           part_result <= part_result >> 1;
                           state <= RECALC_X; 
                        end else begin
                            y_bo <= part_result[8:0];    
                            state <= IDLE;
                        end     
                    end
                RECALC_X:
                    begin
                        if (pause)
                        begin
                            pause = 1'b0;
                        end else
                        begin
                            if(x_above_b) begin
                                x <= alu_res;
                                part_result <= part_result | m;
                            end
                            m <= m >> 2;
                            state <= WORK;
                            pause = 1'b1;
                        end
                    end    
            endcase
        end    
endmodule

module mult_alu(
    input clk_i,
    
    input start_i,
    input [7:0] a_bi,
    input [7:0] b_bi,
    input [15:0] alu_res,
    
    output reg [15:0] part_res,
    output wire [15:0] shifted_part_sum,
    output reg [15:0] y_bo,
    output busy_o
    );
    
    localparam IDLE = 1'b0;
    localparam WORK = 1'b1;
    
    reg [3:0] ctr;
    wire [2:0] end_step;
    wire [7:0] part_sum;
    reg [7:0] a, b;
    reg state = IDLE;
    reg pause = 1'b0;
    
    assign part_sum = a &{8{b[ctr]}}; // a & (replicate b[ctr] 8 times)
    assign shifted_part_sum = part_sum << ctr;
    assign end_step = (ctr == 4'h8); 
    assign busy_o = state;
    
    always @(posedge clk_i)
        begin
            case(state)
            IDLE:
                if(start_i) 
                begin
                    state <= WORK;
                    
                    a <= a_bi;
                    b <= b_bi;
                    ctr <= 0;
                    part_res <= 0;
                    pause = 1'b1;
                end
            WORK:
                begin
                    if (end_step) 
                    begin
                        y_bo <= part_res;
                        state <= IDLE;
                    end
                
                    if (pause)
                    begin
                        pause = 1'b0;
                    end    
                    else begin
                        part_res <= alu_res;
                        ctr <= ctr + 1;
                        pause <= 1'b1;
                    end
                end
            endcase
        end
endmodule
