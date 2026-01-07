`timescale 1ns/1ps

// LUI: Load Upper Immediate
module lui_unit32(
    input  [31:0] rs2,
    output [31:0] out
);
assign out = {rs2[15:0], 16'h0000};
endmodule
