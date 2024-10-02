`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2024 01:16:31 AM
// Design Name: 
// Module Name: hazard_detection
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


module hazard_detection
(
    input [4:0] id_ex_rd,if_id_rs1,if_id_rs2,
    input id_ex_MemRW,
    input PCSel_in,
    output logic if_id_write,flush_pipeline,
    output logic PC_write_enable,mux_sel
);

always_comb 
    begin
        if ((id_ex_MemRW == 1) && (id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2)) 
            begin
                PC_write_enable = 1'b0;
                if_id_write     = 1'b0;
                mux_sel         = 1'b1;
            end
        else
            begin
                PC_write_enable = 1'b1;
                if_id_write     = 1'b1;
                mux_sel         = 1'b0;
            end
        
    end
always_comb 

begin 
    if(PCSel_in)
        flush_pipeline = 1'b1;
    else
        flush_pipeline = 1'b0;
    
end

endmodule
