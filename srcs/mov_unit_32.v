`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2025 17:20:55
// Design Name: 
// Module Name: mov_unit_32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mov_unit32(
    input  [31:0] rs1,   
    input  [31:0] rs2,   
    input  [31:0] rs3,   
    input  [5:0]  funct, 
    output reg [31:0] out
);
    always @(*) begin
        case (funct)
            6'b110000: out = rs2;                     // MOVE: rd = rs2
            6'b110001: out = (rs2 < rs3) ? rs2 : rs3; // CMOV: rd = (rs2 < rs3)?rs2:rs3
            default:   out = 32'b0;
        endcase
    end
endmodule
