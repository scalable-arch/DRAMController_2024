`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_DDR_CTRL
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // APB interface
    APB_IF.SLV                  apb_if,

    // AXI interface
    AXI_A_IF.DST                axi_ar_if,
    AXI_A_IF.DST                axi_aw_if,
    AXI_W_IF.DST                axi_w_if,
    AXI_B_IF.SRC                axi_b_if,
    AXI_R_IF.SRC                axi_r_if,

    // DFI interface
    DFI_CTRL_IF.SRC             dfi_ctrl_if,
    DFI_WR_IF.SRC               dfi_wr_if,
    DFI_RD_IF.DST               dfi_rd_if
);

    // timing parameters
    TIMING_IF                   timing_if();

    // requests to a bank
    REQ_IF                      bk_req_if_arr[`DRAM_BK_CNT](.clk(clk), .rst_n(rst_n));

    // requests to the scheduler
    BK_CTRL_IF #(`DRAM_BK_CNT)  bk_if();
    
    // scheduling output
    SCHED_IF                    sched_if();

    AXI_A_IF                    axi_aw_internal_if (.clk(clk), .rst_n(rst_n));

    // Configurations
    SAL_CFG                     u_cfg
    (
        .clk                    (clk),
        .rst_n                  (rst_n),

        .apb_if                 (apb_if),

        .timing_if              (timing_if)
    );

    SAL_WR_CTRL                 u_wr_ctrl
    (
        .clk                    (clk),
        .rst_n                  (rst_n),

        .timing_if              (timing_if),
        .sched_if               (sched_if),

        .axi_aw_if              (axi_aw_if),
        .axi_w_if               (axi_w_if),
        .axi_b_if               (axi_b_if),

        .axi_aw2_if             (axi_aw_internal_if),
        .dfi_wr_if              (dfi_wr_if)
    );

    SAL_ADDR_DECODER            u_decoder
    (
        .clk                    (clk),
        .rst_n                  (rst_n),

        .axi_ar_if              (axi_ar_if),
        .axi_aw_if              (axi_aw_internal_if),

        .req_if_arr             (bk_req_if_arr)
    );

    genvar geni;

    generate
        for (geni=0; geni<`DRAM_BK_CNT; geni=geni+1) begin  : BK
            SAL_BK_CTRL
            #(
                .BK_ID                  (geni)
            )
            u_bank_ctrl
            (
                .clk                    (clk),
                .rst_n                  (rst_n),

                .timing_if              (timing_if),

                .req_if                 (bk_req_if_arr[geni]),
                
                .bk_reqs                (bk_if.reqs[geni]),
                .bk_gnts                (bk_if.gnts[geni]),
                
                .ref_req_i              (1'b0),
                .ref_gnt_o              ()
            );
        end
    endgenerate

    SAL_SCHED                   
    #(`DRAM_BK_CNT) u_sched
    (
        .clk                    (clk),
        .rst_n                  (rst_n),
        
        .timing_if              (timing_if),
        .bk_if                  (bk_if),
        .sched_if               (sched_if)
    );

    SAL_CTRL_ENCODER            u_encoder
    (
        .clk                    (clk),
        .rst_n                  (rst_n),

        .sched_if               (sched_if),
        .dfi_ctrl_if            (dfi_ctrl_if)
    );

    SAL_RD_CTRL                 u_rd_ctrl
    (
        .clk                    (clk),
        .rst_n                  (rst_n),

        .timing_if              (timing_if),
        .sched_if               (sched_if),
        .dfi_rd_if              (dfi_rd_if),
        .axi_r_if               (axi_r_if)
    );

endmodule // SAL_DDR_CTRL
