module Processor_TB();

    reg clk;
	reg reset;
    // Instantiate your Top-Level Processor
    processor uut (
        .CLK(clk));

    // Clock Generation (10ns period)
    always #5 clk = ~clk;

    // Reset Sequence
    initial begin
        clk = 0;
        reset = 1;     // Hold reset high to initialize PC to 0
        
        #10;           // Wait one clock cycle
        reset = 0;     // Release reset, processor starts fetching
        
        #1000;         // Run for 1000ns, then stop
        $finish;
    end
endmodule