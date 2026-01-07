`timescale 1ns / 1ps
module riscv_processor_top(
    input  wire clk,
    input  wire rst,        // Reset button
    input  wire led_sel,    // Switch: upper/lower 16 bits
    output wire [15:0] leds
);

reg [31:0] PC;
reg [31:0] next_PC;
wire [31:0] instruction;

blk_mem_gen_1 INST_MEM (
    .clka(clk),
    .addra(PC[9:0]),   // assuming <= 1024 instructions
    .douta(instruction)
);


    // Instruction fields
    wire [5:0] opcode = instruction[31:26];
    wire [3:0] rs     = instruction[25:22];
    wire [3:0] rt     = instruction[21:18];
    wire [3:0] rd     = instruction[17:14];
    wire [5:0] funct  = instruction[8:3];
    wire [15:0] imm16 = instruction[17:2];
    wire [25:0] imm26 = instruction[25:0];
    
    reg [5:0] cur_opcode;

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

wire [31:0] PC_plus_1;

ripple_adder_32 PC_INC (
    .a(PC),
    .b(32'd1),
    .cin(1'b0),
    .sum(PC_plus_1),
    .cout(),
    .overflow()
);

wire [31:0] imm16_ext = {{16{imm16[15]}}, imm16};
wire [31:0] PC_branch16;

ripple_adder_32 PC_BRANCH16_ADDER (
    .a(PC),
    .b(imm16_ext),
    .cin(1'b0),
    .sum(PC_branch16),
    .cout(),
    .overflow()
);


wire [31:0] imm26_ext = {{6{imm26[25]}}, imm26};
wire [31:0] PC_branch26;
ripple_adder_32 PC_BRANCH26_ADDER (
    .a(32'd0),
    .b(imm26_ext),
    .cin(1'b0),
    .sum(PC_branch26),
    .cout(),
    .overflow()
);


    reg ld_en, st_en;
    reg [31:0] mem_addr, mem_wdata;
    wire [31:0] mem_rdata;
    wire mem_ready;

// ld_st_module LDST (
//     .clk(clk),
//     .reset(rst),
//     .execute((opcode[5:4]==2'b01) ? 1'b1 : 1'b0), // simple mapping: LD/ST opcodes
//     .switches({opcode, rd, rs}), // using switches to pass instruction fields
//     .leds()                       // unused
// );
ld_st_module LDST (
    .clk(clk),
    .reset(rst),
    .ld_en(ld_en),
    .st_en(st_en),
    .addr(mem_addr),
    .write_data(mem_wdata),
    .read_data(mem_rdata),
    .ready(mem_ready)
);

parameter IDLE = 2'b00, RUN = 2'b01, HALT = 2'b10;
reg [1:0] state;

wire is_zero = (rs_val != 32'b0);

wire branch_taken = ((opcode == 6'b111001) && rs_val[31]) ||  // BMI
                    ((opcode == 6'b111010) && (!rs_val[31] && is_zero)) || // BPL
                    ((opcode == 6'b111011) && !is_zero);     // BZ

    assign alu_result = alu_out;

    // Core control
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 0;
            state <= RUN;
            we <= 0;
            ld_en <= 0;
            st_en <= 0;
            mem_addr <= 0;
            mem_wdata <= 0;
            wd <= 0;
        end else begin
            we <= 0;
            rd_addr <= 0;
            wd <= 0;
            // ld_en <= 0;
            // st_en <= 0;
            // mem_addr <= 0;
            // mem_wdata <= 0;
            case (state)
                RUN: begin
                    $display("Time=%0t PC=%0d R1=%0d R2=%0d OPCODE=%b", 
                            $time, PC, RB.regs[1], RB.regs[2], opcode);
                    // we <= 0;
                    // rd_addr <= 4'b0;
                    // wd <= 32'b0;
                    if (opcode == 6'b101000) begin
                        state <= HALT;
                    end else begin
                    if (opcode == 6'b000000) begin
                        case (funct)
                            // Arithmetic ops
                            6'b001000, 6'b001001, 6'b001010, 6'b001011, 
                            6'b001100, 6'b001101: begin
                                we <= 1; rd_addr <= rd; wd <= alu_out;
                            end

                            // Logic ops
                            6'b010000, 6'b010001, 6'b010010, 6'b010011, 6'b010100: begin
                                we <= 1; rd_addr <= rd; wd <= alu_out;
                            end

                            // Shift ops
                            6'b011011, 6'b011001, 6'b011010: begin
                                we <= 1; rd_addr <= rd; wd <= alu_out;
                            end

                            // Hamming or custom ops
                            6'b101000: begin
                                we <= 1; rd_addr <= rd; wd <= alu_out;
                            end

                            // MOV 
                            6'b110000: begin
                                we <= 1; rd_addr <= rs; wd <= rt_val;
                            end

                            // CMOV 
                            6'b110001: begin
                                we <= 1; rd_addr <= rs; wd <= rt_val;
                            end
                        endcase
                    end


                    // I-type arithmetic and logic
                    else if(opcode == 6'b001000 || opcode == 6'b001001 || opcode == 6'b011000 || opcode == 6'b011001 || opcode == 6'b011010 ||
                    opcode == 6'b010000 || opcode == 6'b010001 || opcode == 6'b010010 || opcode == 6'b110000) begin
                        we <= 1; rd_addr <= rt; wd <= alu_out;
                    end

                    else if(opcode == 6'b101010) begin // Load
                            mem_addr <= rs_val + {{16{imm16[15]}}, imm16};
                            ld_en <= 1;
                            // wd <= mem_rdata;
                            // rd_addr <= rt;
                            // we <= 1;
                    end else if(opcode == 6'b101011) begin // Store
                            //$display("HELLO 2.0");
                            mem_addr <= rs_val + {{16{imm16[15]}}, imm16};
                            st_en <= 1;
                            mem_wdata <= rt_val;
                    end

//                    cur_opcode = instruction[31:26];
                    next_PC = PC_plus_1;
                    
                    if (opcode == 6'b111100) next_PC = PC_branch26;
                    else if(branch_taken) next_PC = PC_branch16;
//                    else next_PC = PC_plus_1;
                    
                    PC <= next_PC; 

                    end
                end

                HALT: begin
                    PC <= PC;
                    we <= 0;
            end

            default: state <= IDLE;

            endcase
                if(mem_ready && ld_en) begin
                wd <= mem_rdata;
                rd_addr <= rt;
                we <= 1;
                ld_en <= 0; 
            end

            if(mem_ready && st_en) begin
                st_en <= 0;
            end
        end
    end

    wire [31:0] led_reg_val = RB.regs[2]; // display R2 as result
    assign leds = led_sel ? led_reg_val[31:16] : led_reg_val[15:0];

endmodule