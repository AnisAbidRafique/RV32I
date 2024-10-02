`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2024 10:06:25 AM
// Design Name: 
// Module Name: pipe_reg
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


module pipe_reg #(parameter width_in = 32)
(
    input clk,
    input [width_in - 1 : 0] data_in,
    input rst_n,flush,
    input enable,
    output logic [width_in - 1 : 0] data_out
);

always @ (posedge clk)
begin
    if(!rst_n || flush)
        begin
        //reset registers
        data_out <= 0;
        end
    else if(enable)
        data_out <= data_in;      
end

endmodule
