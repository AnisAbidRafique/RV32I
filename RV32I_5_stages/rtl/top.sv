module top
(
    input clk,
    input rst_n
);

logic [32 -1:0] mux_out_A;
logic [32 -1:0] mux_out_B;
logic [32 -1:0] PC_mux_out;
logic [31:0] instr_addr,instr_addr_reg,instr_addr_reg_ex,instr_addr_reg_mem,instr_addr_reg_wb;
logic    [32 - 1:0] Result,Result_reg_mem,Result_reg_wb;
//logic [PROG_VALUE - 1:0] addr;
logic [32 - 1 :0] A_out;

logic [32 - 1 : 0] operand,data2,data1,data1_reg_ex,data2_reg_ex,data2_reg_mem;
logic [31:0] dataR,operand_reg_ex,dataR_reg_wb; 
logic [31:0] MUX_4_1_in;
logic [31:0] ALU_out_mux,FWD_B_out_mux,FWD_A_out_mux,FWD_B_out_mux_mem;
logic BrUn,BrLT,BrEq,RegWEn,MemRW,PCSel,ASel,BSel,RegWEn_reg_ctrl_wb;
logic BrEq_reg_ctrl_id,BrLT_reg_ctrl_id,BrUn_reg_ctrl_id,BrEq_reg_ctrl_ex;
logic BrLT_reg_ctrl_ex,BrUn_reg_ctrl_ex,ASel_reg_ctrl_ex,MemRW_reg_ctrl_mem;
logic ASel_reg_ctrl_id,BSel_reg_ctrl_id,MemRW_reg_ctrl_id,MemRW_reg_ctrl_ex;
logic RegWEn_reg_ctrl_id,BSel_reg_ctrl_ex,RegWEn_reg_ctrl_ex,RegWEn_reg_ctrl_mem;
logic PC_write_enable,ctrl_mux_sel,if_id_write_out,flush_pipeline;

logic [3:0] ALUSel,ALUSel_reg_ctrl_id,ALUSel_reg_ctrl_ex;
logic [2:0] ImmSel,ImmSel_reg_ctrl_id,hazard_mux_out;
logic [1:0] WBSel,WBSel_reg_ctrl_id,WBSel_reg_ctrl_ex,WBSel_reg_ctrl_mem,WBSel_reg_ctrl_wb;
logic [31:0] pc_in;
logic [31:0] pc_reg,pc_reg_ex,pc_reg_mem,pc_reg_wb;
logic [1:0] fwd_sel_A,fwd_sel_B;
logic PCSel_reg_ctrl_id,PCSel_reg_ctrl_ex,B_flag_ctrl_id,B_flag_ctrl_ex;
logic PCSel_out_ex;

//IF Stage//

pipe_reg #(.width_in()) uPC_ID
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(if_id_write_out),
    .flush(flush_pipeline),
    .data_in(A_out),
    .data_out(pc_reg)
);

pipe_reg #(.width_in()) uinst_ID
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(if_id_write_out),
    .flush(flush_pipeline),
    .data_in(instr_addr),
    .data_out(instr_addr_reg)
);

MUX_2_1#(.BUS_WIDTH()) uMUX_pc
(
    .in_1(MUX_4_1_in),
    .in_2(Result),
    .BSel(PCSel_out_ex),
    .mux_out(pc_in)
);

program_counter#(.PROG_VALUE()) pc
(    .clk(clk),
     .rst_n(rst_n),
     .PCWrite(PC_write_enable),
     .pc_in(pc_in),
     .MUX_4_1_in(MUX_4_1_in),
     .A_out(A_out)
);

instruction#(.IMEM_DEPTH(),.PROG_VALUE ()) uinst
(    .addr(A_out - 32'h8000_0000),
     .instr_addr(instr_addr)
);

//ID Stage//

control_unit ucrtl_unit
(
    .Inst({instr_addr_reg[30],instr_addr_reg[14:12],instr_addr_reg[6:2]}),
    .BrEq(BrEq_reg_ctrl_ex),
    .BrLT(BrLT_reg_ctrl_ex),
    .PCSel(PCSel_reg_ctrl_id),
    .BrUn(BrUn_reg_ctrl_id),
    .ASel(ASel_reg_ctrl_id),
    .BSel(BSel_reg_ctrl_id),
    .MemRW(MemRW_reg_ctrl_id),
    .RegWEn(RegWEn_reg_ctrl_id),
    .B_flag(B_flag_ctrl_id),
    .ImmSel(ImmSel_reg_ctrl_id),
    .ALUSel(ALUSel_reg_ctrl_id),
    .WBSel(WBSel_reg_ctrl_id)
);

pipe_reg #(.width_in(1)) uBflag_EX
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(flush_pipeline),
    .data_in(B_flag_ctrl_id),
    .data_out(B_flag_ctrl_ex)
);

pipe_reg #(.width_in(1)) uPCSel_EX
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(flush_pipeline),
    .data_in(PCSel_reg_ctrl_id),
    .data_out(PCSel_reg_ctrl_ex)
);

pipe_reg #(.width_in()) uPC_EX
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(flush_pipeline),
    .data_in(pc_reg),
    .data_out(pc_reg_ex)
);

pipe_reg #(.width_in()) urs1_EX
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(flush_pipeline),
    .data_in(data1),
    .data_out(data1_reg_ex)
);

pipe_reg #(.width_in()) urs2_EX
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(flush_pipeline),
    .data_in(data2),
    .data_out(data2_reg_ex)
);

pipe_reg #(.width_in()) uimm_EX
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(flush_pipeline),
    .data_in(operand),
    .data_out(operand_reg_ex)
);

pipe_reg #(.width_in()) uinst_EX
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(flush_pipeline),
    .data_in(instr_addr_reg),
    .data_out(instr_addr_reg_ex)
);

////control signals////
pipe_reg #(.width_in(4)) uALUSel_EX
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(flush_pipeline),
    .data_in(ALUSel_reg_ctrl_id),
    .data_out(ALUSel_reg_ctrl_ex)
);
pipe_reg #(.width_in(2)) uWBSel_EX
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(flush_pipeline ),
    .data_in(WBSel_reg_ctrl_id),
    .data_out(WBSel_reg_ctrl_ex)
);
pipe_reg #(.width_in(1)) uBrUn_EX
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(flush_pipeline),
    .data_in(BrUn_reg_ctrl_id),
    .data_out(BrUn_reg_ctrl_ex)
);
pipe_reg #(.width_in(1)) uASel_EX
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(flush_pipeline),
    .data_in(ASel_reg_ctrl_id),
    .data_out(ASel_reg_ctrl_ex)
);
pipe_reg #(.width_in(1)) uBSel_EX
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(flush_pipeline),
    .data_in(BSel_reg_ctrl_id),
    .data_out(BSel_reg_ctrl_ex)
);
pipe_reg #(.width_in(1)) uMemRW_EX
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(flush_pipeline ),
    .data_in(hazard_mux_out[0]),
    .data_out(MemRW_reg_ctrl_ex)
);
pipe_reg #(.width_in(1)) uRegWEn_EX
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(flush_pipeline),
    .data_in(hazard_mux_out[1]),
    .data_out(RegWEn_reg_ctrl_ex)
);
//Modules//
register_file#(.REGF_WIDTH(),.SELECTORS())ureg
(   .clk(clk),
    .rst_n(rst_n),
    .rsW(instr_addr_reg_wb[11:7]),
    .rs1(instr_addr_reg[19:15]),
    .rs2(instr_addr_reg[24:20]),
    .RegWEn(RegWEn_reg_ctrl_wb),
    .rd(ALU_out_mux),
    .data1(data1),
    .data2(data2)
);

imm_gen img
(
    .instr_addr(instr_addr_reg),
    .ImmSel(ImmSel_reg_ctrl_id),
    .operand(operand)
);

hazard_detection uhazard_detector
(
    .id_ex_rd(instr_addr_reg_ex[11:7]),
    .if_id_rs1(instr_addr_reg[19:15]),
    .if_id_rs2(instr_addr_reg[24:20]),
    .id_ex_MemRW(MemRW_reg_ctrl_ex),
    .if_id_write(if_id_write_out),
    .PC_write_enable(PC_write_enable),
    .mux_sel(ctrl_mux_sel),
    .PCSel_in(PCSel_out_ex),
    .flush_pipeline(flush_pipeline)
);
MUX_2_1#(.BUS_WIDTH(2)) uMUX_Hazard
(
    .in_1({RegWEn_reg_ctrl_id,MemRW_reg_ctrl_id}), //reg
    .in_2(2'b00),
    .BSel(ctrl_mux_sel),
    .mux_out(hazard_mux_out)
);

//EX Stage//

pipe_reg #(.width_in()) uPC_MEM
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(1'b0),
    .data_in(pc_reg_ex),
    .data_out(pc_reg_mem)
);

pipe_reg #(.width_in()) ualu_MEM
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(1'b0),
    .data_in(Result),
    .data_out(Result_reg_mem)
);

pipe_reg #(.width_in()) urs2_MEM
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(1'b0),
    .data_in(data2_reg_ex),
    .data_out(data2_reg_mem)
);

pipe_reg #(.width_in()) urs2_forward_B_MEM
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(1'b0),
    .data_in(FWD_B_out_mux),
    .data_out(FWD_B_out_mux_mem)
);

pipe_reg #(.width_in()) uinst_MEM
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(1'b0),
    .data_in(instr_addr_reg_ex),
    .data_out(instr_addr_reg_mem)
);

//control signals//
pipe_reg #(.width_in(2)) uWBSel_MEM
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(1'b0),
    .data_in(WBSel_reg_ctrl_ex),
    .data_out(WBSel_reg_ctrl_mem)
);

pipe_reg #(.width_in(1)) uMemRW_MEM
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(1'b0),
    .data_in(MemRW_reg_ctrl_ex),
    .data_out(MemRW_reg_ctrl_mem)
);
pipe_reg #(.width_in(1)) uRegWEn_MEM
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(1'b0),
    .data_in(RegWEn_reg_ctrl_ex),
    .data_out(RegWEn_reg_ctrl_mem)
);

//Modules//
branch_control_unit ubranchctrl
(
    .PCSel_in(PCSel_reg_ctrl_ex),
    .B_flag(B_flag_ctrl_ex),
    .Eq(BrEq_reg_ctrl_ex),
    .Lt(BrLT_reg_ctrl_ex),
    .instr({instr_addr_reg_ex[30],instr_addr_reg_ex[14:12],instr_addr_reg_ex[6:2]}),
    .PCSel_out(PCSel_out_ex)
);
branch_comp ubranch_comp
(
    .A(FWD_A_out_mux),
    .B(FWD_B_out_mux),
    .BrUn(BrUn_reg_ctrl_ex),
    .Eq(BrEq_reg_ctrl_ex),
    .Lt(BrLT_reg_ctrl_ex)
);

//////////////for forwarding/////////////
MUX_4_1#(.BUS_WIDTH ()) uForward_A_mux
(
    // .in_1(data1_reg_ex),
    .in_1(data1_reg_ex),
    .in_2(ALU_out_mux),
    .in_3(Result_reg_mem),
    .Sel(fwd_sel_A),
    .mux_out(FWD_A_out_mux)
);

MUX_4_1#(.BUS_WIDTH ()) uForward_B_mux
(
    // .in_1(data2_reg_ex),
    .in_1(data2_reg_ex),
    .in_2(ALU_out_mux),
    .in_3(Result_reg_mem),
    .Sel(fwd_sel_B),
    .mux_out(FWD_B_out_mux)
);

fwd_logic ufwd_comb_inst
(
    .ex_mem_rd(instr_addr_reg_mem[11:7]),
    .mem_wb_rd(instr_addr_reg_wb[11:7]),
    .id_ex_rs1(instr_addr_reg_ex[19:15]),
    .id_ex_rs2(instr_addr_reg_ex[24:20]),
    .ex_mem_RegWEn(RegWEn_reg_ctrl_mem),
    .mem_wb_RegWEn(RegWEn_reg_ctrl_wb),
    .fwd_sel_A(fwd_sel_A),
    .fwd_sel_B(fwd_sel_B)
);

///////////////

MUX_2_1#(.BUS_WIDTH()) uMUX_A
(
    .in_1(FWD_A_out_mux),
    .in_2(pc_reg_ex),
    .BSel(ASel_reg_ctrl_ex),
    .mux_out(mux_out_A)
);

MUX_2_1#(.BUS_WIDTH()) uMUX_B
(
    .in_1(FWD_B_out_mux),
    .in_2(operand_reg_ex),
    .BSel(BSel_reg_ctrl_ex),
    .mux_out(mux_out_B)
);
    

alu#(.ALU_WIDTH()) ualu
(
     .data1(mux_out_A),
     .data2(mux_out_B),
     .ALUSel(ALUSel_reg_ctrl_ex),
     .Result(Result)
);



//MEM Stage//

pipe_reg #(.width_in()) upc_4_WB
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(1'b0),
    .data_in(pc_reg_mem + 4), //pc+4
    .data_out(pc_reg_wb)
);

pipe_reg #(.width_in()) ualu_WB
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(1'b0),
    .data_in(Result_reg_mem),
    .data_out(Result_reg_wb)
);

pipe_reg #(.width_in()) umem_WB
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(1'b0),
    .data_in(dataR),
    .data_out(dataR_reg_wb)
);

pipe_reg #(.width_in()) uinst_WB
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(1'b0),
    .data_in(instr_addr_reg_mem),
    .data_out(instr_addr_reg_wb)
);
//Control signals//
pipe_reg #(.width_in(2)) uWBSel_WB
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(1'b0),
    .data_in(WBSel_reg_ctrl_mem),
    .data_out(WBSel_reg_ctrl_wb)
);
pipe_reg #(.width_in(1)) uRegWEn_WB
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(1'b1),
    .flush(1'b0),
    .data_in(RegWEn_reg_ctrl_mem),
    .data_out(RegWEn_reg_ctrl_wb)
);
//Modules//
data_mem#(.IMEM_DEPTH(),.PROG_VALUE()) udatamem_inst
(
    .addr(Result_reg_mem),
    .dataW(FWD_B_out_mux_mem),
    .MemRW(MemRW_reg_ctrl_mem),
    .clk(clk),
    .funct3(instr_addr_reg_mem[14:12]),
    .dataR(dataR)
);


//WB Stage//

MUX_4_1#(.BUS_WIDTH ()) uALU_out_mux
(
    .in_1(dataR_reg_wb),
    .in_2(Result_reg_wb),
    .in_3(pc_reg_wb),
    .Sel(WBSel_reg_ctrl_wb),
    .mux_out(ALU_out_mux)
);

//Please uncomment for checking thanks



    logic [31:0]  data1_2,data1_3,data2_2,data2_3,next_addr_1,next_addr_2,next_addr_3,next_addr_4,current_addr_1,current_addr_2,current_addr_3,current_addr_4;




always_ff @( posedge clk ) 
begin
    data1_2 <= data1_reg_ex;
    data1_3 <= data1_2;

    data2_2 <= data2_reg_ex;
    data2_3 <= data2_2;

    next_addr_1    <= pc_in;
    next_addr_2    <= next_addr_1;
    next_addr_3    <= next_addr_2;
    next_addr_4    <= next_addr_3;

    current_addr_1 <= A_out;
    current_addr_2 <= current_addr_1;
    current_addr_3 <= current_addr_2;
    current_addr_4 <= current_addr_3;
    
end

tracer tracer_ip (
                   .clk_i(clk),
                   .rst_ni(rst_n),
                   .hart_id_i(32'b0),

                   .rvfi_valid(1'b1),
                   .rvfi_insn_t(instr_addr_reg_wb),
                   .rvfi_rs1_addr_t(instr_addr_reg_wb[19:15]),
                   .rvfi_rs2_addr_t(instr_addr_reg_wb[24:20]),

                   .rvfi_rs1_rdata_t(data1_3),
                   .rvfi_rs2_rdata_t(data2_3),

                   .rvfi_rd_addr_t(instr_addr_reg_wb[11:7]) ,
                   .rvfi_rd_wdata_t(ALU_out_mux),
                   .rvfi_pc_rdata_t(current_addr_4),               
                   .rvfi_pc_wdata_t(next_addr_4),     
                   .rvfi_mem_addr(0),
                   .rvfi_mem_rmask(0),
                   .rvfi_mem_wmask(0),
                   .rvfi_mem_rdata(0),
                   .rvfi_mem_wdata(0)
               );

endmodule
