`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2026 18:58:08
// Design Name: 
// Module Name: MaxPooling
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


module MaxPooling(input clk,input [31:0] data,input en_in,output reg  en_out,output reg [31:0] data_out);
parameter rowlength=6;
parameter pixel_width=32;
reg [2:0] state;
reg [pixel_width-1:0] row1 [(rowlength/2)-1:0];
reg [pixel_width-1:0] temp;
reg [pixel_width-1:0] temp2;
integer i;
integer index;
integer count;
initial begin
count=0;
state=0;
index=0;
end
always@(posedge clk) begin
if(en_in==1 || count==(rowlength/2)*(rowlength/2)-1) begin
case (state)

3'b000:begin
temp<=data;
state<=1;
end

3'b001: begin
row1[0]<=(data>temp)?data:temp;
if(index==(rowlength/2)-1) begin
state<=2;
index<=0;
end
else begin
state<=0;  
index<=index+1;
end
end

3'b010:begin
temp<=data;
state<=3;
end

3'b011:begin
temp2<=(temp>data)?temp:data;
state<=4;
end

3'b100:begin
temp<=data;
data_out<=(temp2>row1[(rowlength/2)-1])?temp2:row1[(rowlength/2)-1];
en_out<=1;
count<=count+1;
state<=3;
if(index==(rowlength/2)-1) begin
index<=0;
state<=1;
end
else begin
index<=index+1;
end
end
endcase
end
end

always @(posedge clk) begin
if(en_in==1) begin
if(state==1 || state==4) begin
for(i=1;i<(rowlength/2);i=i+1) begin
row1[i]<=row1[i-1];
end
end
end
end

always @(posedge clk) begin
if(en_out==1) begin
en_out<=0;  
end
end

endmodule
