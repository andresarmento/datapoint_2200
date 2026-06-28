// ============================================================================
//  Datapoint 2200 (Version I) - Load Immediate instruction
//
//  André Sarmento Barbosa - 2026
// ============================================================================
module dp2200_cpu (
    input  wire clk,
    input  wire rst_n,
    output reg  [12:0] mem_addr,    // RAM Address
    input  wire [7:0]  mem_rdata,   // RAM data
    output wire [7:0]  dbg_reg      // Debug: 0=A 1=B 2=C 3=D 4=E 5=H 6=L
);

    reg [12:0] P;               // Program Counter (13 bits in Version I)
    reg [7:0]  IR;              // Instruction register
    reg [7:0]  OPR;             // Operand register
    reg [7:0]  reg_file [0:7];  // Register file: A B C D E H L dummy
    reg [3:0]  state;
    integer    i;
    wire [1:0] inst_type = IR[7:6];  // Instruction type
    wire [2:0] mod1st    = IR[5:3];  // 1st modifier
    wire [2:0] mod2nd    = IR[2:0];  // 2nd modifier

    assign dbg_reg = reg_file[0]; // 0=A 1=B 2=C 3=D 4=E 5=H 6=L

    wire is_type2 = (inst_type == 2'b00) && ((mod2nd == 3'b100) || (mod2nd == 3'b110));
    wire is_type3 = (inst_type == 2'b01);

    // ----------------------------------------------------------------
    //  Datapoint 2200 FSM
    // ----------------------------------------------------------------
    localparam S_RESET          = 4'd0,
               S_FETCH_OPCODE   = 4'd1,
               S_WAIT_OPCODE    = 4'd2,
               S_FETCH_OPER     = 4'd3,
               S_WAIT_OPER      = 4'd4,
               S_FETCH_LSP      = 4'd5,
               S_WAIT_LSP       = 4'd6,
               S_FETCH_MSP      = 4'd7,
               S_WAIT_MSP       = 4'd8,
               S_EXEC           = 4'd9;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= S_RESET;
            P        <= 13'd0;
            IR       <= 8'd0;
            OPR      <= 8'd0;
            mem_addr <= 13'd0;
            for (i = 0; i < 8; i = i + 1)
                reg_file[i] <= 8'd0;

        end else begin
            case (state)
                S_RESET: begin
                    state    <= S_FETCH_OPCODE;
                    mem_addr <= P;
                end

                S_FETCH_OPCODE: begin
                    state <= S_WAIT_OPCODE;
                    P     <= P + 1;
                end

                S_WAIT_OPCODE: begin
                    IR       <= mem_rdata;
                    mem_addr <= P;
                    if (mem_rdata[7:6] == 2'b01)            // Decode Type-3
                        state <= S_FETCH_LSP;
                    else if ((mem_rdata[7:6] == 2'b00) &&   // Decode Type-2
                             ((mem_rdata[2:0] == 3'b100) || (mem_rdata[2:0] == 3'b110)))
                        state <= S_FETCH_OPER;
                    else                                    // Decode Type-1
                        state <= S_EXEC;
                end

                S_FETCH_OPER: begin
                    state <= S_WAIT_OPER;
                    P     <= P + 1;
                end

                S_WAIT_OPER: begin
                    OPR   <= mem_rdata;
                    state <= S_EXEC;
                end

                S_EXEC: begin
                    if (is_type2 && mod2nd == 3'b110)   // LImm (load immediate)
                        reg_file[mod1st] <= OPR;
                    else if (inst_type == 2'b11)        // LOAD d,s
                        reg_file[mod1st] <= reg_file[mod2nd];
                    state    <= S_FETCH_OPCODE;
                    mem_addr <= P;
                end

                default: state <= S_FETCH_OPCODE;
            endcase
        end
    end
endmodule


