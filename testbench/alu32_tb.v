`timescale 1ns/1ps

module tb_alu32;

    reg  [31:0] rs1, rs2;
    reg  [5:0]  opcode;
    reg  [5:0]  funct;
//    reg  [15:0] imm16;
    wire [31:0] result;
    wire        zero, ovf;

    reg  [31:0] expected;

    // DUT
    alu32 dut(
        .rs1(rs1), .rs2(rs2),
        .opcode(opcode), .funct(funct),
//        .imm16(imm16),
        .result(result), .zero(zero), .ovf(ovf)
    );

    // Enhanced check task
    task check(input [127:0] name);
        begin
            if (result !== expected)
                $display("%s | rs1=%h rs2=%h | result=%h expected=%h | FAIL",
                          name, rs1, rs2, result, expected);
            else
                $display("%s | rs1=%h rs2=%h | result=%h expected=%h | PASS",
                          name, rs1, rs2, result, expected);
        end
    endtask

    initial begin
        $dumpfile("alu32_tb.vcd");
        $dumpvars(0,tb_alu32);

        // ========= R-type tests =========
        opcode = 6'b000000;

        rs1=10; rs2=20; funct=6'b001000; #5;  expected = rs1 + rs2; check("ADD");
        rs1=30; rs2=5;  funct=6'b001001; #5;        expected = rs1 - rs2; check("SUB");
        rs1=15; rs2=0;  funct=6'b001010; #5;        expected = rs1 + 1;   check("INC");
        rs1=15; rs2=0;  funct=6'b001011; #5;        expected = rs1 - 1;   check("DEC");

        rs1=32'hF0F0; rs2=32'h0FF0; funct=6'b010000; #5; expected = rs1 & rs2; check("AND");
        rs1=32'hAAAA; rs2=32'h5555; funct=6'b010001; #5; expected = rs1 | rs2; check("OR");
        rs1=32'hAAAA; rs2=32'h5555; funct=6'b010010; #5; expected = rs1 ^ rs2; check("XOR");
        rs1=32'hAAAA; rs2=32'h5555; funct=6'b010011; #5; expected = ~(rs1 | rs2); check("NOR");
        rs1=32'hFFFF0000; rs2=0; funct=6'b010100; #5;   expected = ~rs1; check("NOT");

        rs1=32'hF000_0000; rs2=32'h0000_0004; funct=6'b011001; #5; expected = rs1 >> rs2[4:0]; check("SRL (R-type)");
        rs1=32'hF000_0000; rs2=32'h0000_0004; funct=6'b011010; #5; expected = $signed(rs1) >>> rs2[4:0]; check("SRA (R-type)");
        rs1=32'h0000_0001; rs2=32'h0000_0001; funct=6'b011011; #5; expected = rs1 << rs2[0]; check("SLA (R-type)");

        rs1=5;  rs2=10; funct=6'b001100; #5; expected = (rs1 < rs2) ? 1 : 0; check("SLT");
        rs1=15; rs2=10; funct=6'b001101; #5; expected = (rs1 > rs2) ? 1 : 0; check("SGT");

        rs1=32'h0000_0007; rs2=0; funct=6'b101000; #5; expected = 3; check("HAM");

        // ========= I-type tests =========
        opcode = 6'b001000; rs1=20; rs2=25; funct=0; #5; expected = rs1 + rs2; check("ADDI");
        opcode = 6'b001001; rs1=50; rs2=10; #5;      expected = rs1 - rs2; check("SUBI");

        opcode = 6'b010000; rs1=32'h1234; rs2=32'h00FF; #5; expected = rs1 & rs2; check("ANDI");
        opcode = 6'b010001; rs1=32'h1234; rs2=32'h00FF; #5; expected = rs1 | rs2; check("ORI");
        opcode = 6'b010010; rs1=32'h1234; rs2=32'hABCD; #5; expected = rs1 ^ rs2; check("XORI");

        opcode = 6'b011000; rs1=32'h0001; rs2=32'h0001; #5; expected = rs1 << rs2[4:0]; check("SLAI (I-type)");
        opcode = 6'b011001; rs1=32'hF000_0000; rs2=32'h0004; #5; expected = rs1 >> rs2[4:0]; check("SRLI (I-type)");
        opcode = 6'b011010; rs1=32'hF000_0000; rs2=32'h0004; #5; expected = $signed(rs1) >>> rs2[4:0]; check("SRAI (I-type)");

        opcode = 6'b110000; rs2=32'hABCD; rs1=0; #5; expected = {rs2[15:0], 16'h0000}; check("LUI");

        $finish;
    end

endmodule
