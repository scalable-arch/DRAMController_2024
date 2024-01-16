`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_BK_CTRL
#(
    parameter                   BK_ID   = 0
)
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // timing parameters
    TIMING_IF.MON               timing_if,

    // request from the address decoder
    REQ_IF.DST                  req_if,

    // request to the scheduler
    output  bk_req_t            bk_reqs,
    input   bk_gnt_t            bk_gnts,
    
    // per-bank auto-refresh requests
    input   wire                ref_req_i,
    output  logic               ref_gnt_o
);

    // current row address
    dram_ra_t                   cur_ra,             cur_ra_n;
    logic   [5:0]               cnt,                cnt_n;

    wire                        is_t_rc_met,
                                is_t_ras_met,
                                is_t_rtp_met,
                                is_t_wtp_met,
                                is_row_open_met;
                                
                                                       

    // tried to make similar to the state machine
    // in the Micron dataset. Can eliminate some states
    enum    logic   [2:0]   {
        S_IDLE                  = 'd0,
        S_ACTIVATING            = 'd1,
        S_BANK_ACTIVE           = 'd2,
        S_READING               = 'd3,
        S_WRITING               = 'd4,
        S_PRECHARGING           = 'd5,
        S_REFRESHING            = 'd6
    } state,    state_n;

    always_ff @(posedge clk)
        if (~rst_n) begin
            state                   <= S_IDLE;
            cur_ra                  <= 'h0;
            cnt                     <= 'h0;
        end
        else begin
            state                   <= state_n;
            cur_ra                  <= cur_ra_n;
            cnt                     <= cnt_n;
        end

    always_comb begin
        cur_ra_n                    = cur_ra;
        state_n                     = state;
        if (cnt=='d0) begin
            cnt_n                       = 'h0;
        end
        else begin
            cnt_n                       = cnt - 'h1;
        end

        ref_gnt_o                   = 1'b0;
        req_if.ready                = 1'b0;

        bk_reqs.act_req              = 1'b0;
        bk_reqs.rd_req               = 1'b0;
        bk_reqs.wr_req               = 1'b0;
        bk_reqs.pre_req              = 1'b0;
        bk_reqs.ref_req              = 1'b0;
        bk_reqs.ra                   = 'hx;
        bk_reqs.ca                   = 'hx;
        bk_reqs.id                   = 'hx;
        bk_reqs.len                  = 'hx;

        case (state)
            S_IDLE: begin
                if (req_if.valid) begin    // a new request came
                    // ACTIVATE command
                    if (is_t_rc_met) begin
                        bk_reqs.act_req          = 1'b1;
                        bk_reqs.ra               = req_if.ra;
                        bk_reqs.seq_num          = req_if.seq_num;
                        if (bk_gnts.act_gnt) begin
                            cur_ra_n                    = req_if.ra;
                            cnt_n                       = timing_if.t_rcd_m2;
                            state_n                     = S_ACTIVATING;
                        end
                    end
                end
                else if (ref_req_i) begin
                    // AUTO-REFRESH command
                    if (is_t_rc_met) begin
                        bk_reqs.ref_req          = 1'b1;
                        if (bk_gnts.ref_gnt) begin
                            ref_gnt_o                   = 1'b1;
                            cnt_n                       = timing_if.t_rfc_m2;
                            state_n                     = S_REFRESHING;
                        end
                    end
                end
            end
            S_ACTIVATING: begin
                if (cnt=='d0) begin
                    state_n                     = S_BANK_ACTIVE;
                end
            end
            S_BANK_ACTIVE: begin
                if (req_if.valid) begin
                    if (cur_ra == req_if.ra) begin // bank hit
                        bk_reqs.ca               = req_if.ca;
                        bk_reqs.id               = req_if.id;
                        bk_reqs.len              = req_if.len;
                        bk_reqs.seq_num          = req_if.seq_num;

                        if (req_if.wr) begin
                            // WRITE command
                            bk_reqs.wr_req           = 1'b1;

                            if (bk_gnts.wr_gnt) begin
                                req_if.ready                = 1'b1;
                                cnt_n                       = timing_if.burst_cycle_m2;
                                state_n                     = S_WRITING;
                            end
                        end
                        else begin
                            // READ command
                            bk_reqs.rd_req           = 1'b1;

                            if (bk_gnts.rd_gnt) begin
                                req_if.ready                = 1'b1;
                                cnt_n                       = timing_if.burst_cycle_m2;
                                state_n                     = S_READING;
                            end
                        end
                    end
                    else begin  // bank miss
                        if (is_t_ras_met & is_t_rtp_met & is_t_wtp_met) begin
                            // PRECHARGE command
                            bk_reqs.pre_req          = 1'b1;

                            if (bk_gnts.pre_gnt) begin
                                cnt_n                       = timing_if.t_rp_m2;
                                state_n                     = S_PRECHARGING;
                            end
                        end
                    end
                end
                else begin  // no request
                    if (is_row_open_met & is_t_ras_met & is_t_rtp_met & is_t_wtp_met) begin
                        // PRECHARGE command
                        bk_reqs.pre_req          = 1'b1;

                        if (bk_gnts.pre_gnt) begin
                            cnt_n                       = timing_if.t_rp_m2;
                            state_n                     = S_PRECHARGING;
                        end
                    end
                end
            end
            S_WRITING: begin
                if (cnt=='d0) begin
                    state_n                     = S_BANK_ACTIVE;
                end
            end
            S_READING: begin
                if (cnt=='d0) begin
                    state_n                     = S_BANK_ACTIVE;
                end
            end
            S_PRECHARGING: begin
                if (cnt=='d0) begin
                    state_n                     = S_IDLE;
                end
            end
            S_REFRESHING: begin
                if (cnt=='d0) begin
                    state_n                     = S_IDLE;
                end
            end
        endcase
    end

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(`T_RC_WIDTH)) u_rc_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_gnts.act_gnt),
        .reset_value_i              (timing_if.t_rc_m1),
        .is_zero_o                  (is_t_rc_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(`T_RAS_WIDTH)) u_ras_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_gnts.act_gnt),
        .reset_value_i              (timing_if.t_ras_m1),
        .is_zero_o                  (is_t_ras_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(`T_RTP_WIDTH)) u_rtp_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_gnts.rd_gnt),
        .reset_value_i              (timing_if.t_rtp_m1),
        .is_zero_o                  (is_t_rtp_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(`T_WTP_WIDTH)) u_wtp_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_gnts.wr_gnt),
        .reset_value_i              (timing_if.t_wtp_m1),
        .is_zero_o                  (is_t_wtp_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(`ROW_OPEN_WIDTH)) u_row_open_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_gnts.rd_gnt | bk_gnts.wr_gnt),
        .reset_value_i              (timing_if.row_open_cnt),
        .is_zero_o                  (is_row_open_met)
    );

endmodule // SAL_BK_CTRL
