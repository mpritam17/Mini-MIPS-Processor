`timescale 1ns / 1ps

module tb_top_level_module;

    // Inputs
    reg clk;
    reg reset_btn;
    reg execute_btn;
    reg [15:0] sw;
   
    // Outputs
    wire [15:0] led;
   
    
    top_level_module uut (
        .clk(clk),
        .reset_btn(reset_btn),
        .execute_btn(execute_btn),
        .sw(sw),
        .led(led)
    );
   
    // Clock
    always #5 clk = ~clk;
   
    task press_execute;
        begin
            execute_btn = 1;
            #30;
            execute_btn = 0;
            #50;
        end
    endtask
   
    task display_register;
        input [3:0] reg_addr;
        begin
            // Set destination register for display
            sw[13:10] = reg_addr;
            #20;
            $display("R%d Lower: 0x%h", reg_addr, led);
           
            sw[15] = 1'b1; // Upper bits
            #20;
            $display("R%d Upper: 0x%h", reg_addr, led);
           
            sw[15] = 1'b0; // Reset to lower bits
            #20;
        end
    endtask
   
    initial begin
        // Initialize
        clk = 0;
        reset_btn = 0;
        execute_btn = 0;
        sw = 0;
       
        #100;
        $display("=== TOP MODULE TEST - SEQUENTIAL INITIALIZATION ===");
        $display("Registers: R0=0, R1=1, R2=2... Memory: Mem[0]=0, Mem[1]=1...");
       
        // Reset system
        $display("\nStep 1: Reset system");
        reset_btn = 1;
        #50;
        reset_btn = 0;
        #50;
       
        // Display initial state
        $display("Initial registers via LEDs:");
        display_register(4'd0);
        display_register(4'd1);
        display_register(4'd2);
       
        // Test LD instruction
        $display("\nStep 2: LD R6, 3(R0) - Load from address 0+3=3 (value 3)");
        sw = 16'b0_0_0110_0000_000011;
        press_execute();
        display_register(4'd6);
       
        // Test ST instruction  
        $display("\nStep 3: ST R1, 8(R0) - Store R1 (value 1) to address 0+8=8");
        sw = 16'b0_1_0001_0000_001000;
        press_execute();
       
        // Verify store
        $display("Step 4: LD R8, 8(R0) - Verify stored value 1");
        sw = 16'b0_0_1000_0000_001000;
        press_execute();
        display_register(4'd8);
       
        $display("=== TOP MODULE TEST COMPLETE ===");
        $finish;
    end

endmodule