`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

interface TIMING_IF ();
    // intra-bank timing
    logic   [`T_RC_WIDTH-1:0]   t_rc_m1;
    logic   [`T_RCD_WIDTH-1:0]  t_rcd_m1;
    logic   [`T_RP_WIDTH-1:0]   t_rp_m1;
    logic   [`T_RAS_WIDTH-1:0]  t_ras_m1;
    logic   [`T_RFC_WIDTH-1:0]  t_rfc_m1;
    logic   [`T_RTP_WIDTH-1:0]  t_rtp_m1;
    logic   [`T_WTP_WIDTH-1:0]  t_wtp_m1;
    logic   [`ROW_OPEN_WIDTH-1:0]row_open_cnt;
    // inter-bank timing
    logic   [`T_RRD_WIDTH-1:0]  t_rrd_m1;
    logic   [`T_CCD_WIDTH-1:0]  t_ccd_m1;
    logic   [`T_WTR_WIDTH-1:0]  t_wtr_m1;
    logic   [`T_RTW_WIDTH-1:0]  t_rtw_m1;
    logic   [3:0]               dfi_wren_lat;
    logic   [3:0]               dfi_rden_lat;

    // synthesizable, for design
    modport SRC (
        output                  t_rc_m1, t_rcd_m1, t_rp_m1, t_ras_m1, t_rfc_m1, t_rtp_m1, t_wtp_m1, row_open_cnt,
                                t_rrd_m1, t_ccd_m1, t_wtr_m1, t_rtw_m1, dfi_wren_lat, dfi_rden_lat
    );
    modport MON (
        input                   t_rc_m1, t_rcd_m1, t_rp_m1, t_ras_m1, t_rfc_m1, t_rtp_m1, t_wtp_m1, row_open_cnt,
                                t_rrd_m1, t_ccd_m1, t_wtr_m1, t_rtw_m1, dfi_wren_lat, dfi_rden_lat
    );
endinterface

interface REQ_IF
(
    input                       clk,
    input                       rst_n
);
    logic                       valid;
    logic                       ready;
    logic   [`AXI_ID_WIDTH-1:0] id;
    logic   [`DRAM_RA_WIDTH-1:0]ra;
    logic   [`DRAM_CA_WIDTH-1:0]ca;
    logic                       wr;
    logic   [`AXI_LEN_WIDTH-1:0]len;

    // synthesizable, for design
    modport SRC (
        output                  valid, id, ra, ca, wr, len,
        input                   ready
    );
    modport DST (
        input                   valid, id, ra, ca, wr, len,
        output                  ready
    );

    // for verification only
    // synthesis translate_off
    clocking SRC_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        output                  valid, id, ra, ca, wr, len;
        input                   ready;
    endclocking

    clocking DST_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        input                   valid, id, ra, ca, wr, len;
        output                  ready;
    endclocking

    clocking MON_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        input                   valid, id, ra, ca, wr, len;
        input                   ready;
    endclocking

    modport SRC_TB (clocking SRC_CB, input clk, rst_n);
    modport DST_TB (clocking DST_CB, input clk, rst_n);

    function void init();   // does not consume timing
        valid                       = 1'b0;
        id                          = 'hx;
        ra                          = 'hx;
        ca                          = 'hx;
        wr                          = 'hx;
        len                         = 'hx;
    endfunction

    task automatic transfer(  input [`AXI_ID_WIDTH-1:0]     id,
                              input [`DRAM_RA_WIDTH-1:0]    ra,
                              input [`DRAM_CA_WIDTH-1:0]    ca,
                              input                         wr,
                              input [`AXI_LEN_WIDTH-1:0]    len);
        SRC_CB.valid                <= 1'b1;
        SRC_CB.id                   <= id;
        SRC_CB.ra                   <= ra;
        SRC_CB.ca                   <= ca;
        SRC_CB.wr                   <= wr;
        SRC_CB.len                  <= len;
        @(posedge clk);
        while (ready!=1'b1) begin
            @(posedge clk);
        end
        SRC_CB.valid                <= 1'b0;
        SRC_CB.id                   <= 'hx;
        SRC_CB.ra                   <= 'hx;
        SRC_CB.ca                   <= 'hx;
        SRC_CB.wr                   <= 'hx;
        SRC_CB.len                  <= 'hx;
    endtask
    // synthesis translate_on
endinterface

interface SCHED_IF ();
    logic                       act_req; // reqs are not used in STEP1
    logic                       rd_req;
    logic                       wr_req;
    logic                       pre_req;
    logic                       ref_req;
    logic                       act_gnt;
    logic                       rd_gnt;
    logic                       wr_gnt;
    logic                       pre_gnt;
    logic                       ref_gnt;
    logic   [`DRAM_BA_WIDTH-1:0]ba;
    logic   [`DRAM_RA_WIDTH-1:0]ra;
    logic   [`DRAM_CA_WIDTH-1:0]ca;
    logic   [`AXI_ID_WIDTH-1:0] id;
    logic   [`AXI_LEN_WIDTH-1:0]len;

    // synthesizable, for design
    // SRC
    modport BK_CTRL (
        output                  ba, ra, ca, id, len,
        output                  act_gnt, rd_gnt, wr_gnt, pre_gnt, ref_gnt
    );
    // DST
    modport CTRL_ENCODER (
        input                   ba, ra, ca,
        input                   act_gnt, rd_gnt, wr_gnt, pre_gnt, ref_gnt
    );
    // MON
    modport MON (
        input                   act_req, rd_req, wr_req, pre_req, ref_req, ba, ra, ca, id, len,
        input                   act_gnt, rd_gnt, wr_gnt, pre_gnt, ref_gnt
    );
    modport RD_CTRL (
        input                   id, len,
        input                   rd_gnt
    );
    modport WR_CTRL (
        input                   wr_gnt
    );
endinterface

