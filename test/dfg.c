#include <stdio.h>

//  gcc dfg.c -o dfg.elf
//  ./dfg.elf

signed char x0 = 0b00100101;
signed char x1 = 0b00110101;
signed char x2 = 0b11110101;
signed char x3 = 0b11101011;

signed char y_in0 = 0b00000000;
signed char y_in1 = 0b00000000;
signed char y_in2 = 0b00000000;
signed char y_in3 = 0b00000000;

signed char Wi00 = 0b10111000;
signed char Wi01 = 0b11101000;
signed char Wi02 = 0b00100000;
signed char Wi03 = 0b10110001;
signed char Wz00 = 0b00010101;
signed char Wz01 = 0b11010001;
signed char Wz02 = 0b11111011;
signed char Wz03 = 0b00001011;
signed char Wf00 = 0b00000110;
signed char Wf01 = 0b11100101;
signed char Wf02 = 0b11011001;
signed char Wf03 = 0b10001011;
signed char Wo00 = 0b00110000;
signed char Wo01 = 0b00101110;
signed char Wo02 = 0b11010101;
signed char Wo03 = 0b01010010;
signed char Ri00 = 0b00000011;
signed char Ri01 = 0b10110011;
signed char Ri02 = 0b01001010;
signed char Ri03 = 0b10011101;
signed char Rz00 = 0b01000100;
signed char Rz01 = 0b11100001;
signed char Rz02 = 0b11010100;
signed char Rz03 = 0b01000100;
signed char Rf00 = 0b10110001;
signed char Rf01 = 0b01011001;
signed char Rf02 = 0b00010101;
signed char Rf03 = 0b10000000;
signed char Ro00 = 0b00000111;
signed char Ro01 = 0b10000000;
signed char Ro02 = 0b00111101;
signed char Ro03 = 0b10010101;
signed char pi0 = 0b01100100;
signed char pf0 = 0b01101101;
signed char po0 = 0b01011100;

signed long  r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22,r23,r24,r25,r26,r27;
signed long y_out0,y_out1,y_out2,y_out3;
signed long c = 0;
unsigned int sigmoid_mem[256];

void init();

void printBinary(int num) {
    int i;
    printf("Binary representation: ");
    for (i = 8; i >= 0; i--) {
        int k = num >> i;
        if (k & 1)
            printf("1");
        else
            printf("0");
    }
    printf("\n");
}
signed long idx;
void main(){
    init();
    r1 = (x0 * Wz00 + x1 * Wz01 + x2 * Wz02 + x3 * Wz03)>>7;
    r2 = (y_in0 * Rz00 + y_in1 * Rz01 + y_in2 * Rz02 + y_in3 * Rz03)>>7;
    r3 = (x0 * Wi00 + x1 * Wi01 + x2 * Wi02 + x3 * Wi03)>>7;
    r4 = (y_in0 * Ri00 + y_in1 * Ri01 + y_in2 * Ri02 + y_in3 * Ri03)>>7;
    printf("r1 = 0x%08lX,\a r2 = 0x%08lX\a r3 = 0x%08lX\a r4 = 0x%08lX\n", r1, r2, r3, r4);

    r5 = (c * pf0)>>7;
    r6 = (x0 * Wf00 + x1 * Wf01 + x2 * Wf02 + x3 * Wf03)>>7;
    r7 = (y_in0 * Rf00 + y_in1 * Rf01 + y_in2 * Rf02 + y_in3 * Rf03)>>7;
    r8 = (x0 * Wo00 + x1 * Wo01 + x2 * Wo02 + x3 * Wo03)>>7;
    r9 = (y_in0 * Ro00 + y_in1 * Ro01 + y_in2 * Ro02 + y_in3 * Ro03)>>7;
    printf("r5 = 0x%08lX,\a r6 = 0x%08lX\a r7 = 0x%08lX\a r8 = 0x%08lX r9 = 0x%08lX\n", r5, r6, r7, r8, r9);

    r10 = r1 + r2;
    r11 = r3 + r4;
    r12 = (c * pi0)>>7;
    r13 = r6 + r7;
    printf("r10 = 0x%08lX,\a r11 = 0x%08lX\a r12 = 0x%08lX\a r13 = 0x%08lX\n", r10, r11, r12, r13);

    if(r10 > 32767){
        idx = 127 << 1;
        printf("r10 > 32767");
    } 
    else if(r10 < -32768){
        idx = -128 << 1;
        printf("r10 <-32768");
    }
    else
        idx = r10;
    printf("idx>>1 = 0x%08lX\a\n",idx>>1);
    r14 = sigmoid_mem[(idx >> 1) & 0xFF];//TODO: >>7 还是 8(VERILOG中查表只使用高8位)
    r15 = r11 + r12;
    r16 = r5 + r13;
    r17 = r8 + r9;
    printf("r14 = 0x%08lX,\a r15 = 0x%08lX\a r16 = 0x%08lX\a r17 = 0x%08lX\n", r14, r15, r16, r17);

    if(r15 > 32767) idx = 127 << 1; else if(r15 < -32768) idx = -128 << 1; else idx = r15;
    printf("idx>>1 = 0x%08lX\a\n",idx>>1);
    r18 = sigmoid_mem[(idx >> 1) & 0xFF];   //TODO: check

    if(r16 > 32767) idx = 127 << 1; else if(r16 < -32768) idx = -128 << 1; else idx = r16;
    printf("idx>>1 = 0x%08lX\a\n",idx>>1);
    r19 = sigmoid_mem[(idx >> 1) & 0xFF];
    
    r20 = (r18 * r14)>>7;
    r21 = (c * r19)>>7;
    printf("r18 = 0x%08lX,\a r19 = 0x%08lX\a r20 = 0x%08lX\a r21 = 0x%08lX\n", r18, r19, r20, r21);

    r22 = r20 + r21;
    r23 = r22;
    c = r22;
    // c = (r22 >> 7) & 0xFF;//TODO: check
    printf("r22 = 0x%08lX,\a r23 = 0x%08lX\a c = 0x%08lX\n", r22, r23, c);

    r24 = sigmoid_mem[(r22 >> 1) & 0xFF];
    r25 = (po0 * r23)>>7;
    r26 = r25 + r17;

    idx = r26;
    if(r26 > 32767) idx = 127 << 1; else if(r26 < -32768) r26 = -128 << 1; else idx = r26;
    r27 = sigmoid_mem[(idx >> 1) & 0xFF];
        printf("(r26 >> 8) & 0xFF = 0x%08lX\n", (r26 ) & 0xFF);//for test
        printf("idx = %ld\n",idx);
    printf("r24 = 0x%08lX,\a r25 = 0x%08lX\a r26 = 0x%08lX\a r27 = 0x%08lX\n", r24, r25, r26, r27);

    y_out0 = (r24 * r27) >> 7;
    printBinary(y_out0);
    // printf("y_out0 = 0x%08X\n", y_out0);

}


void init()
{
    sigmoid_mem[0]   = 0b01000000;   
    sigmoid_mem[1]   = 0b01000000;
    sigmoid_mem[2]   = 0b01000000;
    sigmoid_mem[3]   = 0b01000001;
    sigmoid_mem[4]   = 0b01000001;
    sigmoid_mem[5]   = 0b01000010;
    sigmoid_mem[6]   = 0b01000010;
    sigmoid_mem[7]   = 0b01000011;
    sigmoid_mem[8]   = 0b01000011;
    sigmoid_mem[9]   = 0b01000100;
    sigmoid_mem[10]  = 0b01000100;
    sigmoid_mem[11]  = 0b01000101;
    sigmoid_mem[12]  = 0b01000101;
    sigmoid_mem[13]  = 0b01000110;
    sigmoid_mem[14]  = 0b01000110;
    sigmoid_mem[15]  = 0b01000111;
    sigmoid_mem[16]  = 0b01000111;
    sigmoid_mem[17]  = 0b01001000;
    sigmoid_mem[18]  = 0b01001000;
    sigmoid_mem[19]  = 0b01001001;
    sigmoid_mem[20]  = 0b01001001;
    sigmoid_mem[21]  = 0b01001010;
    sigmoid_mem[22]  = 0b01001010;
    sigmoid_mem[23]  = 0b01001011;
    sigmoid_mem[24]  = 0b01001011;
    sigmoid_mem[25]  = 0b01001100;
    sigmoid_mem[26]  = 0b01001100;
    sigmoid_mem[27]  = 0b01001101;
    sigmoid_mem[28]  = 0b01001101;
    sigmoid_mem[29]  = 0b01001110;
    sigmoid_mem[30]  = 0b01001110;
    sigmoid_mem[31]  = 0b01001111;
    sigmoid_mem[32]  = 0b01001111;
    sigmoid_mem[33]  = 0b01010000;
    sigmoid_mem[34]  = 0b01010000;
    sigmoid_mem[35]  = 0b01010001;
    sigmoid_mem[36]  = 0b01010001;
    sigmoid_mem[37]  = 0b01010010;
    sigmoid_mem[38]  = 0b01010010;
    sigmoid_mem[39]  = 0b01010010;
    sigmoid_mem[40]  = 0b01010011;
    sigmoid_mem[41]  = 0b01010011;
    sigmoid_mem[42]  = 0b01010100;
    sigmoid_mem[43]  = 0b01010100;
    sigmoid_mem[44]  = 0b01010101;
    sigmoid_mem[45]  = 0b01010101;
    sigmoid_mem[46]  = 0b01010110;
    sigmoid_mem[47]  = 0b01010110;
    sigmoid_mem[48]  = 0b01010110;
    sigmoid_mem[49]  = 0b01010111;
    sigmoid_mem[50]  = 0b01010111;
    sigmoid_mem[51]  = 0b01011000;
    sigmoid_mem[52]  = 0b01011000;
    sigmoid_mem[53]  = 0b01011001;
    sigmoid_mem[54]  = 0b01011001;
    sigmoid_mem[55]  = 0b01011001;
    sigmoid_mem[56]  = 0b01011010;
    sigmoid_mem[57]  = 0b01011010;
    sigmoid_mem[58]  = 0b01011011;
    sigmoid_mem[59]  = 0b01011011;
    sigmoid_mem[60]  = 0b01011011;
    sigmoid_mem[61]  = 0b01011100;
    sigmoid_mem[62]  = 0b01011100;
    sigmoid_mem[63]  = 0b01011101;
    sigmoid_mem[64]  = 0b01011101;
    sigmoid_mem[65]  = 0b01011101;
    sigmoid_mem[66]  = 0b01011110;
    sigmoid_mem[67]  = 0b01011110;
    sigmoid_mem[68]  = 0b01011111;
    sigmoid_mem[69]  = 0b01011111;
    sigmoid_mem[70]  = 0b01011111;
    sigmoid_mem[71]  = 0b01100000;
    sigmoid_mem[72]  = 0b01100000;
    sigmoid_mem[73]  = 0b01100000;
    sigmoid_mem[74]  = 0b01100001;
    sigmoid_mem[75]  = 0b01100001;
    sigmoid_mem[76]  = 0b01100010;
    sigmoid_mem[77]  = 0b01100010;
    sigmoid_mem[78]  = 0b01100010;
    sigmoid_mem[79]  = 0b01100011;
    sigmoid_mem[80]  = 0b01100011;
    sigmoid_mem[81]  = 0b01100011;
    sigmoid_mem[82]  = 0b01100100;
    sigmoid_mem[83]  = 0b01100100;
    sigmoid_mem[84]  = 0b01100100;
    sigmoid_mem[85]  = 0b01100101;
    sigmoid_mem[86]  = 0b01100101;
    sigmoid_mem[87]  = 0b01100101;
    sigmoid_mem[88]  = 0b01100110;
    sigmoid_mem[89]  = 0b01100110;
    sigmoid_mem[90]  = 0b01100110;
    sigmoid_mem[91]  = 0b01100111;
    sigmoid_mem[92]  = 0b01100111;
    sigmoid_mem[93]  = 0b01100111;
    sigmoid_mem[94]  = 0b01101000;
    sigmoid_mem[95]  = 0b01101000;
    sigmoid_mem[96]  = 0b01101000;
    sigmoid_mem[97]  = 0b01101000;
    sigmoid_mem[98]  = 0b01101001;
    sigmoid_mem[99]  = 0b01101001;
    sigmoid_mem[100] = 0b01101001;
    sigmoid_mem[101] = 0b01101010;
    sigmoid_mem[102] = 0b01101010;
    sigmoid_mem[103] = 0b01101010;
    sigmoid_mem[104] = 0b01101010;
    sigmoid_mem[105] = 0b01101011;
    sigmoid_mem[106] = 0b01101011;
    sigmoid_mem[107] = 0b01101011;
    sigmoid_mem[108] = 0b01101100;
    sigmoid_mem[109] = 0b01101100;
    sigmoid_mem[110] = 0b01101100;
    sigmoid_mem[111] = 0b01101100;
    sigmoid_mem[112] = 0b01101101;
    sigmoid_mem[113] = 0b01101101;
    sigmoid_mem[114] = 0b01101101;
    sigmoid_mem[115] = 0b01101101;
    sigmoid_mem[116] = 0b01101110;
    sigmoid_mem[117] = 0b01101110;
    sigmoid_mem[118] = 0b01101110;
    sigmoid_mem[119] = 0b01101110;
    sigmoid_mem[120] = 0b01101110;
    sigmoid_mem[121] = 0b01101111;
    sigmoid_mem[122] = 0b01101111;
    sigmoid_mem[123] = 0b01101111;
    sigmoid_mem[124] = 0b01101111;
    sigmoid_mem[125] = 0b01110000;
    sigmoid_mem[126] = 0b01110000;
    sigmoid_mem[127] = 0b01110000;    
    sigmoid_mem[128] = 0b00001111;    
    sigmoid_mem[129] = 0b00001111;
    sigmoid_mem[130] = 0b00001111;
    sigmoid_mem[131] = 0b00001111;
    sigmoid_mem[132] = 0b00010000;
    sigmoid_mem[133] = 0b00010000;
    sigmoid_mem[134] = 0b00010000;
    sigmoid_mem[135] = 0b00010000;
    sigmoid_mem[136] = 0b00010001;
    sigmoid_mem[137] = 0b00010001;
    sigmoid_mem[138] = 0b00010001;
    sigmoid_mem[139] = 0b00010001;
    sigmoid_mem[140] = 0b00010001;
    sigmoid_mem[141] = 0b00010010;
    sigmoid_mem[142] = 0b00010010;
    sigmoid_mem[143] = 0b00010010;
    sigmoid_mem[144] = 0b00010010;
    sigmoid_mem[145] = 0b00010011;
    sigmoid_mem[146] = 0b00010011;
    sigmoid_mem[147] = 0b00010011;
    sigmoid_mem[148] = 0b00010011;
    sigmoid_mem[149] = 0b00010100;
    sigmoid_mem[150] = 0b00010100;
    sigmoid_mem[151] = 0b00010100;
    sigmoid_mem[152] = 0b00010101;
    sigmoid_mem[153] = 0b00010101;
    sigmoid_mem[154] = 0b00010101;
    sigmoid_mem[155] = 0b00010101;
    sigmoid_mem[156] = 0b00010110;
    sigmoid_mem[157] = 0b00010110;
    sigmoid_mem[158] = 0b00010110;
    sigmoid_mem[159] = 0b00010111;
    sigmoid_mem[160] = 0b00010111;
    sigmoid_mem[161] = 0b00010111;
    sigmoid_mem[162] = 0b00010111;
    sigmoid_mem[163] = 0b00011000;
    sigmoid_mem[164] = 0b00011000;
    sigmoid_mem[165] = 0b00011000;
    sigmoid_mem[166] = 0b00011001;
    sigmoid_mem[167] = 0b00011001;
    sigmoid_mem[168] = 0b00011001;
    sigmoid_mem[169] = 0b00011010;
    sigmoid_mem[170] = 0b00011010;
    sigmoid_mem[171] = 0b00011010;
    sigmoid_mem[172] = 0b00011011;
    sigmoid_mem[173] = 0b00011011;
    sigmoid_mem[174] = 0b00011011;
    sigmoid_mem[175] = 0b00011100;
    sigmoid_mem[176] = 0b00011100;
    sigmoid_mem[177] = 0b00011100;
    sigmoid_mem[178] = 0b00011101;
    sigmoid_mem[179] = 0b00011101;
    sigmoid_mem[180] = 0b00011101;
    sigmoid_mem[181] = 0b00011110;
    sigmoid_mem[182] = 0b00011110;
    sigmoid_mem[183] = 0b00011111;
    sigmoid_mem[184] = 0b00011111;
    sigmoid_mem[185] = 0b00011111;
    sigmoid_mem[186] = 0b00100000;
    sigmoid_mem[187] = 0b00100000;
    sigmoid_mem[188] = 0b00100000;
    sigmoid_mem[189] = 0b00100001;
    sigmoid_mem[190] = 0b00100001;
    sigmoid_mem[191] = 0b00100010;
    sigmoid_mem[192] = 0b00100010;
    sigmoid_mem[193] = 0b00100010;
    sigmoid_mem[194] = 0b00100011;
    sigmoid_mem[195] = 0b00100011;
    sigmoid_mem[196] = 0b00100100;
    sigmoid_mem[197] = 0b00100100;
    sigmoid_mem[198] = 0b00100100;
    sigmoid_mem[199] = 0b00100101;
    sigmoid_mem[200] = 0b00100101;
    sigmoid_mem[201] = 0b00100110;
    sigmoid_mem[202] = 0b00100110;
    sigmoid_mem[203] = 0b00100110;
    sigmoid_mem[204] = 0b00100111;
    sigmoid_mem[205] = 0b00100111;
    sigmoid_mem[206] = 0b00101000;
    sigmoid_mem[207] = 0b00101000;
    sigmoid_mem[208] = 0b00101001;
    sigmoid_mem[209] = 0b00101001;
    sigmoid_mem[210] = 0b00101001;
    sigmoid_mem[211] = 0b00101010;
    sigmoid_mem[212] = 0b00101010;
    sigmoid_mem[213] = 0b00101011;
    sigmoid_mem[214] = 0b00101011;
    sigmoid_mem[215] = 0b00101100;
    sigmoid_mem[216] = 0b00101100;
    sigmoid_mem[217] = 0b00101101;
    sigmoid_mem[218] = 0b00101101;
    sigmoid_mem[219] = 0b00101101;
    sigmoid_mem[220] = 0b00101110;
    sigmoid_mem[221] = 0b00101110;
    sigmoid_mem[222] = 0b00101111;
    sigmoid_mem[223] = 0b00101111;
    sigmoid_mem[224] = 0b00110000;
    sigmoid_mem[225] = 0b00110000;
    sigmoid_mem[226] = 0b00110001;
    sigmoid_mem[227] = 0b00110001;
    sigmoid_mem[228] = 0b00110010;
    sigmoid_mem[229] = 0b00110010;
    sigmoid_mem[230] = 0b00110011;
    sigmoid_mem[231] = 0b00110011;
    sigmoid_mem[232] = 0b00110100;
    sigmoid_mem[233] = 0b00110100;
    sigmoid_mem[234] = 0b00110101;
    sigmoid_mem[235] = 0b00110101;
    sigmoid_mem[236] = 0b00110110;
    sigmoid_mem[237] = 0b00110110;
    sigmoid_mem[238] = 0b00110111;
    sigmoid_mem[239] = 0b00110111;
    sigmoid_mem[240] = 0b00111000;
    sigmoid_mem[241] = 0b00111000;
    sigmoid_mem[242] = 0b00111001;
    sigmoid_mem[243] = 0b00111001;
    sigmoid_mem[244] = 0b00111010;
    sigmoid_mem[245] = 0b00111010;
    sigmoid_mem[246] = 0b00111011;
    sigmoid_mem[247] = 0b00111011;
    sigmoid_mem[248] = 0b00111100;
    sigmoid_mem[249] = 0b00111100;
    sigmoid_mem[250] = 0b00111101;
    sigmoid_mem[251] = 0b00111101;
    sigmoid_mem[252] = 0b00111110;
    sigmoid_mem[253] = 0b00111110;
    sigmoid_mem[254] = 0b00111111;
    sigmoid_mem[255] = 0b00111111;

}