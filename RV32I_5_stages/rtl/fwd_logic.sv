module fwd_logic
(
    input [4:0] ex_mem_rd,mem_wb_rd,id_ex_rs1,id_ex_rs2,
    input ex_mem_RegWEn,mem_wb_RegWEn,
    output logic [1:0] fwd_sel_A,fwd_sel_B
);

always_comb 
    begin
        //Forwarding Rs1 
         if ((ex_mem_rd == (id_ex_rs1 )) && (ex_mem_RegWEn == 1) && (ex_mem_rd != 0)) 
            begin
                    fwd_sel_A = 2'b10;    //forward ex
                    // fwd_sel_B = 2'b00;     //no forward simple
            end
        else if((mem_wb_rd == (id_ex_rs1)) && (mem_wb_RegWEn == 1) && (mem_wb_rd != 0))
            begin
                    fwd_sel_A = 2'b01;    //forward mem
                    // fwd_sel_B = 2'b00;     //no forward simple
            end
        else
            begin
                fwd_sel_A = 2'b00;     //no forward simple
                // fwd_sel_B = 2'b00;     //no forward simple
            end

        //Forwarding Rs2
        if((ex_mem_rd == (id_ex_rs2)) && (ex_mem_RegWEn == 1) && (ex_mem_rd != 0))
            begin
                    fwd_sel_B = 2'b10;    //forward ex
                    // fwd_sel_A = 2'b00;    //no forward simple
            end
        
        else if((mem_wb_rd == (id_ex_rs2)) && (mem_wb_RegWEn == 1) && (mem_wb_rd != 0))
            begin
                    fwd_sel_B = 2'b01;    //forward mem
                    // fwd_sel_A = 2'b00;     //no forward simple
            end
        else
            begin
                // fwd_sel_A = 2'b00;     //no forward simple
                fwd_sel_B = 2'b00;     //no forward simple
            end  
    end

endmodule