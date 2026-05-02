`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2026 15:20:52
// Design Name: 
// Module Name: GeneralLineBuffer
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


module GeneralLineBuffer(input en_in,input clk,input [7:0] data,output reg [31:0] out1,
output reg [31:0] out2,output reg [31:0] out3,output  en_out);
reg enable;
parameter rowlength=6;
parameter padding=1;
parameter buffersize=8;
parameter pixel_width=8;
reg [15:0] rowcount;
reg [pixel_width:0] row1 [rowlength+2*padding-1:0];
reg [pixel_width:0] row2 [rowlength+2*padding-1:0];
reg [pixel_width:0] row3 [rowlength+2*padding-1:0];
reg [2:0] buffer_index;
reg [pixel_width:0] buff1 [buffersize-1:0];
reg [pixel_width:0] buff2 [buffersize-1:0];
reg [pixel_width:0] buff3 [buffersize-1:0];
reg [2:0] state;
reg [19:0] count;
reg ready; 
reg force_execute;
integer index;
integer i;
initial begin
ready=0;
force_execute=0;
count=0;
rowcount=0;
index=rowlength+padding-1;
state=0;
buffer_index=0;
for(i=0;i<rowlength+2*padding;i=i+1) begin
row1[i]=0;
end
row2[0]=0;
row2[rowlength+2*padding-1]=0;
row3[0]=0;
row3[rowlength+2*padding-1]=0;
end

always @(posedge clk) begin
if(en_in==1 || ready==1) begin
case(state)

3'b000: begin //filling row 2
row2[index]<=data;
count<=count+1;
if(index==padding) begin
index<=rowlength+padding-1;
state<=1;
end
else begin
index<=index-1;
end
end

3'b001:begin
row3[index]<=data;
count<=count+1;
if(index==padding) begin
index<=0;
state<=2;
end
else begin
index<=index-1;
end
end

3'b010:begin  
row3[0]<=data;
count<=count+1;
row3[padding]<=0;
row2[padding]<=row3[rowlength+2*padding-1];
row2[0]<=row3[rowlength+2*padding-2];
row1[padding]<=row2[rowlength+2*padding-1];
row1[0]<=row2[rowlength+2*padding-2];
buff1[buffer_index]<=row1[rowlength+2*padding-1];
buff2[buffer_index]<=row2[rowlength+2*padding-1];
buff3[buffer_index]<=row3[rowlength+2*padding-1];

buff1[buffer_index+1]<=row1[rowlength+2*padding-2];
buff2[buffer_index+1]<=row2[rowlength+2*padding-2];
buff3[buffer_index+1]<=row3[rowlength+2*padding-2];
buffer_index<=buffer_index+2;
index<=index+1;
state<=3;
end

3'b011:begin //normal operation
row3[0]<=data;
count<=count+1;
row2[0]<=row3[rowlength+2*padding-1];
row1[0]<=row2[rowlength+2*padding-1];
buff1[buffer_index]<=row1[rowlength+2*padding-1];
buff2[buffer_index]<=row2[rowlength+2*padding-1];
buff3[buffer_index]<=row3[rowlength+2*padding-1];
buffer_index<=buffer_index+1;
if(index==rowlength-1) begin
index<=0;
state<=4;
end
else begin
index<=index+1;
end
rowcount<=rowcount+1;
end

3'b100:begin
row3[0]<=data;
count<=count+1;
if(count==rowlength*rowlength)begin
force_execute<=1;
end
row3[1]<=0;
row3[2]<=0;
row2[2]<=row3[rowlength+2*padding-1];
row2[1]<=row3[rowlength+2*padding-2];
row2[0]<=row3[rowlength+2*padding-3];
row1[2]<=row2[rowlength+2*padding-1];
row1[1]<=row2[rowlength+2*padding-2];
row1[0]<=row2[rowlength+2*padding-3];
index<=1;
state<=3;
buff1[buffer_index]<=row1[rowlength+2*padding-1];
buff2[buffer_index]<=row2[rowlength+2*padding-1];
buff3[buffer_index]<=row3[rowlength+2*padding-1];
buff1[buffer_index+1]<=row1[rowlength+2*padding-2];
buff2[buffer_index+1]<=row2[rowlength+2*padding-2];
buff3[buffer_index+1]<=row3[rowlength+2*padding-2];
buff1[buffer_index+2]<=row1[rowlength+2*padding-3];
buff2[buffer_index+2]<=row2[rowlength+2*padding-3];
buff3[buffer_index+2]<=row3[rowlength+2*padding-3];
buffer_index<=buffer_index+3;
end

endcase
end
end

always @(posedge clk) begin
if(en_in==1) begin
if(state==2) begin
for(i=2;i<rowlength+2*padding;i=i+1) begin
row1[i]<=row1[i-2];
row2[i]<=row2[i-2];
row3[i]<=row3[i-2];
end
end

else if(state==3) begin
for(i=1;i<rowlength+2*padding;i=i+1) begin
row1[i]<=row1[i-1];
row2[i]<=row2[i-1];
row3[i]<=row3[i-1];
end
end

else if(state==4) begin
for(i=3;i<rowlength+2*padding;i=i+1) begin
row1[i]<=row1[i-3];
row2[i]<=row2[i-3];
row3[i]<=row3[i-3];
end
end
end
end

always @(posedge clk) begin
if(en_in==0  || force_execute==1) begin
    if(buffer_index!=0) begin
    for(i=1;i<buffersize;i=i+1) begin
       buff1[i-1]<=buff1[i];
       buff2[i-1]<=buff2[i];
       buff3[i-1]<=buff3[i];
    end
    buffer_index<=buffer_index-1;
    out1<=buff1[0];
    out2<=buff2[0];
    out3<=buff3[0];
    enable<=1;
end
end
else begin
if(force_execute==1) begin
ready<=1;
end
enable<=0;
end
end

assign en_out= enable;
endmodule
