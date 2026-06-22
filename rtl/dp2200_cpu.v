// ============================================================================
//  Datapoint 2200 (Version I) - control FSM skeleton
//  No instructions implemented yet. This is just the instruction-cycle
//  "engine": fetch a byte, advance P, land in DECODE, loop back to fetch.
//
//  André Sarmento Barbosa - 2026
// ============================================================================
module dp2200_cpu (
    input  wire clk,
    input  wire rst_n,
    output reg  [12:0] mem_addr,     // RAM Address
    input  wire [7:0]  mem_rdata     // RAM data
);
 
    reg [12:0] P;               // P  - program counter (13 bits in Version I)
    reg [7:0]  IR;              // IR - instruction register
    reg [1:0] state;

    // ----------------------------------------------------------------
    //  Datapoint 2200 FSM
    // ----------------------------------------------------------------
    localparam S_RESET  = 2'd0,
               S_FETCH  = 2'd1,
               S_FETCH2 = 2'd2,
               S_DECODE = 2'd3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_RESET;
            P     <= 13'd0;
            IR    <= 8'd0;
            mem_addr <= 13'd0;

        end else begin
            case (state)
                S_RESET: begin
                    state <= S_FETCH;
                end
 
                S_FETCH: begin
                    mem_addr <= P;
                    state    <= S_FETCH2;
                end
 
                S_FETCH2: begin
                    IR    <= mem_rdata;
                    P     <= P + 13'd1;
                    state <= S_DECODE;
                end
 
                S_DECODE: begin
                    state <= S_FETCH;
                end
 
                default: state <= S_FETCH;
            endcase
        end
    end
endmodule
 
 
