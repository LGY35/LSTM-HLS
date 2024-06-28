`timescale 1ns / 1ps

module tb_lstm_top;

// Parameters
parameter DATA_WIDTH = 8;
parameter REG_WIDTH = 8;
parameter CYCLE = 10; // Clock cycle: 10ns

// Inputs
reg clk;
reg rst_n;
reg start;
reg signed [DATA_WIDTH-1:0] x[0:3];
reg signed [DATA_WIDTH-1:0] y_in[0:3];

// Outputs
wire finished;
wire signed [DATA_WIDTH-1:0] y_out[0:3];

reg signed [DATA_WIDTH-1:0] X10_IN;
reg signed [DATA_WIDTH-1:0] X11_IN;
reg signed [DATA_WIDTH-1:0] X12_IN;
reg signed [DATA_WIDTH-1:0] X13_IN;
reg signed [DATA_WIDTH-1:0] X20_IN;
reg signed [DATA_WIDTH-1:0] X21_IN;
reg signed [DATA_WIDTH-1:0] X22_IN;
reg signed [DATA_WIDTH-1:0] X23_IN;
reg signed [DATA_WIDTH-1:0] X30_IN;
reg signed [DATA_WIDTH-1:0] X31_IN;
reg signed [DATA_WIDTH-1:0] X32_IN;
reg signed [DATA_WIDTH-1:0] X33_IN;
reg signed [DATA_WIDTH-1:0] X40_IN;
reg signed [DATA_WIDTH-1:0] X41_IN;
reg signed [DATA_WIDTH-1:0] X42_IN;
reg signed [DATA_WIDTH-1:0] X43_IN;

// Instantiate the Unit Under Test (UUT)
lstm_top #(
    .DATA_WIDTH(DATA_WIDTH),
    .REG_WIDTH(REG_WIDTH)
) uut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .x(x),
    .y_in(y_in),
    .finished(finished),
    .y_out(y_out)
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
    X10_IN = 8'b00101101;
    X11_IN = 8'b10111100;
    X12_IN = 8'b00101001;
    X13_IN = 8'b01010111;
    X20_IN = 8'b00100010;
    X21_IN = 8'b11100001;
    X22_IN = 8'b01000101;
    X23_IN = 8'b01010101;
    X30_IN = 8'b01110001;
    X31_IN = 8'b00011011;
    X32_IN = 8'b11011010;
    X33_IN = 8'b11000010;
    X40_IN = 8'b10110101;
    X41_IN = 8'b11110011;
    X42_IN = 8'b00101001;
    X43_IN = 8'b00011101;
    y_in[0] = 8'b00000000;
    y_in[1] = 8'b00000000;
    y_in[2] = 8'b00000000;
    y_in[3] = 8'b00000000;
    // Wait for the global reset
    repeat(2)@(posedge clk);
    rst_n = 1;
    repeat(2)@(posedge clk);

    // Stimulate inputs
    start = 1;
    repeat(2)@(posedge clk);
    start = 0;
    repeat(30)@(posedge clk) begin
        if(finished == 1) begin
            y_in[0] <= y_out[0];
            y_in[1] <= y_out[1];
            y_in[2] <= y_out[2];
            y_in[3] <= y_out[3];
        end
    end
    
    //第二次
    x[0] = 8'b00101101;
    x[1] = 8'b10111100;
    x[2] = 8'b00101001;
    x[3] = 8'b01010111;
    start = 1;
    repeat(2)@(posedge clk);
    start = 0;
    repeat(30)@(posedge clk) begin
        if(finished == 1) begin
            y_in[0] <= y_out[0];
            y_in[1] <= y_out[1];
            y_in[2] <= y_out[2];
            y_in[3] <= y_out[3];
        end
    end

    //第三次
    x[0] = 8'b00100010;
    x[1] = 8'b11100001;
    x[2] = 8'b01000101;
    x[3] = 8'b01010101;
    start = 1;
    repeat(2)@(posedge clk);
    start = 0;
    repeat(30)@(posedge clk) begin
        if(finished == 1) begin
            y_in[0] <= y_out[0];
            y_in[1] <= y_out[1];
            y_in[2] <= y_out[2];
            y_in[3] <= y_out[3];
        end
    end

    //第四次
    x[0] = 8'b01110001;
    x[1] = 8'b00011011;
    x[2] = 8'b11011010;
    x[3] = 8'b11000010;
    start = 1;
    repeat(2)@(posedge clk);
    start = 0;
    repeat(30)@(posedge clk) begin
        if(finished == 1) begin
            y_in[0] <= y_out[0];
            y_in[1] <= y_out[1];
            y_in[2] <= y_out[2];
            y_in[3] <= y_out[3];
        end
    end

    //第五次
    x[0] = 8'b10110101;
    x[1] = 8'b11110011;
    x[2] = 8'b00101001;
    x[3] = 8'b00011101;
    start = 1;
    repeat(2)@(posedge clk);
    start = 0;
    repeat(30)@(posedge clk) begin
        if(finished == 1) begin
            y_in[0] <= y_out[0];
            y_in[1] <= y_out[1];
            y_in[2] <= y_out[2];
            y_in[3] <= y_out[3];
        end
    end

    // Finish the simulation
    repeat(80)@(posedge clk);
    $finish;
end



// Display outputs for debugging
initial begin
    $monitor("Time = %t, finished = %b, y_out[0] = %b, y_out[1] = %b, y_out[2] = %b, y_out[3] = %b", $time, finished, y_out[0], y_out[1], y_out[2], y_out[3]);
end

// 生成FSDB文件
initial begin
    $fsdbDumpfile("lstm_top.fsdb"); // FSDB文件名
    $fsdbDumpvars("+all");//$fsdbDumpvars(0, uut);  // 记录所有信号
    $fsdbDumpon;
end

endmodule
