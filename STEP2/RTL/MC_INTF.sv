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

    logic   [`T_RCD_WIDTH-1:0]  t_rcd_m2;
    logic   [`T_RP_WIDTH-1:0]   t_rp_m2;
    logic   [`T_RFC_WIDTH-1:0]  t_rfc_m2;

    // inter-bank timing
    logic   [`T_RRD_WIDTH-1:0]  t_rrd_m1;
    logic   [`T_CCD_WIDTH-1:0]  t_ccd_m1;
    logic   [`T_WTR_WIDTH-1:0]  t_wtr_m1;
    logic   [`T_RTW_WIDTH-1:0]  t_rtw_m1;
    logic   [3:0]               dfi_wren_lat;
    logic   [3:0]               dfi_rden_lat;
    logic   [`BURST_CYCLE_WIDTH-1:0]burst_cycle_m2;

    // synthesizable, for design
    modport SRC (
        output                  t_rc_m1, t_rcd_m1, t_rp_m1, t_ras_m1, t_rfc_m1, t_rtp_m1, t_wtp_m1, row_open_cnt,
                                t_rcd_m2, t_rp_m2, t_rfc_m2,
                                t_rrd_m1, t_ccd_m1, t_wtr_m1, t_rtw_m1, dfi_wren_lat, dfi_rden_lat, burst_cycle_m2
    );
    modport MON (
        input                   t_rc_m1, t_rcd_m1, t_rp_m1, t_ras_m1, t_rfc_m1, t_rtp_m1, t_wtp_m1, row_open_cnt,
                                t_rcd_m2, t_rp_m2, t_rfc_m2,
                                t_rrd_m1, t_ccd_m1, t_wtr_m1, t_rtw_m1, dfi_wren_lat, dfi_rden_lat, burst_cycle_m2
    );
endinterface

interface REQ_IF
(
    input                       clk,
    input                       rst_n
);
    logic                       valid;
    logic                       ready;
    logic                       wr;
    axi_id_t                    id;
    axi_len_t                   len;
    seq_num_t                   seq_num;
    dram_ra_t                   ra;
    dram_ca_t                   ca;

    // synthesizable, for design
    modport SRC (
        output                  valid, wr, id, len, seq_num, ra, ca,
        input                   ready
    );
    modport DST (
        input                   valid, wr, id, len, seq_num, ra, ca,
        output                  ready
    );

    // for verification only
    // synthesis translate_off
    clocking SRC_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        output                  valid, wr, id, len, seq_num, ra, ca;
        input                   ready;
    endclocking

    clocking DST_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        input                   valid, wr, id, len, seq_num, ra, ca;
        output                  ready;
    endclocking

    clocking MON_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        input                   valid, wr, id, len, seq_num, ra, ca;
        input                   ready;
    endclocking

    modport SRC_TB (clocking SRC_CB, input clk, rst_n);
    modport DST_TB (clocking DST_CB, input clk, rst_n);

    function void init();   // does not consume timing
        valid                       = 1'b0;
        wr                          = 'hx;
        len                         = 'hx;
        seq_num                     = 'hx;
        id                          = 'hx;
        ra                          = 'hx;
        ca                          = 'hx;
    endfunction

    task automatic transfer(
        input                       wr,
        input   axi_id_t            id,
        input   axi_len_t           len,
        input   seq_num_t           seq_num,
        dram_ra_t                   ra,
        dram_ca_t                   ca
    );
        SRC_CB.valid                <= 1'b1;
        SRC_CB.wr                   <= wr;
        SRC_CB.id                   <= id;
        SRC_CB.len                  <= len;
        SRC_CB.seq_num              <= seq_num;
        SRC_CB.ra                   <= ra;
        SRC_CB.ca                   <= ca;
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


typedef struct packed {
    logic                       act_req;
    logic                       rd_req;
    logic                       wr_req;
    logic                       pre_req;
    logic                       ref_req;
    dram_ba_t                   ba;
    dram_ra_t                   ra;
    dram_ca_t                   ca;
    seq_num_t                   seq_num;
    axi_id_t                    id;
    axi_len_t                   len;
} bk_req_t;

typedef struct packed {
    logic                       act_gnt;
    logic                       rd_gnt;
    logic                       wr_gnt;
    logic                       pre_gnt;
    logic                       ref_gnt;
} bk_gnt_t;

interface BK_CTRL_IF #(
    parameter   BK_CNT = 1
);
    bk_req_t [BK_CNT-1:0]       reqs;
    bk_gnt_t [BK_CNT-1:0]       gnts;

    // synthesizable, for design
    modport BK ( // requests to the scheduler (not be used)
        output                  reqs,
        input                   gnts
    );
    modport SCHED ( // grants to bank controllers
        input                   reqs,
        output                  gnts
    );
    modport MON (
        input                   reqs,
        input                   gnts 
    );
endinterface

interface SCHED_IF ();
    logic                       act_gnt;
    logic                       rd_gnt;
    logic                       wr_gnt;
    logic                       pre_gnt;
    logic                       ref_gnt;
    dram_ba_t                   ba;
    dram_ra_t                   ra;
    dram_ca_t                   ca;
    seq_num_t                   seq_num;
    axi_id_t                    id;
    axi_len_t                   len;

    // synthesizable, for design
    modport SCHED (
        output                  ba, ra, ca, id, len,
        output                  act_gnt, rd_gnt, wr_gnt, pre_gnt, ref_gnt
    );
    modport CTRL_ENCODER (
        input                   ba, ra, ca,
        output                  act_gnt, rd_gnt, wr_gnt, pre_gnt, ref_gnt
    );
    
    modport RD_CTRL (
        input                   id, len,
        input                   rd_gnt
    );
    modport WR_CTRL (
        input                   wr_gnt
    );
    modport MON (
        input                   ba, ra, ca, id, len,
        input                   act_gnt, rd_gnt, wr_gnt, pre_gnt, ref_gnt
    );
endinterface

