`timescale 1ns / 1ps

module tb_lstm_top;

// Parameters
parameter DATA_WIDTH = 8;
parameter CYCLE = 10; // Clock cycle: 10ns

// Inputs
reg clk;
reg rst_n;
reg start;
reg signed [DATA_WIDTH-1:0] x[0:3];
reg signed [DATA_WIDTH-1:0] y_in[0:3];

// Outputs
wire finished;
wire signed [DATA_WIDTH-1:0] y[0:3];

// Instantiate the Unit Under Test (UUT)
lstm_top #(
    .DATA_WIDTH(DATA_WIDTH)
) uut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .x(x),
    .y_in(y_in),
    .finished(finished),
    .y_out(y)
);

// Clock generation
initial begin
    clk = 0;
    forever #(CYCLE/2) clk = ~clk;
end

// Initial Setup and Stimulus
initial begin
    // Initialize Inputs
    rst_n = 0;
    start = 0;
    x[0] = 8'b00100101;
    x[1] = 8'b00110101;
    x[2] = 8'b11110101;
    x[3] = 8'b11101011;
    y_in[0] = 8'b00000000;
    y_in[1] = 8'b00000000;
    y_in[2] = 8'b00000000;
    y_in[3] = 8'b00000000;
    // Wait for the global reset
    #(CYCLE*2);
    rst_n = 1;
    #(CYCLE*2);

    // Stimulate inputs
    start = 1;
    #(CYCLE*2);
    start = 0;
    #(CYCLE*50); // Wait for some operations to happen

    //第二次
    x[0] = 8'b00100101;
    x[1] = 8'b00110101;
    x[2] = 8'b11110101;
    x[3] = 8'b11101011;
    start = 1;
    #(CYCLE*2);
    start = 0;
    #(CYCLE*50);

    //第三次
    x[0] = 8'b00100010;
    x[1] = 8'b11100001;
    x[2] = 8'b01000101;
    x[3] = 8'b01010101;
    start = 1;
    #(CYCLE*2);
    start = 0;
    #(CYCLE*50);

    // Finish the simulation
    #(CYCLE*10);
    $finish;
end

// Display outputs for debugging
initial begin
    $monitor("Time = %t, finished = %b, y[0] = %d, y[1] = %d, y[2] = %d, y[3] = %d", $time, finished, y[0], y[1], y[2], y[3]);
end

endmodule
