`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.02.2026 23:31:08
// Design Name: 
// Module Name: mem_fetch
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


module mem_fetch(input[7:0] data_in,input clk,output reg [11:0] address,output reg en_out,input wait_memfetch,output reg done);
reg init;
parameter rowlength=6;
reg  state;
reg counter;
initial begin 
    done=0;
    counter=0;
    state=0;
    en_out=0;
    init=0;   
    address=0;
end

always@(posedge clk) begin
if(wait_memfetch==0) begin
if (init ==0) begin
init<=1;
end
if (init==1) begin
address<=address+1;
if(address==rowlength*rowlength-1)begin
done<=1;
end
init<=0;
end
end
end

always@(posedge clk) begin //correct timing for line buffer
if(wait_memfetch==0) begin
case(state) 
1'b0: begin

state<=1'b1;

end

1'b1:begin
en_out<=~en_out;
end
endcase
end
end
endmodule
