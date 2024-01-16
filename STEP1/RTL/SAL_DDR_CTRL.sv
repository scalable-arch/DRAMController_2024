`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_DDR_CTRL
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // APB interface
    APB_IF.DST                  apb_if,

    // request interface
    REQ_IF.DST                  req_if,
    AXI_W_IF.DST                axi_w_if,
    AXI_R_IF.SRC                axi_r_if,

    // DFI interface
    DFI_CTRL_IF.SRC             dfi_ctrl_if,
    DFI_WR_IF.SRC               dfi_wr_if,
    DFI_RD_IF.DST               dfi_rd_if
);

    // timing parameters
    TIMING_IF                   timing_if();

    // request to a bank
    // scheduling output
    SCHED_IF                    sched_if();

    // Configurations
    SAL_CFG                         u_cfg
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .apb_if                     (apb_if),

        .timing_if                  (timing_if)
    );

    SAL_BK_CTRL                     u_bank_ctrl
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .timing_if                  (timing_if),

        .req_if                     (req_if),
        .sched_if                   (sched_if),

        .ref_req_i                  (1'b0),
        .ref_gnt_o                  ()
    );

    SAL_CTRL_ENCODER                u_encoder
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .sched_if                   (sched_if),
        .dfi_ctrl_if                (dfi_ctrl_if)
    );

    SAL_WR_CTRL                     u_wr_ctrl
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .axi_w_if                   (axi_w_if),
        .timing_if                  (timing_if),
        .sched_if                   (sched_if),

        .dfi_wr_if                  (dfi_wr_if)
    );

    SAL_RD_CTRL                     u_rd_ctrl
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .timing_if                  (timing_if),
        .sched_if                   (sched_if),
        .dfi_rd_if                  (dfi_rd_if),
        .axi_r_if                   (axi_r_if)
    );

endmodule // SAL_DDR_CTRL
