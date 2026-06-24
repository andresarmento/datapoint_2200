// ============================================================================
//  Datapoint 2200 (Version I) - FSM
//
//  André Sarmento Barbosa - 2026
// ============================================================================
module dp2200_cpu (
    input  wire clk,
    input  wire rst_n,
    output reg  [12:0] mem_addr,    // RAM Address
    input  wire [7:0]  mem_rdata    // RAM data
);
 
    reg [12:0] P;               // Program Counter (13 bits in Version I)
    reg [7:0]  IR;              // Instruction register
    reg [7:0]  OPR;             // Operand register
    reg [3:0]  state;


    // ----------------------------------------------------------------
    //  Datapoint 2200 FSM
    // ----------------------------------------------------------------
    localparam S_RESET          = 4'd0,
               S_WAIT_OPCODE    = 4'd1,
               S_FETCH_OPCODE   = 4'd2,
               S_EXEC           = 4'd3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= S_RESET;
            P        <= 13'd0;
            IR       <= 8'd0;
            mem_addr <= 13'd0;

        end else begin
            case (state)
                S_RESET: begin
                    state <= S_WAIT_OPCODE;
                    mem_addr <= P;
                end
 
                S_WAIT_OPCODE: begin
                    state <= S_FETCH_OPCODE;
                    P  <= P + 1;
                end
 
                S_FETCH_OPCODE: begin
                    IR <= mem_rdata;
                    state <= S_EXEC;
                end

                S_EXEC: begin
                    state <= S_WAIT_OPCODE;
                    mem_addr <= P;
                end
 
                default: state <= S_WAIT_OPCODE;
            endcase
        end
    end
endmodule
 
 
