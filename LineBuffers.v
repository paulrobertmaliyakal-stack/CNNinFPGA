`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2026 19:26:24
// Design Name: 
// Module Name: LineBuffers
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


module LineBuffers(input [7:0] data_in,input en_in,output reg en_out,input clk,output reg [7:0] data_out1,output reg [7:0] data_out2,output reg [7:0] data_out3,output reg wait_memfetch,input done);
parameter rowlength=6;
parameter kernelsize=3;
parameter imagewidth=8;
parameter padding =1;
reg [7:0] temp_data;
reg force_execute;
reg [imagewidth-1:0] linebuffer1 [0:rowlength+2*padding-1];
reg [imagewidth-1:0] linebuffer2 [0:rowlength+2*padding-1];
reg [imagewidth-1:0] linebuffer3 [0:rowlength+2*padding-1];
reg [7:0] index1;
reg [7:0] index2;
reg [7:0] index3;
reg [1:0] state;
reg finish;
integer i;
initial begin
finish=0;
force_execute=0;
state=0;
for (i=0;i<rowlength+2*padding;i=i+1) begin
linebuffer1[i]=0; // since padding=1
end
linebuffer2[0]=0; // padding
linebuffer2[rowlength+2*padding-1]=0;
linebuffer3[0]=0;
linebuffer3[rowlength+2*padding-1]=0;
index1=0;
index2=rowlength+2*padding-2;
index3=rowlength+2*padding-2;
wait_memfetch =0;
end
always@(posedge clk) begin
    if ((en_in==1 || force_execute==1)&& finish==0)begin

case (state)

2'b00:begin   // fill the row2 of the line buffer as padding is 1 and row 1 is initialized with 0
linebuffer2[index2]<=data_in;
if(index2==1) begin
state<=2'b01;
end
else begin
index2<=index2-1;
end
end

2'b01: begin   //fill the row 3 
linebuffer3[index3]<=data_in;
if(index3==1) begin
state<=2'b10;
end
index3<=index3-1;
end 

2'b10:begin   // simultaneosly fetching and sending data to next stage
en_out<=1;
data_out1<=linebuffer1[rowlength+2*padding-1];
data_out2<=linebuffer2[rowlength+2*padding-1];
data_out3<=linebuffer3[rowlength+2*padding-1];

for(i=1;i<rowlength+2*padding;i=i+1) begin
linebuffer1[i]<=linebuffer1[i-1];
linebuffer2[i]<=linebuffer2[i-1];
linebuffer3[i]<=linebuffer3[i-1];
end

linebuffer1[0]<=linebuffer2[rowlength+2*padding-1];
linebuffer2[0]<=linebuffer3[rowlength+2*padding-1];

//deciding the pixel to dump into the line buffer
if(force_execute==1 && done==1) begin
state<=2'b11;
linebuffer3[0]<=0;
index1<=index1+1;
if(index1==2*(rowlength+2*padding)+1) begin
finish<=1;
en_out<=0;
end
end

else if((index3==0 || index3==rowlength+2*padding-1 )&& force_execute==0)begin
wait_memfetch<=1;
linebuffer3[0]<=0;
temp_data<=data_in;
end
else if(force_execute==1 && done==0) begin
if(index3==1)begin
linebuffer3[0]<=temp_data;
end
if(index3==0) begin
linebuffer3[0]<=0;
end
end

else begin
linebuffer3[0]<=data_in;
end
//------------------
//updating index3
if(index3==rowlength+2*padding-1) begin
index3<=0;
end
else begin
index3<=index3+1;
end
//---------------
end

2'b11:begin  //just a delay state
state<=2'b10;
end
endcase
end
end

always@(posedge clk)begin
if(wait_memfetch==1)begin
case(force_execute)
1'b0: begin
force_execute<=1;
end
1'b1:begin
if(index3==1 && done==0) begin
force_execute<=0;
wait_memfetch<=0;
end
end
endcase
end
end

always @(posedge clk) begin
if((en_out==1 && force_execute==0)||state==3) begin
en_out<=0;
end
end

endmodule
