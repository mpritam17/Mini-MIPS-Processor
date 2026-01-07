`timescale 1ns/1ps

module alu32(
    input  [31:0] rs1, rs2,   // operands (rs2 carries imm for I-type)
    input  [5:0] opcode,     // opcode field
    input  [5:0] funct,      // funct field (valid if opcode==000000)
//    input  [15:0] imm16,      // for LUI
    output [31:0] result,
    output zero,
    output ovf
);

// Extract control bits
wire [2:0] block_sel = (opcode==6'b000000) ? funct[5:3] : opcode[5:3];
wire [2:0] func_sel  = (opcode==6'b000000) ? funct[2:0] : opcode[2:0];

// Block outputs
wire [31:0] arith_out, logic_out, shft_out, ham_out, lui_out, mov_out;
wire arith_ovf;

arith_unit32 AU(.a(rs1), .b(rs2), .func(func_sel), .out(arith_out), .ovf(arith_ovf));
logic_unit32 LU(.a(rs1), .b(rs2), .func(func_sel), .out(logic_out));
shifter32    SH(.in(rs1), .rs2(rs2), .shamt(rs2[4:0]), .func(func_sel), .out(shft_out));
ham_unit32   HAM(.a(rs1), .out(ham_out));
lui_unit32   LUI(.rs2(rs2), .out(lui_out));
mov_unit32   MOV(.rs1(rs1), .rs2(rs1), .rs3(rs2), .funct(funct), .out(mov_out)); 

// Output mux
reg [31:0] res_reg;
reg ovf_reg;

always @(*) begin
    res_reg = 0;
    ovf_reg = 0;

    if (opcode == 6'b000000) begin
        // R-type
        case (funct)
            6'b001000, 6'b001001, 6'b001010, 6'b001011, // ADD, SUB, INC, DEC
            6'b001100, 6'b001101: begin                 // SLT, SGT
                res_reg = arith_out;
                ovf_reg = arith_ovf;
            end
            6'b010000, 6'b010001, 6'b010010, 6'b010011, 6'b010100:  // logic ops
                res_reg = logic_out; 
            6'b011011, 6'b011001, 6'b011010: // shift ops
                res_reg = shft_out;  
            6'b101000: // HAM
                res_reg = ham_out;   
            // MOVE / CMOV
            6'b110000, 6'b110001: res_reg = mov_out;
            default: res_reg = 0;
        endcase
    end else begin
        // I-type
        case (opcode)
            6'b001000,6'b001001: begin 
                res_reg = arith_out; ovf_reg = arith_ovf; 
                end // ADDI, SUBI
            6'b010000,6'b010001,6'b010010: 
                res_reg = logic_out;  // ANDI, ORI, XORI
            6'b011000,6'b011001,6'b011010: res_reg = shft_out;   // SLAI, SRLI, SRAI
            6'b110000: res_reg = lui_out;    // LUI
            default: res_reg = 0;
        endcase
    end
end

assign result = res_reg;
assign ovf    = ovf_reg;
assign zero   = (res_reg==0);

endmodule
