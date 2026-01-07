// shifter32.v
// shift_type: 2'b01 = SLA, 10 = SRL, 11 = SRA
`timescale 1ns/1ps

module shifter32(
    input  [31:0] in,
    input  [31:0] rs2,        // for SLA (use rs2[0])
    input  [4:0]  shamt,      // for SLAI, SRLI, SRAI
    input  [2:0]  func,
    output reg [31:0] out
);
always @(*) begin
    case(func)
        3'b000: out = in << shamt;              // SLAI
        3'b001: out = in >> shamt;              // SRLI (logical right)
        3'b010: out = $signed(in) >>> shamt;    // SRAI (arithmetic right)
        3'b011: out = in << rs2[0];             // SLA (1-bit max shift)
        default: out = in;
    endcase
end
endmodule