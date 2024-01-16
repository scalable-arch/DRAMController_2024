`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

`define DRAM_BK_CNT2 4

module SAL_SCHED
#(
    parameter   bk_cnt = 4
)
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    TIMING_IF.MON               timing_if,

    // requests from bank controllers
    BK_CTRL_IF.SCHED            bk_if,
    
    SCHED_IF.SCHED              sched_if
);

    logic                       act_req,
                                rd_req,
                                wr_req,
                                pre_req,
                                ref_req;

    wire                        is_t_rrd_met,
                                is_t_ccd_met,
                                is_t_rtw_met,
                                is_t_wtr_met;

    seq_num_t                   rd_seq_num, wr_seq_num;                            
    

 
    always_comb begin
           act_req                         = bk_if.reqs[0].act_req;
           rd_req                          = bk_if.reqs[0].rd_req;
           wr_req                          = bk_if.reqs[0].wr_req;
           pre_req                         = bk_if.reqs[0].pre_req;
           ref_req                         = bk_if.reqs[0].ref_req;
       for (int i='d1; i<`DRAM_BK_CNT; i=i+'d1) begin
           act_req                         = act_req | bk_if.reqs[i].act_req;
           rd_req                          = rd_req  | bk_if.reqs[i].rd_req;
           wr_req                          = wr_req  | bk_if.reqs[i].wr_req;
           pre_req                         = pre_req | bk_if.reqs[i].pre_req;
           ref_req                         = ref_req | bk_if.reqs[i].ref_req;
       end
    end
    
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            rd_seq_num                  <= 'd0;
            wr_seq_num                  <= 'd0;
        end
        else begin
            if (sched_if.rd_gnt == 1'b1) begin
                rd_seq_num                  <= rd_seq_num + 'd1;
            end
            if (sched_if.wr_gnt == 1'b1) begin
                wr_seq_num                  <= wr_seq_num + 'd1;
            end
        end
    end                        
                                
    always_comb begin
        for (int i=0; i<`DRAM_BK_CNT; i=i+1) begin
            bk_if.gnts[i].act_gnt                  = 1'b0;
            bk_if.gnts[i].rd_gnt                   = 1'b0;
            bk_if.gnts[i].wr_gnt                   = 1'b0;
            bk_if.gnts[i].pre_gnt                  = 1'b0;
            bk_if.gnts[i].ref_gnt                  = 1'b0;
        end
        sched_if.act_gnt                = 1'b0;
        sched_if.rd_gnt                 = 1'b0;
        sched_if.wr_gnt                 = 1'b0;
        sched_if.pre_gnt                = 1'b0;
        sched_if.ref_gnt                = 1'b0;
        sched_if.ba                     = 'hx;
        sched_if.ra                     = 'hx;
        sched_if.ca                     = 'hx;
        sched_if.id                     = 'hx;
        sched_if.len                    = 'hx;

        if (act_req & is_t_rrd_met) begin
            for (int i=0; i<`DRAM_BK_CNT; i=i+1) begin
                if (bk_if.reqs[i].act_req) begin
                    bk_if.gnts[i].act_gnt                  = 1'b1;
                    sched_if.act_gnt                = 1'b1;
                    sched_if.ba                     = i;
                    sched_if.ra                     = bk_if.reqs[i].ra;
                    break;
                end
            end
        end
        else if (rd_req & is_t_ccd_met & is_t_wtr_met) begin
            for (int i=0; i<`DRAM_BK_CNT; i=i+1) begin
                if (bk_if.reqs[i].seq_num == rd_seq_num) begin
                    bk_if.gnts[i].rd_gnt                   = 1'b1;
                    sched_if.rd_gnt                 = 1'b1;
                    sched_if.ba                     = i;
                    sched_if.ca                     = bk_if.reqs[i].ca;
                    sched_if.id                     = bk_if.reqs[i].id;
                    sched_if.len                    = bk_if.reqs[i].len;
                    break;
                end
            end
        end
        else if (wr_req & is_t_ccd_met & is_t_rtw_met) begin
            for (int i=0; i<`DRAM_BK_CNT; i=i+1) begin
                if (bk_if.reqs[i].seq_num == wr_seq_num) begin
                    bk_if.gnts[i].wr_gnt                   = 1'b1;
                    sched_if.wr_gnt                 = 1'b1;
                    sched_if.ba                     = i;
                    sched_if.ca                     = bk_if.reqs[i].ca;
                    sched_if.id                     = bk_if.reqs[i].id;
                    sched_if.len                    = bk_if.reqs[i].len;
                    break;
                end
            end
        end
        else if (pre_req) begin
            for (int i=0; i<`DRAM_BK_CNT; i=i+1) begin
                if (bk_if.reqs[i].pre_req) begin
                    bk_if.gnts[i].pre_gnt                  = 1'b1;
                    sched_if.pre_gnt                = 1'b1;
                    sched_if.ba                     = i;
                    break;
                end
            end
        end
        else if (ref_req & is_t_rrd_met) begin
            for (int i=0; i<`DRAM_BK_CNT; i=i+1) begin
                if (bk_if.reqs[i].ref_req) begin
                    bk_if.gnts[i].ref_gnt                  = 1'b1;
                    sched_if.ref_gnt                = 1'b1;
                    sched_if.ba                     = i;
                    break;
                end
            end
        end
    end

    // inter-bank
    SAL_TIMING_CNTR  #(.CNTR_WIDTH(`T_RRD_WIDTH)) u_rrd_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (sched_if.act_gnt),
        .reset_value_i              (timing_if.t_rrd_m1),
        .is_zero_o                  (is_t_rrd_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(`T_CCD_WIDTH)) u_ccd_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (sched_if.rd_gnt | sched_if.wr_gnt),
        .reset_value_i              (timing_if.t_ccd_m1),
        .is_zero_o                  (is_t_ccd_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(`T_RTW_WIDTH)) u_rtw_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (sched_if.rd_gnt),
        .reset_value_i              (timing_if.t_rtw_m1),
        .is_zero_o                  (is_t_rtw_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(`T_WTR_WIDTH)) u_wtr_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (sched_if.wr_gnt),
        .reset_value_i              (timing_if.t_wtr_m1),
        .is_zero_o                  (is_t_wtr_met)
    );
endmodule // SAL_SCHED
