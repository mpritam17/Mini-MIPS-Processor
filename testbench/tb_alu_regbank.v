`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2025 16:47:58
// Design Name: 
// Module Name: tb_alu_regbank
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


module tb_top_regbank_entire;

    reg clk, rst;
    reg [31:0] instruction;
    wire [31:0] alu_result;

    top_regbank_entire DUT (
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .alu_result(alu_result)
    );

    // Clock
    always #5 clk = ~clk;

    // --- Task: write directly into regbank ---
    task reg_write(input [3:0] addr, input [31:0] data);
        begin
            DUT.RB.regs[addr] = data;
        end
    endtask

    // --- Task: check expected result ---
    task check_result(input [31:0] expected, input [255:0] msg);
        begin
            #2;
            $display("\n[TEST] %-10s", msg);
            $display("    -> Expected: 0x%h | Got: 0x%h", expected, alu_result);
            if (alu_result === expected)
                $display("    PASS: %-10s", msg);
            else
                $display("    FAIL: %-10s (Expected %h, Got %h)", msg, expected, alu_result);
        end
    endtask

    // --- Main test sequence ---
    initial begin
        clk = 0; instruction = 0;
        #10

        // Initialize registers
        reg_write(4'd1, 32'h00000010); // R1 = 0x10
        reg_write(4'd2, 32'h00000020); // R2 = 0x20
        reg_write(4'd3, 32'h00000070); // R3 = 0x70
        reg_write(4'd4, 32'h00000010); // R4 = 0x10
        reg_write(4'd5, 32'h00000000); // R5 = 0
        reg_write(4'd6, 32'h00000005); // R6 = 0x05
        reg_write(4'd7, 32'hFFFFFFF0); // R7 = -16

        $display("\n============== STARTING FULL TESTBENCH ==============\n");

        // ===========================================================
        // R-TYPE INSTRUCTIONS
        // ===========================================================

        $display("R1=0x%h, R2=0x%h", DUT.RB.regs[1], DUT.RB.regs[2]);
        instruction = {6'b000000, 4'd1, 4'd2, 4'd8, 5'b0, 6'b001000, 3'b000}; // ADD R8 = R1 + R2
        #10 check_result(32'h30, "ADD");

        $display("R2=0x%h, R1=0x%h", DUT.RB.regs[2], DUT.RB.regs[1]);
        instruction = {6'b000000, 4'd2, 4'd1, 4'd9, 5'b0, 6'b001001, 3'b0}; // SUB R9 = R2 - R1
        #10 check_result(32'h10, "SUB");

        $display("R1=0x%h", DUT.RB.regs[1]);
        instruction = {6'b000000, 4'd1, 4'd0, 4'd10, 5'b0, 6'b001010, 3'b0}; // INC R10 = R1 + 1
        #10 check_result(32'h11, "INC");

        $display("R2=0x%h", DUT.RB.regs[2]);
        instruction = {6'b000000, 4'd2, 4'd0, 4'd11, 5'b0, 6'b001011, 3'b0}; // DEC R11 = R2 - 1
        #10 check_result(32'h1F, "DEC");

        $display("R1=0x%h, R2=0x%h", DUT.RB.regs[1], DUT.RB.regs[2]);
        instruction = {6'b000000, 4'd1, 4'd2, 4'd12, 5'b0, 6'b001100, 3'b0}; // SLT R12 = (R1 < R2)
        #10 check_result(32'h1, "SLT");

        instruction = {6'b000000, 4'd2, 4'd1, 4'd13, 5'b0, 6'b001101, 3'b0}; // SGT R13 = (R2 > R1)
        #10 check_result(32'h1, "SGT");

        instruction = {6'b000000, 4'd1, 4'd2, 4'd14, 5'b0, 6'b010000, 3'b0}; // AND R14 = R1 & R2
        #10 check_result(32'h0, "AND");

        instruction = {6'b000000, 4'd1, 4'd2, 4'd15, 5'b0, 6'b010001, 3'b0}; // OR R15 = R1 | R2
        #10 check_result(32'h30, "OR");

        instruction = {6'b000000, 4'd1, 4'd2, 4'd9, 5'b0, 6'b010010, 3'b0}; // XOR R9 = R1 ^ R2
        #10 check_result(32'h30, "XOR");

        instruction = {6'b000000, 4'd1, 4'd2, 4'd10, 5'b0, 6'b010011, 3'b0}; // NOR R10 = ~(R1 | R2)
        #10 check_result(32'hFFFFFFCF, "NOR");

        instruction = {6'b000000, 4'd2, 4'd0, 4'd11, 5'b0, 6'b010100, 3'b0}; // NOT R11 = ~R2
        #10 check_result(32'hFFFFFFDF, "NOT");

        $display("R3=0x%h, R4=0x%h", DUT.RB.regs[3], DUT.RB.regs[4]);
        instruction = {6'b000000, 4'd3, 4'd4, 4'd12, 5'b0, 6'b011011, 3'b0}; // SLA R12 = R3 << R4[0]
        #10 check_result(32'h00000070, "SLA");

        instruction = {6'b000000, 4'd3, 4'd4, 4'd13, 5'b0, 6'b011001, 3'b0}; // SRL R13 = R3 >> R4
        #10 check_result(32'h00000000, "SRL");

        $display("R7=0x%h, R6=0x%h", DUT.RB.regs[7], DUT.RB.regs[6]);
        instruction = {6'b000000, 4'd7, 4'd6, 4'd14, 5'b0, 6'b011010, 3'b0}; // SRA R14 = R7 >>> R6
        #10 check_result(32'hFFFFFFFF, "SRA");

        instruction = {6'b000000, 4'd1, 4'd0, 4'd15, 5'b0, 6'b101000, 3'b0}; // HAM R15 = HammingWeight(R1)
        #10 check_result(32'h1, "HAM");

        instruction = {6'b000000, 4'd2, 4'd1, 4'd0, 5'b0, 6'b110000, 3'b0}; // MOV R2 <- R1
        #10 check_result(32'h10, "MOV");

        reg_write(4'd5, 32'h1234); // make R5 non-zero
        instruction = {6'b000000, 4'd5, 4'd1, 4'd0, 5'b0, 6'b110001, 3'b0}; // CMOV R5 <- R1
        #10 check_result(32'h10, "CMOV");

        // ===========================================================
        // I-TYPE INSTRUCTIONS
        // ===========================================================
        $display("R1=0x%h", DUT.RB.regs[1]);
        instruction = {6'b001000, 4'd1, 4'd2, 16'h0005, 2'b0}; // ADDI R2 = R1 + 5
        #10 check_result(32'h15, "ADDI");

        $display("R2=0x%h", DUT.RB.regs[2]);
        instruction = {6'b001001, 4'd2, 4'd3, 16'h0002, 2'b0}; // SUBI R3 = R2 - 2
        #10 check_result(32'h13, "SUBI");

        instruction = {6'b010000, 4'd1, 4'd4, 16'h000F, 2'b0}; // ANDI R4 = R1 & 0xF
        #10 check_result(32'h0, "ANDI");

        instruction = {6'b010001, 4'd1, 4'd5, 16'h00FF, 2'b0}; // ORI R5 = R1 | 0xFF
        #10 check_result(32'hFF, "ORI");

        instruction = {6'b010010, 4'd2, 4'd6, 16'h000F, 2'b0}; // XORI R6 = R2 ^ 0xF
        #10 check_result(32'h1A, "XORI");

        instruction = {6'b011000, 4'd1, 4'd7, 16'h0002, 2'b0}; // SLAI R7 = R1 << 2
        #10 check_result(32'h40, "SLAI");

        instruction = {6'b011001, 4'd1, 4'd8, 16'h0002, 2'b0}; // SRLI R8 = R1 >> 2
        #10 check_result(32'h4, "SRLI");

        instruction = {6'b011010, 4'd7, 4'd9, 16'h0003, 2'b0}; // SRAI R9 = R7 >>> 3
        #10 check_result(32'h8, "SRAI");

        instruction = {6'b110000, 4'd0, 4'd10, 16'h1234, 2'b0}; // LUI R10 = imm << 16
        #10 check_result(32'h12340000, "LUI");

        $display("\n============== ALL TESTS COMPLETED ==============\n");
        $finish;
    end
endmodule


