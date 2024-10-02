`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2024 06:58:15 AM
// Design Name: 
// Module Name: branch_control_unit
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


module branch_control_unit(
    input PCSel_in,
    input [8:0] instr,
    input B_flag,Eq,Lt,
    output logic PCSel_out
    );

    always_comb
        begin
            if(B_flag)
                begin
                    casex (instr)
                        9'bx00011000 : //beq
                        begin
                            if(Eq) 
                                PCSel_out = 1'b1;
                            else
                                PCSel_out = 1'b0;
                        end
                        9'bx00111000 :    //bne
                        begin
                            if(!Eq)     
                                PCSel_out = 1'b1;
                            else
                                PCSel_out = 1'b0;
                        end
                        9'bx10011000 : //blt
                        begin
                            if(Lt)     
                                PCSel_out = 1'b1;
                            else
                                PCSel_out = 1'b0;
                        end
                        9'bx11011000 : //bltu
                        begin
                            if(Lt)     
                                PCSel_out = 1'b1;
                            else
                                PCSel_out = 1'b0;
                        end
                        default: PCSel_out = PCSel_in;
                    endcase
                end
            else
                begin
                    PCSel_out = PCSel_in;
                end
        end
endmodule
// if(Eq && instr == 9'bx00011000)     //beq
//                         PCSel_out = 1'b1;

//                     if(!Eq && instr == 9'bx00111000)    //bne
//                         PCSel_out = 1'b1;               

//                     if(Lt && instr == 9'bx10011000)     //blt
//                         PCSel_out = 1'b1;

//                     if(Lt && instr == 9'bx11011000)     //bltu
//                         PCSel_out = 1'b1;