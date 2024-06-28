module lstm
#(  parameter DATA_WIDTH = 8,  
    parameter REG_WIDTH = 32    //TODO: 位宽对结果的影响
)
(
    // ------------input-----------------   
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire signed [DATA_WIDTH-1:0] x0,  
    input wire signed [DATA_WIDTH-1:0] x1,  
    input wire signed [DATA_WIDTH-1:0] x2,  
    input wire signed [DATA_WIDTH-1:0] x3,  
    input wire signed [DATA_WIDTH-1:0] y_in0, 
    input wire signed [DATA_WIDTH-1:0] y_in1, 
    input wire signed [DATA_WIDTH-1:0] y_in2, 
    input wire signed [DATA_WIDTH-1:0] y_in3,
    input wire signed [DATA_WIDTH*4-1:0] Wi,  
    input wire signed [DATA_WIDTH*4-1:0] Wz,  
    input wire signed [DATA_WIDTH*4-1:0] Wf,  
    input wire signed [DATA_WIDTH*4-1:0] Wo,  
    input wire signed [DATA_WIDTH*4-1:0] Ri,  
    input wire signed [DATA_WIDTH*4-1:0] Rz,  
    input wire signed [DATA_WIDTH*4-1:0] Rf,  
    input wire signed [DATA_WIDTH*4-1:0] Ro,  
    input wire signed [DATA_WIDTH*3-1:0] p,  
    // sigmod data
    input wire [DATA_WIDTH-1:0] sigmod_data_in1,//输入的sigmod的值为无符号数
    input wire [DATA_WIDTH-1:0] sigmod_data_in2,//输入的sigmod的值为无符号数
    input wire [DATA_WIDTH-1:0] sigmod_data_in3,//输入的sigmod的值为无符号数

    // ------------output-----------------  
    output reg sigmod_request1, 
    output reg sigmod_request2, 
    output reg sigmod_request3, 
    output reg signed [DATA_WIDTH-1:0] sigmod_data_out1, 
    output reg signed [DATA_WIDTH-1:0] sigmod_data_out2, 
    output reg signed [DATA_WIDTH-1:0] sigmod_data_out3, 
    output reg valid,   //输出完成
    output reg signed [DATA_WIDTH-1:0] y
);


//权重
reg signed [DATA_WIDTH-1:0] Wi0;
reg signed [DATA_WIDTH-1:0] Wi1;
reg signed [DATA_WIDTH-1:0] Wi2;
reg signed [DATA_WIDTH-1:0] Wi3;
reg signed [DATA_WIDTH-1:0] Wz0;
reg signed [DATA_WIDTH-1:0] Wz1;
reg signed [DATA_WIDTH-1:0] Wz2;
reg signed [DATA_WIDTH-1:0] Wz3;
reg signed [DATA_WIDTH-1:0] Wf0;
reg signed [DATA_WIDTH-1:0] Wf1;
reg signed [DATA_WIDTH-1:0] Wf2;
reg signed [DATA_WIDTH-1:0] Wf3;
reg signed [DATA_WIDTH-1:0] Wo0;
reg signed [DATA_WIDTH-1:0] Wo1;
reg signed [DATA_WIDTH-1:0] Wo2;
reg signed [DATA_WIDTH-1:0] Wo3;
reg signed [DATA_WIDTH-1:0] Ri0;
reg signed [DATA_WIDTH-1:0] Ri1;
reg signed [DATA_WIDTH-1:0] Ri2;
reg signed [DATA_WIDTH-1:0] Ri3;
reg signed [DATA_WIDTH-1:0] Rz0;
reg signed [DATA_WIDTH-1:0] Rz1;
reg signed [DATA_WIDTH-1:0] Rz2;
reg signed [DATA_WIDTH-1:0] Rz3;
reg signed [DATA_WIDTH-1:0] Rf0;
reg signed [DATA_WIDTH-1:0] Rf1;
reg signed [DATA_WIDTH-1:0] Rf2;
reg signed [DATA_WIDTH-1:0] Rf3;
reg signed [DATA_WIDTH-1:0] Ro0;
reg signed [DATA_WIDTH-1:0] Ro1;
reg signed [DATA_WIDTH-1:0] Ro2;
reg signed [DATA_WIDTH-1:0] Ro3;
reg signed [DATA_WIDTH-1:0] pi;
reg signed [DATA_WIDTH-1:0] pf;
reg signed [DATA_WIDTH-1:0] po;

//----------------reg-----------------------------
reg signed [REG_WIDTH-1:0] r1;
reg signed [REG_WIDTH-1:0] r2;
reg signed [REG_WIDTH-1:0] r3;
reg signed [REG_WIDTH-1:0] r4;
reg signed [REG_WIDTH-1:0] r5;
reg signed [REG_WIDTH-1:0] r6;
reg signed [REG_WIDTH-1:0] c;

//----------------ctrl----------------------------
parameter IDLE = 1'b0;
parameter BUSY = 1'b1;
reg curr_state;
reg next_state;
parameter CTRL_STEPS = 16;// 0-15
reg [3:0] counter;


//状态机第一段
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        curr_state <= IDLE;
    else
        curr_state <= next_state;
end

//计数器
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        counter <= 4'd0;
    else 
        case(curr_state)
            BUSY:
            begin 
                if(counter == CTRL_STEPS - 1)
                    counter <= 4'd0;
                else 
                    counter <= counter + 1;
            end
            default:
                counter <= 4'd0;
        endcase
end


//状态机第二段
always @(*) begin
    next_state = IDLE;
    case(curr_state)
        IDLE: 
            if(start == 1'b1)
                next_state = BUSY;
            else   
                next_state = IDLE;
        BUSY: 
            if(counter == CTRL_STEPS - 1)
                next_state = IDLE;
            else   
                next_state = BUSY;
        default: 
                next_state = IDLE;
    endcase
end

//sigmod  使用纯组合逻辑查找
always @(*) begin
    sigmod_data_out1 = 0;
    sigmod_request1 = 0; 
    sigmod_data_out2 = 0;
    sigmod_request2 = 0; 
    sigmod_data_out3 = 0;
    sigmod_request3 = 0; 
    case(curr_state)
        BUSY:
            case(counter)
                9: begin    
                    // r1 计算sigmod查找表。输出为 -128 至 127 的 8bit 有符号数
                    begin   // r1是由两个8bit有符号数相乘得到，不会超过16bit，而低位可能引入噪声或不重要的信息，所以选择中间的7bit
                        if(r1 > 32767)
                            sigmod_data_out1 = 127;
                        else if(r1 < -32768)
                            sigmod_data_out1 = -128;
                        else    
                            // sigmod_data_out1[6:0] = r1[6:0];  
                            sigmod_data_out1[6:0] = r1[7:1];            //r1已经是除了128了，还需要除以2
                            sigmod_data_out1[7] = r1[REG_WIDTH-1];
                            // sigmod_data_out1 = r1[8:1];  
                    end
                    sigmod_request1 = 1;
                    // r2 查找
                    begin
                        if(r2 > 32767)
                            sigmod_data_out2 = 127;
                        else if(r2 < -32768)
                            sigmod_data_out2 = -128;
                        else    
                            // sigmod_data_out2[6:0] = r2[6:0];
                            sigmod_data_out2[6:0] = r2[7:1];
                            sigmod_data_out2[7] = r2[REG_WIDTH-1];
                            // sigmod_data_out2 = r2[8:1];  
                    end
                    sigmod_request2 = 1;
                    // r3 查找
                    begin
                        if(r3 > 32767)
                            sigmod_data_out3 = 127;
                        else if(r3 < -32768)
                            sigmod_data_out3 = -128;
                        else    
                            // sigmod_data_out3[6:0] = r3[6:0];
                            sigmod_data_out3[6:0] = r3[7:1];
                            sigmod_data_out3[7] = r3[REG_WIDTH-1];
                            // sigmod_data_out3 = r3[8:1];  
                    end
                    sigmod_request3 = 1;
                end
                12: begin
                    // r2 查找
                    begin
                        if(r3 > 32767)
                            sigmod_data_out2 = 127;
                        else if(r3 < -32768)
                            sigmod_data_out2 = -128;
                        else    
                            // sigmod_data_out2[6:0] = r3[6:0];
                            sigmod_data_out2[6:0] = r3[7:1];
                            sigmod_data_out2[7] = r3[REG_WIDTH-1];
                            // sigmod_data_out2 = r3[8:1];  
                    end
                    sigmod_request2 = 1;
                end
                14: begin
                    begin
                        if(r1 > 32767)
                            sigmod_data_out1 = 127;
                        else if(r1 < -32768)
                            sigmod_data_out1 = -128;
                        else    
                            // sigmod_data_out1[6:0] = r1[6:0];
                            sigmod_data_out1[6:0] = r1[7:1];
                            sigmod_data_out1[7] = r1[REG_WIDTH-1];
                            // sigmod_data_out1 = r1[8:1];  
                    end
                    sigmod_request1 = 1;
                end
                default: begin
                    sigmod_data_out1 = 0;
                    sigmod_request1 = 0; 
                    sigmod_data_out2 = 0;
                    sigmod_request2 = 0; 
                    sigmod_data_out3 = 0;
                    sigmod_request3 = 0; 
                end
            endcase
    endcase

end

/*
    CS0-3: 向量内积：r1 r2 r3 r4
    CS4-7：向量内积：r1 r2 加法：r4 r6 乘法：r3 r5
*/
//----------状态机第三段：各个寄存器的状态----------------------
//4维向量内积转换为：2个（2个标量内积和一个加法器），共2周期*2 = 4周期

reg signed [REG_WIDTH-1:0] r1_0, r1_1, r1_2, r1_3;  //必须声明signed
// reg1
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        r1 <= 0;
        r1_0 <= 0;
        r1_1 <= 0;
        r1_2 <= 0;
        r1_3 <= 0;
    end 
    else begin
        case(curr_state)
            BUSY:
            case(counter)
            //第1个内积
                0:begin 
                    r1_0 <= Wi0 * x0;
                    r1_1 <= Wi1 * x1;
                end
                1:begin
                    r1_0 <= r1_0 + r1_1;
                    r1_2 <= Wi2 * x2;
                    r1_3 <= Wi3 * x3;
                end
                2:  
                    r1_2 <= r1_2 + r1_3;
                3:
                    r1 <=  (r1_0 + r1_2) >>> 7; // 第四个控制步算完内积
            //第2个内积
                4:begin 
                    r1_0 <= Wz0 * x0;
                    r1_1 <= Wz1 * x1;
                end
                5:begin
                    r1_0 <= r1_0 + r1_1;
                    r1_2 <= Wz2 * x2;
                    r1_3 <= Wz3 * x3;
                end
                6:  
                    r1_2 <= r1_2 + r1_3;
                7:
                    r1 <=  (r1_0 + r1_2) >>> 7; // 第四个控制步算完内积
            //第3个内积，包含其他运算
                8:begin
                    r1 <= r1 + r2;
                    r1_0 <= Wo0 * x0;
                    r1_1 <= Wo1 * x1;
                end
                9:begin
                    r1 <= sigmod_data_in1; 
                    r1_0 <= r1_0 + r1_1;
                    r1_2 <= Wo2 * x2;
                    r1_3 <= Wo3 * x3;
                end
                10:begin  
                    r1 <= (r1 * r2) >>> 7;
                    r1_2 <= r1_2 + r1_3;
                end
                11:
                    r1 <=  (r1_0 + r1_2) >>> 7; // 第四个控制步算完内积
                12:
                    r1 <=  r1 + r2;
                13:begin
                    r1 <=  r1 + r3;
                end
                14:
                    r1 <= sigmod_data_in1; 
                default:;
            endcase 
            default:
                r1 <= 0;
        endcase
    end
end

reg signed [REG_WIDTH-1:0] r2_0, r2_1, r2_2, r2_3;
// reg2
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        r2 <= 0; 
        r2_0 <= 0;
        r2_1 <= 0;
        r2_2 <= 0;
        r2_3 <= 0;
    end
    else 
        case(curr_state)
            BUSY:
            case(counter)
            //第1个内积
                0:begin 
                    r2_0 <= Ri0 * y_in0;
                    r2_1 <= Ri1 * y_in1;
                end
                1:begin 
                    r2_0 <= r2_0 + r2_1;
                    r2_2 <= Ri2 * y_in2;
                    r2_3 <= Ri3 * y_in3;
                end
                2:  
                    r2_2 <= r2_2 + r2_3;
                3:
                    r2 <=  (r2_0 + r2_2) >>> 7; // 第四个控制步算完内积
            //第2个内积
                4:begin 
                    r2_0 <= Rz0 * y_in0;
                    r2_1 <= Rz1 * y_in1;
                end
                5:begin 
                    r2_0 <= r2_0 + r2_1;
                    r2_2 <= Rz2 * y_in2;
                    r2_3 <= Rz3 * y_in3;
                end
                6:  
                    r2_2 <= r2_2 + r2_3;
                7:
                    r2 <=  (r2_0 + r2_2) >>> 7; // 第四个控制步算完内积
            //第3个内积
                8:begin 
                    r2 <= r4 + r5;
                    r2_0 <= Ro0 * y_in0;
                    r2_1 <= Ro1 * y_in1;
                end
                9:begin 
                    r2 <= sigmod_data_in2;
                    r2_0 <= r2_0 + r2_1;
                    r2_2 <= Ro2 * y_in2;
                    r2_3 <= Ro3 * y_in3;
                end
                10:begin  
                    r2 <= (c * r3) >>> 7;
                    r2_2 <= r2_2 + r2_3;
                end
                11:begin
                    r2 <=  (r2_0 + r2_2) >>> 7; // 第四个控制步算完内积
                end
                12:
                    r2 <= sigmod_data_in2;
                13,14:
                    r2 <= r2; 
                default:;
            endcase 
            default:
                r2 <= 0;
        endcase
end

reg signed [REG_WIDTH-1:0] r3_0, r3_1, r3_2, r3_3;
// reg3
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        r3 <= 0;
        r3_0 <= 0;
        r3_1 <= 0;
        r3_2 <= 0;
        r3_3 <= 0;
    end 
    else 
        case(curr_state)
            BUSY:
            case(counter)
                0:begin 
                    r3_0 <= Wf0 * x0;
                    r3_1 <= Wf1 * x1;
                end
                1:begin 
                    r3_0 <= r3_0 + r3_1;
                    r3_2 <= Wf2 * x2;
                    r3_3 <= Wf3 * x3;
                end
                2:  
                    r3_2 <= r3_2 + r3_3;
                3:
                    r3 <=  (r3_0 + r3_2) >>> 7; // 第四个控制步算完内积
                4: 
                    r3 <= (c * pf) >>> 7;
                8:
                    r3 <= r3 + r6;
                9:
                    r3 <= sigmod_data_in3;
                11: 
                    r3 <= r1 + r2;
                12: 
                    r3 <= (po * r4) >>> 7;
                default:;
            endcase 
            default:
                r3 <= 0;
        endcase
end

reg signed [REG_WIDTH-1:0] r4_0, r4_1, r4_2, r4_3;
// reg4
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        r4 <= 0;
        r4_0 <= 0;
        r4_1 <= 0;
        r4_2 <= 0;
        r4_3 <= 0;
    end
    else begin
        case(curr_state)
            BUSY:
            case(counter)
                0:begin 
                    r4_0 <= Rf0 * y_in0;
                    r4_1 <= Rf1 * y_in1;
                end
                1:begin 
                    r4_0 <= r4_0 + r4_1;
                    r4_2 <= Rf2 * y_in2;
                    r4_3 <= Rf3 * y_in3;
                end
                2:  
                    r4_2 <= r4_2 + r4_3;
                3:
                    r4 <=  (r4_0 + r4_2) >>> 7; // 第四个控制步算完内积
                4,11: 
                    r4 <= r1 + r2;
                default:;
            endcase 
            default:
                r4 <= 0;
        endcase
    end
end

// reg5
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        r5 <= 0;
    else 
        case(curr_state)
            BUSY:
            case(counter)
                4:  
                    r5 <= (c * pi) >>> 7;
                default:;
            endcase 
            default:
                r5 <= 0;
        endcase
end

// reg6
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        r6 <= 0;
    else 
        case(curr_state)
            BUSY:
            case(counter)
                4:  
                    r6 <= r3 + r4;
                default:;
            endcase 
            default:
                r6 <= 0;
        endcase
end

// reg c
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        c <= 0;
    else 
        case(curr_state)
            BUSY:
            case(counter)
                11:  begin
                    c <= (r1 + r2);//>> 7; 
                end
                default:;
            endcase 
            default:;   // 不能清零！！！！！！！！！！否则失去记忆功能！！！！！！！！！！！！
        endcase
end

// y valid
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        y <= 0;
        valid <= 0;
    end
    else 
        case(curr_state)
            BUSY:
            case(counter)
                15:begin
                    y <= (r1 * r2) >>> 7; 
                    valid <= 1;
                end
                default:begin
                    y <= 0;
                    valid <= 0;
                end
            endcase 
            default:begin
                y <= 0;
                valid <= 0;
            end
        endcase
end

//  x 与 权重寄存器保存 
always @(posedge clk) begin
    Wi0   <= Wi[DATA_WIDTH-1:0];
    Wi1   <= Wi[DATA_WIDTH*2-1:DATA_WIDTH];
    Wi2   <= Wi[DATA_WIDTH*3-1:DATA_WIDTH*2];
    Wi3   <= Wi[DATA_WIDTH*4-1:DATA_WIDTH*3];
    Wz0   <= Wz[DATA_WIDTH-1:0];
    Wz1   <= Wz[DATA_WIDTH*2-1:DATA_WIDTH];
    Wz2   <= Wz[DATA_WIDTH*3-1:DATA_WIDTH*2];
    Wz3   <= Wz[DATA_WIDTH*4-1:DATA_WIDTH*3];
    Wf0   <= Wf[DATA_WIDTH-1:0];
    Wf1   <= Wf[DATA_WIDTH*2-1:DATA_WIDTH];
    Wf2   <= Wf[DATA_WIDTH*3-1:DATA_WIDTH*2];
    Wf3   <= Wf[DATA_WIDTH*4-1:DATA_WIDTH*3];
    Wo0   <= Wo[DATA_WIDTH-1:0];
    Wo1   <= Wo[DATA_WIDTH*2-1:DATA_WIDTH];
    Wo2   <= Wo[DATA_WIDTH*3-1:DATA_WIDTH*2];
    Wo3   <= Wo[DATA_WIDTH*4-1:DATA_WIDTH*3];
    Ri0   <= Ri[DATA_WIDTH-1:0];
    Ri1   <= Ri[DATA_WIDTH*2-1:DATA_WIDTH];
    Ri2   <= Ri[DATA_WIDTH*3-1:DATA_WIDTH*2];
    Ri3   <= Ri[DATA_WIDTH*4-1:DATA_WIDTH*3];
    Rz0   <= Rz[DATA_WIDTH-1:0];
    Rz1   <= Rz[DATA_WIDTH*2-1:DATA_WIDTH];
    Rz2   <= Rz[DATA_WIDTH*3-1:DATA_WIDTH*2];
    Rz3   <= Rz[DATA_WIDTH*4-1:DATA_WIDTH*3];
    Rf0   <= Rf[DATA_WIDTH-1:0];
    Rf1   <= Rf[DATA_WIDTH*2-1:DATA_WIDTH];
    Rf2   <= Rf[DATA_WIDTH*3-1:DATA_WIDTH*2];
    Rf3   <= Rf[DATA_WIDTH*4-1:DATA_WIDTH*3];
    Ro0   <= Ro[DATA_WIDTH-1:0];
    Ro1   <= Ro[DATA_WIDTH*2-1:DATA_WIDTH];
    Ro2   <= Ro[DATA_WIDTH*3-1:DATA_WIDTH*2];
    Ro3   <= Ro[DATA_WIDTH*4-1:DATA_WIDTH*3];
    pi    <= p[DATA_WIDTH-1:0];
    pf    <= p[DATA_WIDTH*2-1:DATA_WIDTH];
    po    <= p[DATA_WIDTH*3-1:DATA_WIDTH*2];
end 

endmodule