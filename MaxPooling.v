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


module MaxPooling(input clk,input [31:0] data,input en_in,output en_out,output reg [31:0] data_out);
parameter rowlength=6;
parameter pixel_width=32;
reg [2:0] state;
reg [pixel_width-1:0] row1 [(rowlength/2)-1:0];
reg [pixel_width-1:0] temp;
reg [pixel_width-1:0] temp2;
integer i;
integer index;
initial begin
state=0;
index=0;
end
always@(posedge clk) begin
if(en_in==1) begin
case(state) 
3'b000:begin
temp<=data;
if(index==(rowlength/2)-1) begin
state<=1; 
index<=index+1;
end
else if(index==rowlength/2) begin
state<=2;
end
else begin
state<=1;
end
end
3'b001:begin
row1[0]<=data>temp?data:temp;
if(index==(rowlength/2)-1) begin
state<=0;
end
else begin
index<=(index==rowlength/2)?index:index+1;
state<=0;
end
end
3'b010: begin
state<=3;
temp2<=data>temp?data:temp;
end
3'b011: begin
temp<=data;
data_out<=row1[(rowlength/2)-1]>temp2?row1[(rowlength/2)-1]:temp2;
state<=2;
row1[0]<=temp2;
end

endcase
end
end

always @(posedge clk) begin
if(en_in==1) begin
if(state==1 || state==3) begin
for(i=1;i<(rowlength/2);i=i+1) begin
row1[i]<=row1[i-1];
end
end
end
end

endmodule
