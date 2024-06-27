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
reg [2:0]t;
reg [5:0]cnt;

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
    t = 4;
    cnt=0;
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
    #(CYCLE*2);
    rst_n = 1;
    #(CYCLE*2);

    // // Stimulate inputs
    // start = 1;
    // #(CYCLE*2);
    // start = 0;
    // #(CYCLE*50); // Wait for some operations to happen

    // //第二次
    // x[0] = 8'b00101101;
    // x[1] = 8'b10111100;
    // x[2] = 8'b00101001;
    // x[3] = 8'b01010111;
    // start = 1;
    // #(CYCLE*2);
    // start = 0;
    // #(CYCLE*50);

    // //第三次
    // x[0] = 8'b00100010;
    // x[1] = 8'b11100001;
    // x[2] = 8'b01000101;
    // x[3] = 8'b01010101;
    // start = 1;
    // #(CYCLE*2);
    // start = 0;
    // #(CYCLE*50);

    // Finish the simulation
    #(CYCLE*150);
    $finish;
end

//用于迭代
always @(posedge clk) begin
    if(cnt < 15)
        cnt <= cnt + 1;
    else
        cnt <= 15;
end

// 产生start信号
always @(posedge clk) begin
    if(cnt == 12 || finished == 1)  //产生start为cnt=12，即第一次，或者finished等于1，上次结束
        start <= 1;
    else
        start <= 0;
end

always @(posedge clk) begin
    if(finished == 1)   //如果四个都完成了
        t <= t - 1;
    if(t == 0)
        t <= 0;     //停止运行
end

//t-1输入给t
always @(posedge clk) begin
    if(finished == 1)
    begin
        y_in[0] <= y_out[0];
        y_in[1] <= y_out[1];
        y_in[2] <= y_out[2];
        y_in[3] <= y_out[3];
    end
    else begin
        y_in[0] <= 0;
        y_in[1] <= 0;
        y_in[2] <= 0;
        y_in[3] <= 0;
    end
end

always @(posedge clk) begin
    if(finished == 1)
    begin
        case(t)
        4:
        begin
            x[0] <= X10_IN;
            x[1] <= X11_IN;
            x[2] <= X12_IN;
            x[3] <= X13_IN;
        end
        3:
        begin
            x[0] <= X20_IN;
            x[1] <= X21_IN;
            x[2] <= X22_IN;
            x[3] <= X23_IN;
        end
        2:
        begin
            x[0] <= X30_IN;
            x[1] <= X31_IN;
            x[2] <= X32_IN;
            x[3] <= X33_IN;
        end
        1:
        begin
            x[0] <= X40_IN;
            x[1] <= X41_IN;
            x[2] <= X42_IN;
            x[3] <= X43_IN;
        end
        default:;
        endcase
    end
end



// Display outputs for debugging
initial begin
    $monitor("Time = %t, finished = %b, y_out[0] = %d, y_out[1] = %d, y_out[2] = %d, y_out[3] = %d", $time, finished, y_out[0], y_out[1], y_out[2], y_out[3]);
end

// 生成FSDB文件
initial begin
    $fsdbDumpfile("lstm_top.fsdb"); // FSDB文件名
    $fsdbDumpvars("+all");//$fsdbDumpvars(0, uut);  // 记录所有信号
    $fsdbDumpon;
end

endmodule
