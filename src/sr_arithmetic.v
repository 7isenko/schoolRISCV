module hypotenuse(
    input clk_i,
    
    input start_i,
    input [7:0] a_bi,
    input [7:0] b_bi,
    
    output wire [8:0] c_bo,
    output wire  busy_o
    );
    
    reg[17:0] sum;
    
    localparam IDLE             = 3'b000;
    localparam WORK_MULT        = 3'b001;
    localparam PREP_SQRT        = 3'b010;
    localparam START_SQRT       = 3'b011;
    localparam WORK_SQRT        = 3'b100;
    reg[2:0] state = IDLE;
    assign busy_o = |state;
    
    wire sqrt_start, sqrt_busy;
    wire[8:0] sqrt_rez;
    sqrt my_sqrt(clk_i, start_i, sqrt_start, sum, sqrt_rez, sqrt_busy);
    
    wire mult_start;
    wire multa_busy;
    wire multb_busy;
    wire[15:0] multa_rez;
    wire[15:0] multb_rez;
    mult my_multa(clk_i, mult_start, a_bi, a_bi, multa_rez, multa_busy);
    mult my_multb(clk_i, mult_start, b_bi, b_bi, multb_rez, multb_busy);
    
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
                end
            WORK_MULT:
                begin
                    if (!multa_busy && !multb_busy) begin
                        state <= PREP_SQRT;
                    end
                end
            PREP_SQRT:
                begin
                    sum <= multa_rez + multb_rez;
                    state <= START_SQRT;
                end
            START_SQRT:
                begin
                    state <= WORK_SQRT;
                end
            WORK_SQRT:
                begin
                    if (!sqrt_busy) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
endmodule

module sqrt(
    input clk_i,
    input rst_i,
    input start_i,
    input [17:0] x_bi,
    output reg [8:0] y_bo = 0,
    output busy_o
);
    localparam IDLE = 2'h0;
    localparam WORK = 2'b01;
    localparam RECALC_X = 2'b10;
    reg [17:0] x;
    reg [17:0] part_result;
    reg [17:0] b = 0;
    reg [16:0] m;
    reg [1:0] state = IDLE;
    wire end_step; 
    wire x_above_b;
    assign end_step = (m == 0);
    assign busy_o = |state;
    assign x_above_b = x>=b;
    always @(posedge clk_i)
    if (rst_i)
    begin
        y_bo <= 0;
        b <= 0;
        state <= IDLE;
    end
    else
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
                        if(x_above_b) begin
                            x <= x - b;
                            part_result <= part_result | m;
                        end
                        m <= m >> 2;
                        state <= WORK;
                    end    
            endcase
        end    
endmodule

module mult(
    input clk_i,
    
    input start_i,
    input [7:0] a_bi,
    input [7:0] b_bi,
    
    output reg [15:0] y_bo,
    output busy_o
    );
    
    localparam IDLE = 1'b0;
    localparam WORK = 1'b1;
    
    reg [3:0] ctr;
    wire [2:0] end_step;
    wire [7:0] part_sum;
    wire [15:0] shifted_part_sum;
    reg [7:0] a, b;
    reg [15:0] part_res;
    reg state = IDLE;
    
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
                end
            WORK:
                begin
                    if (end_step) 
                    begin
                        y_bo <= part_res;
                        state <= IDLE;
                    end
                    
                    part_res <= part_res + shifted_part_sum; // ___СЛОЖЕНИЕ___
                    ctr <= ctr + 1;
                end
            endcase
        end
endmodule
