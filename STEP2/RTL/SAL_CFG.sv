`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_CFG
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // APB interface
    APB_IF.SLV                  apb_if,

    // timing parameters
    TIMING_IF.SRC               timing_if
);

    assign  timing_if.t_rcd_m2      = `T_RCD_VALUE_M1 - 'd1;
    assign  timing_if.t_rp_m2       = `T_RP_VALUE_M1 - 'd1;
    assign  timing_if.t_rfc_m2      = `T_RFC_VALUE_M1 - 'd1;

    assign  timing_if.t_rfc_m1      = `T_RFC_VALUE_M1;
    assign  timing_if.t_rc_m1       = `T_RC_VALUE_M1;
    assign  timing_if.t_rcd_m1      = `T_RCD_VALUE_M1;
    assign  timing_if.t_rp_m1       = `T_RP_VALUE_M1;
    assign  timing_if.t_ras_m1      = `T_RAS_VALUE_M1;
    assign  timing_if.t_rfc_m1      = `T_RFC_VALUE_M1;
    assign  timing_if.t_rtp_m1      = `T_RTP_VALUE_M1;
    assign  timing_if.t_wtp_m1      = `T_WTP_VALUE_M1;
    assign  timing_if.row_open_cnt  = `ROW_OPEN_CNT;
    assign  timing_if.burst_cycle_m2= `BURST_CYCLE_VALUE_M2;

    assign  timing_if.t_rrd_m1      = `T_RRD_VALUE_M1;
    assign  timing_if.t_ccd_m1      = `T_CCD_VALUE_M1;
    assign  timing_if.t_wtr_m1      = `T_WTR_VALUE_M1;
    assign  timing_if.t_rtw_m1      = `T_RTW_VALUE_M1;
    assign  timing_if.dfi_wren_lat  = 4'd`WRITE_LATENCY;
    assign  timing_if.dfi_rden_lat  = 4'd6;

endmodule
