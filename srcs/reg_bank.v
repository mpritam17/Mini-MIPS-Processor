`timescale 1ns / 1ps

module reg_bank(
    input clk,
    input rst,
    input we,               // write enable
    input [3:0] rd_addr,    // destination register
    input [3:0] rs1_addr,   // source register 1
    input [3:0] rs2_addr,   // source register 2
    input [31:0] wd,        // data to write
    output [31:0] rs1,      // read data 1
    output [31:0] rs2       // read data 2
);
    reg [31:0] regs [0:15];
    integer i;

    // Initial values (for simulation + power-on initialization)
    initial begin
        regs[0]  = 32'h00000000;
        regs[1]  = 32'h00000001;
        regs[2]  = 32'h00000002;
        regs[3]  = 32'h00000003;
        regs[4]  = 32'h00000004;
        regs[5]  = 32'h00000005;
        regs[6]  = 32'h00000006;
        regs[7]  = 32'h00000007;
        regs[8]  = 32'h00000008;
        regs[9]  = 32'h00000009;
        regs[10] = 32'h0000000A;
        regs[11] = 32'h0000000B;
        regs[12] = 32'h0000000C;
        regs[13] = 32'h0000000D;
        regs[14] = 32'h0000000E;
        regs[15] = 32'h0000000F;
    end

    // Combinational reads
    assign rs1 = regs[rs1_addr];
    assign rs2 = regs[rs2_addr];

    // Sequential reset + write
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // regs[0]  <= 32'h00000000;
            // regs[1]  <= 32'h00000001;
            // regs[2]  <= 32'h00000002;
            // regs[3]  <= 32'h00000003;
            // regs[4]  <= 32'h00000004;
            // regs[5]  <= 32'h00000005;
            // regs[6]  <= 32'h00000006;
            // regs[7]  <= 32'h00000007;
            // regs[8]  <= 32'h00000008;
            // regs[9]  <= 32'h00000009;
            // regs[10] <= 32'h0000000A;
            // regs[11] <= 32'h0000000B;
            // regs[12] <= 32'h0000000C;
            // regs[13] <= 32'h0000000D;
            // regs[14] <= 32'h0000000E;
            // regs[15] <= 32'h0000000F;
            regs[0]  <= 32'h00000000;
            regs[1]  <= 32'h00000000;
            regs[2]  <= 32'h00000000;
            regs[3]  <= 32'h00000000;
            regs[4]  <= 32'h00000000;
            regs[5]  <= 32'h00000000;
            regs[6]  <= 32'h00000000;
            regs[7]  <= 32'h00000000;
            regs[8]  <= 32'h00000000;
            regs[9]  <= 32'h00000000;
            regs[10] <= 32'h00000000;
            regs[11] <= 32'h00000000;
            regs[12] <= 32'h00000000;
            regs[13] <= 32'h00000000;
            regs[14] <= 32'h00000000;
            regs[15] <= 32'h00000000;
        end else if (we && rd_addr != 0) begin
            regs[rd_addr] <= wd;
        end
    end
endmodule
