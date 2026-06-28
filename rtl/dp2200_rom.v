// ============================================================================
//  Datapoint 2200 - ROM Memory 8K x 8
//  
//  André Sarmento Barbosa
// ============================================================================
`define ROM_FILE "C:/Users/andre/Downloads/PROJECTS/DATAPOINT_2200/datapoint_2200_fpga/sw/examples/"

module dp2200_rom (
    input  wire        clk,
    input  wire [12:0] addr,
    output reg  [7:0]  rdata
);

    reg [7:0] rom [0:8191];

    initial $readmemh({`ROM_FILE, "002_LOAD.hex"}, rom);

    always @(posedge clk) begin
        rdata <= rom[addr];
    end
endmodule