`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2026 18:33:02
// Design Name: 
// Module Name: PE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PE(input clk,input [7:0] data_1,input [7:0] data_2,input [7:0] data_3,input en_in,output reg [31:0] out);
reg [7:0] kernel[8:0];
parameter kernelsum=10;
parameter rowlength=6;
reg [31:0] accum1;
reg [31:0] accum2;
reg [31:0] accum3;
reg [2:0] state;
reg [1:0] counter;
reg [8:0] rowcount;
reg [1:0] accum_num;
initial begin
accum_num=0;
rowcount=0;
counter=0;
state=0;
kernel[0]=1;
kernel[1]=1;
kernel[2]=4;
kernel[3]=1;
kernel[4]=1;
kernel[5]=4;
kernel[6]=1;
kernel[7]=1;
kernel[8]=4;
end
always @(posedge clk) begin
if(en_in==1) begin
case(state)
3'b0: begin //setting up the accumulators
case(counter) 
2'b0: begin
accum1<=data_1*kernel[0]+data_2*kernel[3]+data_3*kernel[6];
case (accum_num)
2'b01:begin
out<=accum1;
rowcount<=rowcount+1;
end
2'b10: begin
out<=accum2;
rowcount<=rowcount+1;
end
2'b11: begin
out<=accum3;
rowcount<=rowcount+1;
end
endcase
end
2'b1:begin
accum1<=accum1+data_1*kernel[1]+data_2*kernel[4]+data_3*kernel[7];
accum2<=data_1*kernel[0]+data_2*kernel[3]+data_3*kernel[6];
end
2'b10:begin
accum1<=accum1+data_1*kernel[2]+data_2*kernel[5]+data_3*kernel[8];
accum2<=accum2+data_1*kernel[1]+data_2*kernel[4]+data_3*kernel[7];
accum3<=data_1*kernel[0]+data_2*kernel[3]+data_3*kernel[6];
state<=3'b001;
end
endcase
counter<=counter+1;
end
3'b001:begin
accum1<=data_1*kernel[0]+data_2*kernel[3]+data_3*kernel[6];
accum2<=accum2+data_1*kernel[2]+data_2*kernel[5]+data_3*kernel[8];
accum3<=accum3+data_1*kernel[1]+data_2*kernel[4]+data_3*kernel[7];
out<=accum1;
rowcount<=rowcount+1;
if((rowcount==rowlength-2 && accum_num==0)|| rowcount==rowlength-1) begin
state<=3'b000;
counter<=0;
rowcount<=0;
accum_num<=2'b10;
end
else begin
state<=3'b010;
end
end
3'b010:begin
accum1<=accum1+data_1*kernel[1]+data_2*kernel[4]+data_3*kernel[7];
accum2<=data_1*kernel[0]+data_2*kernel[3]+data_3*kernel[6];
accum3<=accum3+data_1*kernel[2]+data_2*kernel[5]+data_3*kernel[8];
out<=accum2;
rowcount<=rowcount+1;
if((rowcount==rowlength-2 && accum_num==0)|| rowcount==rowlength-1) begin
state<=3'b000;
counter<=0;
rowcount<=0;
accum_num<=2'b11;
end
else begin
state<=3'b011;
end
end
3'b011:begin
accum1<=accum1+data_1*kernel[2]+data_2*kernel[5]+data_3*kernel[8];
accum2<=accum2+data_1*kernel[1]+data_2*kernel[4]+data_3*kernel[7];
accum3<=data_1*kernel[0]+data_2*kernel[3]+data_3*kernel[6];
out<=accum3;
rowcount<=rowcount+1;
if((rowcount==rowlength-2 && accum_num==0)|| rowcount==rowlength-1) begin
state<=3'b0;
counter<=0;
rowcount<=0;
accum_num<=2'b01;
end
else begin
state<=3'b001;
end
end
endcase
end
end
endmodule
