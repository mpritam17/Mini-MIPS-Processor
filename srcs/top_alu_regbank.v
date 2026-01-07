module top_regbank_entire (
    input  wire clk,
    input  wire rst,
    input  wire [31:0] instruction,
    output wire [31:0] alu_result
);

    // Instruction fields
    wire [5:0] opcode = instruction[31:26];
    wire [3:0] rs     = instruction[25:22];
    wire [3:0] rt     = instruction[21:18];
    wire [3:0] rd     = instruction[17:14];
    wire [5:0] funct  = instruction[8:3];
    wire [15:0] imm16 = instruction[17:2];

    // Regbank interface
    wire [31:0] rs_val, rt_val;
    reg  [31:0] wd;
    reg  [3:0]  rd_addr;
    reg         we;

    reg_bank RB (
        .clk(clk),
        .rst(rst),
        .we(we),
        .rd_addr(rd_addr),
        .rs1_addr(rs),
        .rs2_addr(rt),
        .wd(wd),
        .rs1(rs_val),
        .rs2(rt_val)
    );

    // ALU interface
    wire [31:0] alu_out;
    wire alu_zero, alu_ovf;

    alu32 ALU (
        .rs1(rs_val),
        .rs2((opcode == 6'b001000 || opcode == 6'b001001 || 
              opcode == 6'b010000 || opcode == 6'b010001 || opcode == 6'b010010 ||
              opcode == 6'b011000 || opcode == 6'b011001 || opcode == 6'b011010 ||
              opcode == 6'b110000) ? {{16{imm16[15]}}, imm16} : rt_val),
        .opcode(opcode),
        .funct(funct),
        .result(alu_out),
        .zero(alu_zero),
        .ovf(alu_ovf)
    );

    assign alu_result = alu_out;

    // Core control
    always @(*) begin
        we = 0;
        rd_addr = 4'b0;
        wd = 32'b0;

            case (opcode)
                6'b000000: begin
                    case (funct)
                        // Arithmetic ops
                        6'b001000, 6'b001001, 6'b001010, 6'b001011, 
                        6'b001100, 6'b001101: begin
                            we = 1; rd_addr = rd; wd = alu_out;
                        end

                        // Logic ops
                        6'b010000, 6'b010001, 6'b010010, 6'b010011, 6'b010100: begin
                            we = 1; rd_addr = rd; wd = alu_out;
                        end

                        // Shift ops
                        6'b011011, 6'b011001, 6'b011010: begin
                            we = 1; rd_addr = rd; wd = alu_out;
                        end

                        // Hamming or custom ops
                        6'b101000: begin
                            we = 1; rd_addr = rd; wd = alu_out;
                        end

                        // MOV 
                        6'b110000: begin
                            we = 1; rd_addr = rs; wd = rt_val;
                        end

                        // CMOV 
                        6'b110001: begin
                            we = 1; rd_addr = rs; wd = rt_val;
                        end

                        default: we = 0;
                    endcase
                end

                // I-type arithmetic and logic
                6'b001000, 6'b001001, 6'b011000, 6'b011001, 6'b011010,
                6'b010000, 6'b010001, 6'b010010, 6'b110000: begin
                    we = 1; rd_addr = rt; wd = alu_out;
                end
            endcase
        end
endmodule