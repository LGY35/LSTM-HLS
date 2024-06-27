
module lstm_top 
#(  
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire signed [DATA_WIDTH-1:0] x[0:3],
    input wire signed [DATA_WIDTH-1:0] y_in[0:3],
    output reg finished,
    output reg signed [DATA_WIDTH-1:0] y_out[0:3]
);

// x
reg signed [DATA_WIDTH-1:0] x0;
reg signed [DATA_WIDTH-1:0] x1;
reg signed [DATA_WIDTH-1:0] x2;
reg signed [DATA_WIDTH-1:0] x3;
// y_in
reg signed [DATA_WIDTH-1:0] y_in0;
reg signed [DATA_WIDTH-1:0] y_in1;
reg signed [DATA_WIDTH-1:0] y_in2;
reg signed [DATA_WIDTH-1:0] y_in3;

//与lstmi的接口，只有valid之后才传递给y_out
wire signed [DATA_WIDTH-1:0] y_t0;
wire signed [DATA_WIDTH-1:0] y_t1;
wire signed [DATA_WIDTH-1:0] y_t2;
wire signed [DATA_WIDTH-1:0] y_t3;
//valid
reg valid0;
reg valid1;
reg valid2;
reg valid3;

//-----------------------------sigmod-----------------------------
//lstm0  in out是相对于lstm unit而言
reg signed[DATA_WIDTH-1:0] sigmoid_mem [0:255];
wire [DATA_WIDTH-1:0] lstm0_sigmod_data_idx1;//连接到lstm的out，作为查找表的索引    // 不能加signed，这里是无符号数
wire [DATA_WIDTH-1:0] lstm0_sigmod_data_idx2;//连接到lstm的out，作为查找表的索引
wire [DATA_WIDTH-1:0] lstm0_sigmod_data_idx3;//连接到lstm的out，作为查找表的索引
wire lstm0_sigmod_request1;
wire lstm0_sigmod_request2;
wire lstm0_sigmod_request3;
reg signed[DATA_WIDTH-1:0] lstm0_sigmod_data_result1;//连接到lstm的in，作为查找表的结果
reg signed[DATA_WIDTH-1:0] lstm0_sigmod_data_result2;//连接到lstm的in，作为查找表的结果
reg signed[DATA_WIDTH-1:0] lstm0_sigmod_data_result3;//连接到lstm的in，作为查找表的结果
//lstm1
wire [DATA_WIDTH-1:0] lstm1_sigmod_data_idx1;
wire [DATA_WIDTH-1:0] lstm1_sigmod_data_idx2;
wire [DATA_WIDTH-1:0] lstm1_sigmod_data_idx3;
wire lstm1_sigmod_request1;
wire lstm1_sigmod_request2;
wire lstm1_sigmod_request3;
reg signed[DATA_WIDTH-1:0] lstm1_sigmod_data_result1;
reg signed[DATA_WIDTH-1:0] lstm1_sigmod_data_result2;
reg signed[DATA_WIDTH-1:0] lstm1_sigmod_data_result3;
//lstm2
wire [DATA_WIDTH-1:0] lstm2_sigmod_data_idx1;
wire [DATA_WIDTH-1:0] lstm2_sigmod_data_idx2;
wire [DATA_WIDTH-1:0] lstm2_sigmod_data_idx3;
wire lstm2_sigmod_request1;
wire lstm2_sigmod_request2;
wire lstm2_sigmod_request3;
reg signed[DATA_WIDTH-1:0] lstm2_sigmod_data_result1;
reg signed[DATA_WIDTH-1:0] lstm2_sigmod_data_result2;
reg signed[DATA_WIDTH-1:0] lstm2_sigmod_data_result3;
//lstm3
wire [DATA_WIDTH-1:0] lstm3_sigmod_data_idx1;
wire [DATA_WIDTH-1:0] lstm3_sigmod_data_idx2;
wire [DATA_WIDTH-1:0] lstm3_sigmod_data_idx3;
wire lstm3_sigmod_request1;
wire lstm3_sigmod_request2;
wire lstm3_sigmod_request3;
reg signed[DATA_WIDTH-1:0] lstm3_sigmod_data_result1;
reg signed[DATA_WIDTH-1:0] lstm3_sigmod_data_result2;
reg signed[DATA_WIDTH-1:0] lstm3_sigmod_data_result3;

//------------------------weight-----------------------------
//lstm0
wire signed [DATA_WIDTH*4-1:0] Wi0;  
wire signed [DATA_WIDTH*4-1:0] Wz0;  
wire signed [DATA_WIDTH*4-1:0] Wf0;  
wire signed [DATA_WIDTH*4-1:0] Wo0;  
wire signed [DATA_WIDTH*4-1:0] Ri0;  
wire signed [DATA_WIDTH*4-1:0] Rz0;  
wire signed [DATA_WIDTH*4-1:0] Rf0; 
wire signed [DATA_WIDTH*4-1:0] Ro0;  
wire signed [DATA_WIDTH*3-1:0] p0; 
//lstm1
wire signed [DATA_WIDTH*4-1:0] Wi1;  
wire signed [DATA_WIDTH*4-1:0] Wz1;  
wire signed [DATA_WIDTH*4-1:0] Wf1;  
wire signed [DATA_WIDTH*4-1:0] Wo1;  
wire signed [DATA_WIDTH*4-1:0] Ri1;  
wire signed [DATA_WIDTH*4-1:0] Rz1;  
wire signed [DATA_WIDTH*4-1:0] Rf1; 
wire signed [DATA_WIDTH*4-1:0] Ro1;  
wire signed [DATA_WIDTH*3-1:0] p1;
//lstm2
wire signed [DATA_WIDTH*4-1:0] Wi2;  
wire signed [DATA_WIDTH*4-1:0] Wz2;  
wire signed [DATA_WIDTH*4-1:0] Wf2;  
wire signed [DATA_WIDTH*4-1:0] Wo2;  
wire signed [DATA_WIDTH*4-1:0] Ri2;  
wire signed [DATA_WIDTH*4-1:0] Rz2;  
wire signed [DATA_WIDTH*4-1:0] Rf2; 
wire signed [DATA_WIDTH*4-1:0] Ro2;  
wire signed [DATA_WIDTH*3-1:0] p2;  
//lstm3
wire signed [DATA_WIDTH*4-1:0] Wi3;  
wire signed [DATA_WIDTH*4-1:0] Wz3;  
wire signed [DATA_WIDTH*4-1:0] Wf3;  
wire signed [DATA_WIDTH*4-1:0] Wo3;  
wire signed [DATA_WIDTH*4-1:0] Ri3;  
wire signed [DATA_WIDTH*4-1:0] Rz3;  
wire signed [DATA_WIDTH*4-1:0] Rf3; 
wire signed [DATA_WIDTH*4-1:0] Ro3;  
wire signed [DATA_WIDTH*3-1:0] p3; 

//例化：
lstm lstm0(clk,rst_n,start,x0,x1,x2,x3,y_in0,y_in1,y_in2,y_in3,Wi0,Wz0,Wf0,Wo0,Ri0,Rz0,Rf0,Ro0,p0,lstm0_sigmod_data_result1,lstm0_sigmod_data_result2,lstm0_sigmod_data_result3,lstm0_sigmod_request1,lstm0_sigmod_request2,lstm0_sigmod_request3,lstm0_sigmod_data_idx1,lstm0_sigmod_data_idx2,lstm0_sigmod_data_idx3,valid0,y_t0);
lstm lstm1(clk,rst_n,start,x0,x1,x2,x3,y_in0,y_in1,y_in2,y_in3,Wi1,Wz1,Wf1,Wo1,Ri1,Rz1,Rf1,Ro1,p1,lstm1_sigmod_data_result1,lstm1_sigmod_data_result2,lstm1_sigmod_data_result3,lstm1_sigmod_request1,lstm1_sigmod_request2,lstm1_sigmod_request3,lstm1_sigmod_data_idx1,lstm1_sigmod_data_idx2,lstm1_sigmod_data_idx3,valid1,y_t1);
lstm lstm2(clk,rst_n,start,x0,x1,x2,x3,y_in0,y_in1,y_in2,y_in3,Wi2,Wz2,Wf2,Wo2,Ri2,Rz2,Rf2,Ro2,p2,lstm2_sigmod_data_result1,lstm2_sigmod_data_result2,lstm2_sigmod_data_result3,lstm2_sigmod_request1,lstm2_sigmod_request2,lstm2_sigmod_request3,lstm2_sigmod_data_idx1,lstm2_sigmod_data_idx2,lstm2_sigmod_data_idx3,valid2,y_t2);
lstm lstm3(clk,rst_n,start,x0,x1,x2,x3,y_in0,y_in1,y_in2,y_in3,Wi3,Wz3,Wf3,Wo3,Ri3,Rz3,Rf3,Ro3,p3,lstm3_sigmod_data_result1,lstm3_sigmod_data_result2,lstm3_sigmod_data_result3,lstm3_sigmod_request1,lstm3_sigmod_request2,lstm3_sigmod_request3,lstm3_sigmod_data_idx1,lstm3_sigmod_data_idx2,lstm3_sigmod_data_idx3,valid3,y_t3);


//输入与输出的端口对应
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 0) begin
        x0 <= x[0];
        x1 <= x[1];
        x2 <= x[2];
        x3 <= x[3];
        y_in0 <= y_in[0];
        y_in1 <= y_in[1];
        y_in2 <= y_in[2];
        y_in3 <= y_in[3];
    end
    else begin
        x0 <= x[0];
        x1 <= x[1];
        x2 <= x[2];
        x3 <= x[3];
        y_in0 <= y_in[0];
        y_in1 <= y_in[1];
        y_in2 <= y_in[2];
        y_in3 <= y_in[3];
    end
end

//完成信号
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 0) 
        finished <= 0;  
    else if(valid0 == 1 && valid1 == 1 && valid2 == 1 && valid3 == 1)
        finished <= 1; 
    else
        finished <= 0; 
end

//输出y
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 0) begin
        y_out[0] <= 0;
        y_out[1] <= 0;
        y_out[2] <= 0;
        y_out[3] <= 0;
    end  
    else begin
        if(valid0 == 1)
            y_out[0] <= y_t0;
        else
            y_out[0] <= 0;
        if(valid1 == 1)
            y_out[1] <= y_t1;
        else
            y_out[1] <= 0;
        if(valid2 == 1)
            y_out[2] <= y_t2;
        else
            y_out[2] <= 0;
        if(valid3 == 1)
            y_out[3] <= y_t3;
        else
            y_out[3] <= 0;
    end
end

//*********************************sigmod查找*******************************
//从lstm单元中传出来的是带符号的8bit，比如-128，对应的无符号8bit就是128，就是，如果得到的负数最大，就是-128，对应的数也是最小的，即sigmod[128]的数
//lstm0-sigmod1
always @(*) begin
    if(lstm0_sigmod_request1 == 1) begin
        lstm0_sigmod_data_result1 = sigmoid_mem[lstm0_sigmod_data_idx1];
    end
    else begin
        lstm0_sigmod_data_result1 = 0;
    end
end

//lstm0-sigmod2
always @(*) begin
    if(lstm0_sigmod_request2 == 1) begin
        lstm0_sigmod_data_result2 = sigmoid_mem[lstm0_sigmod_data_idx2];
    end
    else begin
        lstm0_sigmod_data_result2 = 0;
    end
end

//lstm0-sigmod3
always @(*) begin
    if(lstm0_sigmod_request3 == 1) begin
        lstm0_sigmod_data_result3 = sigmoid_mem[lstm0_sigmod_data_idx3];
    end
    else begin
        lstm0_sigmod_data_result3 = 0;
    end
end

//lstm1-sigmod1
always @(*) begin
    if(lstm1_sigmod_request1 == 1) begin
        lstm1_sigmod_data_result1 = sigmoid_mem[lstm1_sigmod_data_idx1];
    end
    else begin
        lstm1_sigmod_data_result1 = 0;
    end
end

//lstm1-sigmod2
always @(*) begin
    if(lstm1_sigmod_request2 == 1) begin
        lstm1_sigmod_data_result2 = sigmoid_mem[lstm1_sigmod_data_idx2];
    end
    else begin
        lstm1_sigmod_data_result2 = 0;
    end
end

//lstm1-sigmod3
always @(*) begin
    if(lstm1_sigmod_request3 == 1) begin
        lstm1_sigmod_data_result3 = sigmoid_mem[lstm1_sigmod_data_idx3];
    end
    else begin
        lstm1_sigmod_data_result3 = 0;
    end
end

//lstm2-sigmod1
always @(*) begin
    if(lstm2_sigmod_request1 == 1) begin
        lstm2_sigmod_data_result1 = sigmoid_mem[lstm2_sigmod_data_idx1];
    end
    else begin
        lstm2_sigmod_data_result1 = 0;
    end
end

//lstm2-sigmod2
always @(*) begin
    if(lstm2_sigmod_request2 == 1) begin
        lstm2_sigmod_data_result2 = sigmoid_mem[lstm2_sigmod_data_idx2];
    end
    else begin
        lstm2_sigmod_data_result2 = 0;
    end
end

//lstm2-sigmod3
always @(*) begin
    if(lstm2_sigmod_request3 == 1) begin
        lstm2_sigmod_data_result3 = sigmoid_mem[lstm2_sigmod_data_idx3];
    end
    else begin
        lstm2_sigmod_data_result3 = 0;
    end
end

//lstm3-sigmod1
always @(*) begin
    if(lstm3_sigmod_request1 == 1) begin
        lstm3_sigmod_data_result1 = sigmoid_mem[lstm3_sigmod_data_idx1];
    end
    else begin
        lstm3_sigmod_data_result1 = 0;
    end
end

//lstm3-sigmod2
always @(*) begin
    if(lstm3_sigmod_request2 == 1) begin
        lstm3_sigmod_data_result2 = sigmoid_mem[lstm3_sigmod_data_idx2];
    end
    else begin
        lstm3_sigmod_data_result2 = 0;
    end
end

//lstm3-sigmod3
always @(*) begin
    if(lstm3_sigmod_request3 == 1) begin
        lstm3_sigmod_data_result3 = sigmoid_mem[lstm3_sigmod_data_idx3];
    end
    else begin
        lstm3_sigmod_data_result3 = 0;
    end
end


/****************************************************
sigmod查找表
输入只考虑(-2,2)的范围，将这部分的值转换为256之间的映射。
输出的值为正数 0-1
输入的值为0-255，其中 0-127为正数输入，128-255为负数输入
******************************************************/
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 0) begin
        //0-127为 (0,2) 的范围，横坐标为正数的半段，纵坐标为(0.5,1)
        sigmoid_mem[0]   <= 8'b01000000;    //64 / 128 = 0.5
        sigmoid_mem[1]   <= 8'b01000000;
        sigmoid_mem[2]   <= 8'b01000000;
        sigmoid_mem[3]   <= 8'b01000001;
        sigmoid_mem[4]   <= 8'b01000001;
        sigmoid_mem[5]   <= 8'b01000010;
        sigmoid_mem[6]   <= 8'b01000010;
        sigmoid_mem[7]   <= 8'b01000011;
        sigmoid_mem[8]   <= 8'b01000011;
        sigmoid_mem[9]   <= 8'b01000100;
        sigmoid_mem[10]  <= 8'b01000100;
        sigmoid_mem[11]  <= 8'b01000101;
        sigmoid_mem[12]  <= 8'b01000101;
        sigmoid_mem[13]  <= 8'b01000110;
        sigmoid_mem[14]  <= 8'b01000110;
        sigmoid_mem[15]  <= 8'b01000111;
        sigmoid_mem[16]  <= 8'b01000111;
        sigmoid_mem[17]  <= 8'b01001000;
        sigmoid_mem[18]  <= 8'b01001000;
        sigmoid_mem[19]  <= 8'b01001001;
        sigmoid_mem[20]  <= 8'b01001001;
        sigmoid_mem[21]  <= 8'b01001010;
        sigmoid_mem[22]  <= 8'b01001010;
        sigmoid_mem[23]  <= 8'b01001011;
        sigmoid_mem[24]  <= 8'b01001011;
        sigmoid_mem[25]  <= 8'b01001100;
        sigmoid_mem[26]  <= 8'b01001100;
        sigmoid_mem[27]  <= 8'b01001101;
        sigmoid_mem[28]  <= 8'b01001101;
        sigmoid_mem[29]  <= 8'b01001110;
        sigmoid_mem[30]  <= 8'b01001110;
        sigmoid_mem[31]  <= 8'b01001111;
        sigmoid_mem[32]  <= 8'b01001111;
        sigmoid_mem[33]  <= 8'b01010000;
        sigmoid_mem[34]  <= 8'b01010000;
        sigmoid_mem[35]  <= 8'b01010001;
        sigmoid_mem[36]  <= 8'b01010001;
        sigmoid_mem[37]  <= 8'b01010010;
        sigmoid_mem[38]  <= 8'b01010010;
        sigmoid_mem[39]  <= 8'b01010010;
        sigmoid_mem[40]  <= 8'b01010011;
        sigmoid_mem[41]  <= 8'b01010011;
        sigmoid_mem[42]  <= 8'b01010100;
        sigmoid_mem[43]  <= 8'b01010100;
        sigmoid_mem[44]  <= 8'b01010101;
        sigmoid_mem[45]  <= 8'b01010101;
        sigmoid_mem[46]  <= 8'b01010110;
        sigmoid_mem[47]  <= 8'b01010110;
        sigmoid_mem[48]  <= 8'b01010110;
        sigmoid_mem[49]  <= 8'b01010111;
        sigmoid_mem[50]  <= 8'b01010111;
        sigmoid_mem[51]  <= 8'b01011000;
        sigmoid_mem[52]  <= 8'b01011000;
        sigmoid_mem[53]  <= 8'b01011001;
        sigmoid_mem[54]  <= 8'b01011001;
        sigmoid_mem[55]  <= 8'b01011001;
        sigmoid_mem[56]  <= 8'b01011010;
        sigmoid_mem[57]  <= 8'b01011010;
        sigmoid_mem[58]  <= 8'b01011011;
        sigmoid_mem[59]  <= 8'b01011011;
        sigmoid_mem[60]  <= 8'b01011011;
        sigmoid_mem[61]  <= 8'b01011100;
        sigmoid_mem[62]  <= 8'b01011100;
        sigmoid_mem[63]  <= 8'b01011101;
        sigmoid_mem[64]  <= 8'b01011101;
        sigmoid_mem[65]  <= 8'b01011101;
        sigmoid_mem[66]  <= 8'b01011110;
        sigmoid_mem[67]  <= 8'b01011110;
        sigmoid_mem[68]  <= 8'b01011111;
        sigmoid_mem[69]  <= 8'b01011111;
        sigmoid_mem[70]  <= 8'b01011111;
        sigmoid_mem[71]  <= 8'b01100000;
        sigmoid_mem[72]  <= 8'b01100000;
        sigmoid_mem[73]  <= 8'b01100000;
        sigmoid_mem[74]  <= 8'b01100001;
        sigmoid_mem[75]  <= 8'b01100001;
        sigmoid_mem[76]  <= 8'b01100010;
        sigmoid_mem[77]  <= 8'b01100010;
        sigmoid_mem[78]  <= 8'b01100010;
        sigmoid_mem[79]  <= 8'b01100011;
        sigmoid_mem[80]  <= 8'b01100011;
        sigmoid_mem[81]  <= 8'b01100011;
        sigmoid_mem[82]  <= 8'b01100100;
        sigmoid_mem[83]  <= 8'b01100100;
        sigmoid_mem[84]  <= 8'b01100100;
        sigmoid_mem[85]  <= 8'b01100101;
        sigmoid_mem[86]  <= 8'b01100101;
        sigmoid_mem[87]  <= 8'b01100101;
        sigmoid_mem[88]  <= 8'b01100110;
        sigmoid_mem[89]  <= 8'b01100110;
        sigmoid_mem[90]  <= 8'b01100110;
        sigmoid_mem[91]  <= 8'b01100111;
        sigmoid_mem[92]  <= 8'b01100111;
        sigmoid_mem[93]  <= 8'b01100111;
        sigmoid_mem[94]  <= 8'b01101000;
        sigmoid_mem[95]  <= 8'b01101000;
        sigmoid_mem[96]  <= 8'b01101000;
        sigmoid_mem[97]  <= 8'b01101000;
        sigmoid_mem[98]  <= 8'b01101001;
        sigmoid_mem[99]  <= 8'b01101001;
        sigmoid_mem[100] <= 8'b01101001;
        sigmoid_mem[101] <= 8'b01101010;
        sigmoid_mem[102] <= 8'b01101010;
        sigmoid_mem[103] <= 8'b01101010;
        sigmoid_mem[104] <= 8'b01101010;
        sigmoid_mem[105] <= 8'b01101011;
        sigmoid_mem[106] <= 8'b01101011;
        sigmoid_mem[107] <= 8'b01101011;
        sigmoid_mem[108] <= 8'b01101100;
        sigmoid_mem[109] <= 8'b01101100;
        sigmoid_mem[110] <= 8'b01101100;
        sigmoid_mem[111] <= 8'b01101100;
        sigmoid_mem[112] <= 8'b01101101;
        sigmoid_mem[113] <= 8'b01101101;
        sigmoid_mem[114] <= 8'b01101101;
        sigmoid_mem[115] <= 8'b01101101;
        sigmoid_mem[116] <= 8'b01101110;
        sigmoid_mem[117] <= 8'b01101110;
        sigmoid_mem[118] <= 8'b01101110;
        sigmoid_mem[119] <= 8'b01101110;
        sigmoid_mem[120] <= 8'b01101110;
        sigmoid_mem[121] <= 8'b01101111;
        sigmoid_mem[122] <= 8'b01101111;
        sigmoid_mem[123] <= 8'b01101111;
        sigmoid_mem[124] <= 8'b01101111;
        sigmoid_mem[125] <= 8'b01110000;
        sigmoid_mem[126] <= 8'b01110000;
        sigmoid_mem[127] <= 8'b01110000;    //112 / 128 = 0.875
        //128-255为 (-2,0) 的范围，横坐标为负数的半段，纵坐标为(0,0.5)
        sigmoid_mem[128] <= 8'b00001111;    //15 / 128 = 0.1171875
        sigmoid_mem[129] <= 8'b00001111;
        sigmoid_mem[130] <= 8'b00001111;
        sigmoid_mem[131] <= 8'b00001111;
        sigmoid_mem[132] <= 8'b00010000;
        sigmoid_mem[133] <= 8'b00010000;
        sigmoid_mem[134] <= 8'b00010000;
        sigmoid_mem[135] <= 8'b00010000;
        sigmoid_mem[136] <= 8'b00010001;
        sigmoid_mem[137] <= 8'b00010001;
        sigmoid_mem[138] <= 8'b00010001;
        sigmoid_mem[139] <= 8'b00010001;
        sigmoid_mem[140] <= 8'b00010001;
        sigmoid_mem[141] <= 8'b00010010;
        sigmoid_mem[142] <= 8'b00010010;
        sigmoid_mem[143] <= 8'b00010010;
        sigmoid_mem[144] <= 8'b00010010;
        sigmoid_mem[145] <= 8'b00010011;
        sigmoid_mem[146] <= 8'b00010011;
        sigmoid_mem[147] <= 8'b00010011;
        sigmoid_mem[148] <= 8'b00010011;
        sigmoid_mem[149] <= 8'b00010100;
        sigmoid_mem[150] <= 8'b00010100;
        sigmoid_mem[151] <= 8'b00010100;
        sigmoid_mem[152] <= 8'b00010101;
        sigmoid_mem[153] <= 8'b00010101;
        sigmoid_mem[154] <= 8'b00010101;
        sigmoid_mem[155] <= 8'b00010101;
        sigmoid_mem[156] <= 8'b00010110;
        sigmoid_mem[157] <= 8'b00010110;
        sigmoid_mem[158] <= 8'b00010110;
        sigmoid_mem[159] <= 8'b00010111;
        sigmoid_mem[160] <= 8'b00010111;
        sigmoid_mem[161] <= 8'b00010111;
        sigmoid_mem[162] <= 8'b00010111;
        sigmoid_mem[163] <= 8'b00011000;
        sigmoid_mem[164] <= 8'b00011000;
        sigmoid_mem[165] <= 8'b00011000;
        sigmoid_mem[166] <= 8'b00011001;
        sigmoid_mem[167] <= 8'b00011001;
        sigmoid_mem[168] <= 8'b00011001;
        sigmoid_mem[169] <= 8'b00011010;
        sigmoid_mem[170] <= 8'b00011010;
        sigmoid_mem[171] <= 8'b00011010;
        sigmoid_mem[172] <= 8'b00011011;
        sigmoid_mem[173] <= 8'b00011011;
        sigmoid_mem[174] <= 8'b00011011;
        sigmoid_mem[175] <= 8'b00011100;
        sigmoid_mem[176] <= 8'b00011100;
        sigmoid_mem[177] <= 8'b00011100;
        sigmoid_mem[178] <= 8'b00011101;
        sigmoid_mem[179] <= 8'b00011101;
        sigmoid_mem[180] <= 8'b00011101;
        sigmoid_mem[181] <= 8'b00011110;
        sigmoid_mem[182] <= 8'b00011110;
        sigmoid_mem[183] <= 8'b00011111;
        sigmoid_mem[184] <= 8'b00011111;
        sigmoid_mem[185] <= 8'b00011111;
        sigmoid_mem[186] <= 8'b00100000;
        sigmoid_mem[187] <= 8'b00100000;
        sigmoid_mem[188] <= 8'b00100000;
        sigmoid_mem[189] <= 8'b00100001;
        sigmoid_mem[190] <= 8'b00100001;
        sigmoid_mem[191] <= 8'b00100010;
        sigmoid_mem[192] <= 8'b00100010;
        sigmoid_mem[193] <= 8'b00100010;
        sigmoid_mem[194] <= 8'b00100011;
        sigmoid_mem[195] <= 8'b00100011;
        sigmoid_mem[196] <= 8'b00100100;
        sigmoid_mem[197] <= 8'b00100100;
        sigmoid_mem[198] <= 8'b00100100;
        sigmoid_mem[199] <= 8'b00100101;
        sigmoid_mem[200] <= 8'b00100101;
        sigmoid_mem[201] <= 8'b00100110;
        sigmoid_mem[202] <= 8'b00100110;
        sigmoid_mem[203] <= 8'b00100110;
        sigmoid_mem[204] <= 8'b00100111;
        sigmoid_mem[205] <= 8'b00100111;
        sigmoid_mem[206] <= 8'b00101000;
        sigmoid_mem[207] <= 8'b00101000;
        sigmoid_mem[208] <= 8'b00101001;
        sigmoid_mem[209] <= 8'b00101001;
        sigmoid_mem[210] <= 8'b00101001;
        sigmoid_mem[211] <= 8'b00101010;
        sigmoid_mem[212] <= 8'b00101010;
        sigmoid_mem[213] <= 8'b00101011;
        sigmoid_mem[214] <= 8'b00101011;
        sigmoid_mem[215] <= 8'b00101100;
        sigmoid_mem[216] <= 8'b00101100;
        sigmoid_mem[217] <= 8'b00101101;
        sigmoid_mem[218] <= 8'b00101101;
        sigmoid_mem[219] <= 8'b00101101;
        sigmoid_mem[220] <= 8'b00101110;
        sigmoid_mem[221] <= 8'b00101110;
        sigmoid_mem[222] <= 8'b00101111;
        sigmoid_mem[223] <= 8'b00101111;
        sigmoid_mem[224] <= 8'b00110000;
        sigmoid_mem[225] <= 8'b00110000;
        sigmoid_mem[226] <= 8'b00110001;
        sigmoid_mem[227] <= 8'b00110001;
        sigmoid_mem[228] <= 8'b00110010;
        sigmoid_mem[229] <= 8'b00110010;
        sigmoid_mem[230] <= 8'b00110011;
        sigmoid_mem[231] <= 8'b00110011;
        sigmoid_mem[232] <= 8'b00110100;
        sigmoid_mem[233] <= 8'b00110100;
        sigmoid_mem[234] <= 8'b00110101;
        sigmoid_mem[235] <= 8'b00110101;
        sigmoid_mem[236] <= 8'b00110110;
        sigmoid_mem[237] <= 8'b00110110;
        sigmoid_mem[238] <= 8'b00110111;
        sigmoid_mem[239] <= 8'b00110111;
        sigmoid_mem[240] <= 8'b00111000;
        sigmoid_mem[241] <= 8'b00111000;
        sigmoid_mem[242] <= 8'b00111001;
        sigmoid_mem[243] <= 8'b00111001;
        sigmoid_mem[244] <= 8'b00111010;
        sigmoid_mem[245] <= 8'b00111010;
        sigmoid_mem[246] <= 8'b00111011;
        sigmoid_mem[247] <= 8'b00111011;
        sigmoid_mem[248] <= 8'b00111100;
        sigmoid_mem[249] <= 8'b00111100;
        sigmoid_mem[250] <= 8'b00111101;
        sigmoid_mem[251] <= 8'b00111101;
        sigmoid_mem[252] <= 8'b00111110;
        sigmoid_mem[253] <= 8'b00111110;
        sigmoid_mem[254] <= 8'b00111111;
        sigmoid_mem[255] <= 8'b00111111;    //63 / 128 = 0.4921875
    end
end

reg signed [DATA_WIDTH-1:0] Wi00;
reg signed [DATA_WIDTH-1:0] Wi01;
reg signed [DATA_WIDTH-1:0] Wi02;
reg signed [DATA_WIDTH-1:0] Wi03;
reg signed [DATA_WIDTH-1:0] Wi10;
reg signed [DATA_WIDTH-1:0] Wi11;
reg signed [DATA_WIDTH-1:0] Wi12;
reg signed [DATA_WIDTH-1:0] Wi13;
reg signed [DATA_WIDTH-1:0] Wi20;
reg signed [DATA_WIDTH-1:0] Wi21;
reg signed [DATA_WIDTH-1:0] Wi22;
reg signed [DATA_WIDTH-1:0] Wi23;
reg signed [DATA_WIDTH-1:0] Wi30;
reg signed [DATA_WIDTH-1:0] Wi31;
reg signed [DATA_WIDTH-1:0] Wi32;
reg signed [DATA_WIDTH-1:0] Wi33;
reg signed [DATA_WIDTH-1:0] Wz00;
reg signed [DATA_WIDTH-1:0] Wz01;
reg signed [DATA_WIDTH-1:0] Wz02;
reg signed [DATA_WIDTH-1:0] Wz03;
reg signed [DATA_WIDTH-1:0] Wz10;
reg signed [DATA_WIDTH-1:0] Wz11;
reg signed [DATA_WIDTH-1:0] Wz12;
reg signed [DATA_WIDTH-1:0] Wz13;
reg signed [DATA_WIDTH-1:0] Wz20;
reg signed [DATA_WIDTH-1:0] Wz21;
reg signed [DATA_WIDTH-1:0] Wz22;
reg signed [DATA_WIDTH-1:0] Wz23;
reg signed [DATA_WIDTH-1:0] Wz30;
reg signed [DATA_WIDTH-1:0] Wz31;
reg signed [DATA_WIDTH-1:0] Wz32;
reg signed [DATA_WIDTH-1:0] Wz33;
reg signed [DATA_WIDTH-1:0] Wf00;
reg signed [DATA_WIDTH-1:0] Wf01;
reg signed [DATA_WIDTH-1:0] Wf02;
reg signed [DATA_WIDTH-1:0] Wf03;
reg signed [DATA_WIDTH-1:0] Wf10;
reg signed [DATA_WIDTH-1:0] Wf11;
reg signed [DATA_WIDTH-1:0] Wf12;
reg signed [DATA_WIDTH-1:0] Wf13;
reg signed [DATA_WIDTH-1:0] Wf20;
reg signed [DATA_WIDTH-1:0] Wf21;
reg signed [DATA_WIDTH-1:0] Wf22;
reg signed [DATA_WIDTH-1:0] Wf23;
reg signed [DATA_WIDTH-1:0] Wf30;
reg signed [DATA_WIDTH-1:0] Wf31;
reg signed [DATA_WIDTH-1:0] Wf32;
reg signed [DATA_WIDTH-1:0] Wf33;
reg signed [DATA_WIDTH-1:0] Wo00;
reg signed [DATA_WIDTH-1:0] Wo01;
reg signed [DATA_WIDTH-1:0] Wo02;
reg signed [DATA_WIDTH-1:0] Wo03;
reg signed [DATA_WIDTH-1:0] Wo10;
reg signed [DATA_WIDTH-1:0] Wo11;
reg signed [DATA_WIDTH-1:0] Wo12;
reg signed [DATA_WIDTH-1:0] Wo13;
reg signed [DATA_WIDTH-1:0] Wo20;
reg signed [DATA_WIDTH-1:0] Wo21;
reg signed [DATA_WIDTH-1:0] Wo22;
reg signed [DATA_WIDTH-1:0] Wo23;
reg signed [DATA_WIDTH-1:0] Wo30;
reg signed [DATA_WIDTH-1:0] Wo31;
reg signed [DATA_WIDTH-1:0] Wo32;
reg signed [DATA_WIDTH-1:0] Wo33;
reg signed [DATA_WIDTH-1:0] Ri00;
reg signed [DATA_WIDTH-1:0] Ri01;
reg signed [DATA_WIDTH-1:0] Ri02;
reg signed [DATA_WIDTH-1:0] Ri03;
reg signed [DATA_WIDTH-1:0] Ri10;
reg signed [DATA_WIDTH-1:0] Ri11;
reg signed [DATA_WIDTH-1:0] Ri12;
reg signed [DATA_WIDTH-1:0] Ri13;
reg signed [DATA_WIDTH-1:0] Ri20;
reg signed [DATA_WIDTH-1:0] Ri21;
reg signed [DATA_WIDTH-1:0] Ri22;
reg signed [DATA_WIDTH-1:0] Ri23;
reg signed [DATA_WIDTH-1:0] Ri30;
reg signed [DATA_WIDTH-1:0] Ri31;
reg signed [DATA_WIDTH-1:0] Ri32;
reg signed [DATA_WIDTH-1:0] Ri33;
reg signed [DATA_WIDTH-1:0] Rz00;
reg signed [DATA_WIDTH-1:0] Rz01;
reg signed [DATA_WIDTH-1:0] Rz02;
reg signed [DATA_WIDTH-1:0] Rz03;
reg signed [DATA_WIDTH-1:0] Rz10;
reg signed [DATA_WIDTH-1:0] Rz11;
reg signed [DATA_WIDTH-1:0] Rz12;
reg signed [DATA_WIDTH-1:0] Rz13;
reg signed [DATA_WIDTH-1:0] Rz20;
reg signed [DATA_WIDTH-1:0] Rz21;
reg signed [DATA_WIDTH-1:0] Rz22;
reg signed [DATA_WIDTH-1:0] Rz23;
reg signed [DATA_WIDTH-1:0] Rz30;
reg signed [DATA_WIDTH-1:0] Rz31;
reg signed [DATA_WIDTH-1:0] Rz32;
reg signed [DATA_WIDTH-1:0] Rz33;
reg signed [DATA_WIDTH-1:0] Rf00;
reg signed [DATA_WIDTH-1:0] Rf01;
reg signed [DATA_WIDTH-1:0] Rf02;
reg signed [DATA_WIDTH-1:0] Rf03;
reg signed [DATA_WIDTH-1:0] Rf10;
reg signed [DATA_WIDTH-1:0] Rf11;
reg signed [DATA_WIDTH-1:0] Rf12;
reg signed [DATA_WIDTH-1:0] Rf13;
reg signed [DATA_WIDTH-1:0] Rf20;
reg signed [DATA_WIDTH-1:0] Rf21;
reg signed [DATA_WIDTH-1:0] Rf22;
reg signed [DATA_WIDTH-1:0] Rf23;
reg signed [DATA_WIDTH-1:0] Rf30;
reg signed [DATA_WIDTH-1:0] Rf31;
reg signed [DATA_WIDTH-1:0] Rf32;
reg signed [DATA_WIDTH-1:0] Rf33;
reg signed [DATA_WIDTH-1:0] Ro00;
reg signed [DATA_WIDTH-1:0] Ro01;
reg signed [DATA_WIDTH-1:0] Ro02;
reg signed [DATA_WIDTH-1:0] Ro03;
reg signed [DATA_WIDTH-1:0] Ro10;
reg signed [DATA_WIDTH-1:0] Ro11;
reg signed [DATA_WIDTH-1:0] Ro12;
reg signed [DATA_WIDTH-1:0] Ro13;
reg signed [DATA_WIDTH-1:0] Ro20;
reg signed [DATA_WIDTH-1:0] Ro21;
reg signed [DATA_WIDTH-1:0] Ro22;
reg signed [DATA_WIDTH-1:0] Ro23;
reg signed [DATA_WIDTH-1:0] Ro30;
reg signed [DATA_WIDTH-1:0] Ro31;
reg signed [DATA_WIDTH-1:0] Ro32;
reg signed [DATA_WIDTH-1:0] Ro33;
reg signed [DATA_WIDTH-1:0] pi0;
reg signed [DATA_WIDTH-1:0] pf0;
reg signed [DATA_WIDTH-1:0] po0;
reg signed [DATA_WIDTH-1:0] pi1;
reg signed [DATA_WIDTH-1:0] pf1;
reg signed [DATA_WIDTH-1:0] po1;
reg signed [DATA_WIDTH-1:0] pi2;
reg signed [DATA_WIDTH-1:0] pf2;
reg signed [DATA_WIDTH-1:0] po2;
reg signed [DATA_WIDTH-1:0] pi3;
reg signed [DATA_WIDTH-1:0] pf3;
reg signed [DATA_WIDTH-1:0] po3;

assign Wi0 = {Wi03, Wi02, Wi01, Wi00};
assign Wz0 = {Wz03, Wz02, Wz01, Wz00};
assign Wf0 = {Wf03, Wf02, Wf01, Wf00};
assign Wo0 = {Wo03, Wo02, Wo01, Wo00};
assign Wi1 = {Wi13, Wi12, Wi11, Wi10};
assign Wz1 = {Wz13, Wz12, Wz11, Wz10};
assign Wf1 = {Wf13, Wf12, Wf11, Wf10};
assign Wo1 = {Wo13, Wo12, Wo11, Wo10};
assign Wi2 = {Wi23, Wi22, Wi21, Wi20};
assign Wz2 = {Wz23, Wz22, Wz21, Wz20};
assign Wf2 = {Wf23, Wf22, Wf21, Wf20};
assign Wo2 = {Wo23, Wo22, Wo21, Wo20};
assign Wi3 = {Wi33, Wi32, Wi31, Wi30};
assign Wz3 = {Wz33, Wz32, Wz31, Wz30};
assign Wf3 = {Wf33, Wf32, Wf31, Wf30};
assign Wo3 = {Wo33, Wo32, Wo31, Wo30};

assign Ri0 = {Ri03, Ri02, Ri01, Ri00};
assign Rz0 = {Rz03, Rz02, Rz01, Rz00};
assign Rf0 = {Rf03, Rf02, Rf01, Rf00};
assign Ro0 = {Ro03, Ro02, Ro01, Ro00};
assign Ri1 = {Ri13, Ri12, Ri11, Ri10};
assign Rz1 = {Rz13, Rz12, Rz11, Rz10};
assign Rf1 = {Rf13, Rf12, Rf11, Rf10};
assign Ro1 = {Ro13, Ro12, Ro11, Ro10};
assign Ri2 = {Ri23, Ri22, Ri21, Ri20};
assign Rz2 = {Rz23, Rz22, Rz21, Rz20};
assign Rf2 = {Rf23, Rf22, Rf21, Rf20};
assign Ro2 = {Ro23, Ro22, Ro21, Ro20};
assign Ri3 = {Ri33, Ri32, Ri31, Ri30};
assign Rz3 = {Rz33, Rz32, Rz31, Rz30};
assign Rf3 = {Rf33, Rf32, Rf31, Rf30};
assign Ro3 = {Ro33, Ro32, Ro31, Ro30};

assign p0 = {po0, pf0, pi0};
assign p1 = {po1, pf1, pi1};
assign p2 = {po2, pf2, pi2};
assign p3 = {po3, pf3, pi3};


//权重赋值
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 0) begin
        //Wi0
        Wi00 <= 8'b10111000;
        Wi01 <= 8'b11101000;
        Wi02 <= 8'b00100000;
        Wi03 <= 8'b10110001;
        //Wi1
        Wi10 <= 8'b10011011;
        Wi11 <= 8'b11110011;
        Wi12 <= 8'b01000101;
        Wi13 <= 8'b10100100;
        //Wi2
        Wi20 <= 8'b10011100;
        Wi21 <= 8'b11011110;
        Wi22 <= 8'b01101110;
        Wi23 <= 8'b00110010;
        //Wi3
        Wi30 <= 8'b10010000;
        Wi31 <= 8'b01000011;
        Wi32 <= 8'b01111001;
        Wi33 <= 8'b10011000;
        //Wz0
        Wz00 <= 8'b00010101;
        Wz01 <= 8'b11010001;
        Wz02 <= 8'b11111011;
        Wz03 <= 8'b00001011;
        //Wz1
        Wz10 <= 8'b00001010;
        Wz11 <= 8'b10011111;
        Wz12 <= 8'b00100011;
        Wz13 <= 8'b00111000;
        //Wz2
        Wz20 <= 8'b01011110;
        Wz21 <= 8'b01110000;
        Wz22 <= 8'b00001011;
        Wz23 <= 8'b00000101;
        //Wz3
        Wz30 <= 8'b11000100;
        Wz31 <= 8'b00100101;
        Wz32 <= 8'b00100101;
        Wz33 <= 8'b01111110;
        //Wf0
        Wf00 <= 8'b00000110;
        Wf01 <= 8'b11100101;
        Wf02 <= 8'b11011001;
        Wf03 <= 8'b10001011;
        //Wf1
        Wf10 <= 8'b00000111;
        Wf11 <= 8'b00101011;
        Wf12 <= 8'b10100110;
        Wf13 <= 8'b01000001;
        //Wf2
        Wf20 <= 8'b01011100;
        Wf21 <= 8'b00111101;
        Wf22 <= 8'b00010110;
        Wf23 <= 8'b10111110;
        //Wf3
        Wf30 <= 8'b11111100;
        Wf31 <= 8'b00000101;
        Wf32 <= 8'b11000011;
        Wf33 <= 8'b11110001;
        //Wo0
        Wo00 <= 8'b00110000;
        Wo01 <= 8'b00101110;
        Wo02 <= 8'b11010101;
        Wo03 <= 8'b01010010;
        //Wo1
        Wo10 <= 8'b11011100;
        Wo11 <= 8'b00110100;
        Wo12 <= 8'b11101101;
        Wo13 <= 8'b11101110;
        //Wo2
        Wo20 <= 8'b00111100;
        Wo21 <= 8'b11110001;
        Wo22 <= 8'b11000101;
        Wo23 <= 8'b01100011;
        //Wo3
        Wo30 <= 8'b11100101;
        Wo31 <= 8'b10000101;
        Wo32 <= 8'b10110010;
        Wo33 <= 8'b11100100;
        
        //Ri0
        Ri00 <= 8'b00000011;
        Ri01 <= 8'b10110011;
        Ri02 <= 8'b01001010;
        Ri03 <= 8'b10011101;
        //Ri1
        Ri10 <= 8'b01100010;
        Ri11 <= 8'b11101000;
        Ri12 <= 8'b11010010;
        Ri13 <= 8'b10100011;
        //Ri2
        Ri20 <= 8'b00010110;
        Ri21 <= 8'b00111111;
        Ri22 <= 8'b00001000;
        Ri23 <= 8'b00101101;
        //Ri3
        Ri30 <= 8'b10101000;
        Ri31 <= 8'b01010011;
        Ri32 <= 8'b10010111;
        Ri33 <= 8'b11111111;
        //Rz0
        Rz00 <= 8'b01000100;
        Rz01 <= 8'b11100001;
        Rz02 <= 8'b11010100;
        Rz03 <= 8'b01000100;
        //Rz1
        Rz10 <= 8'b11100110;
        Rz11 <= 8'b10110111;
        Rz12 <= 8'b00101011;
        Rz13 <= 8'b10101011;
        //Rz2
        Rz20 <= 8'b01001110;
        Rz21 <= 8'b01001010;
        Rz22 <= 8'b11110000;
        Rz23 <= 8'b01011100;
        //Rz3
        Rz30 <= 8'b01000001;
        Rz31 <= 8'b01110011;
        Rz32 <= 8'b01010101;
        Rz33 <= 8'b01111101;
        //Rf0
        Rf00 <= 8'b10110001;
        Rf01 <= 8'b01011001;
        Rf02 <= 8'b00010101;
        Rf03 <= 8'b10000000;
        //Rf1
        Rf10 <= 8'b11111111;
        Rf11 <= 8'b00001111;
        Rf12 <= 8'b01010000;
        Rf13 <= 8'b01011101;
        //Rf2
        Rf20 <= 8'b10100110;
        Rf21 <= 8'b01101101;
        Rf22 <= 8'b01100001;
        Rf23 <= 8'b00011100;
        //Rf3
        Rf30 <= 8'b10001110;
        Rf31 <= 8'b00110010;
        Rf32 <= 8'b01111101;
        Rf33 <= 8'b01111101;
        //Ro0
        Ro00 <= 8'b00000111;
        Ro01 <= 8'b10000000;
        Ro02 <= 8'b00111101;
        Ro03 <= 8'b10010101;
        //Ro1
        Ro10 <= 8'b11111011;
        Ro11 <= 8'b01100110;
        Ro12 <= 8'b00010110;
        Ro13 <= 8'b00100000;
        //Ro2
        Ro20 <= 8'b01001101;
        Ro21 <= 8'b00010011;
        Ro22 <= 8'b10111111;
        Ro23 <= 8'b00101001;
        //Ro3
        Ro30 <= 8'b10111010;
        Ro31 <= 8'b01011000;
        Ro32 <= 8'b00101010;
        Ro33 <= 8'b00111010;
        
        //pi0
        pi0 <= 8'b01100100;
        //pi1
        pi1 <= 8'b01111011;
        //pi2
        pi2 <= 8'b01000100;
        //pi3
        pi3 <= 8'b00010100;

        //pf0
        pf0 <= 8'b01101101;
        //pf1
        pf1 <= 8'b00010100;
        //pf2
        pf2 <= 8'b10000100;
        //pf3
        pf3 <= 8'b10011111;

        //po0
        po0 <= 8'b01011100;
        //po1
        po1 <= 8'b11111100;
        //po2
        po2 <= 8'b01011000;
        //po3
        po3 <= 8'b10110110;
    end
end


endmodule
