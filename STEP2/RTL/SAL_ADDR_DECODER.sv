`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_ADDR_DECODER
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // request from the AXI side
    AXI_A_IF.DST                axi_ar_if,
    AXI_A_IF.DST                axi_aw_if,

    // requests to bank controllers
    REQ_IF.SRC                  req_if_arr[`DRAM_BK_CNT]
);

    logic                       valid;
    logic                       wr;
    axi_id_t                    id;
    axi_len_t                   len;
    dram_ba_t                   ba;
    dram_ra_t                   ra;
    dram_ca_t                   ca;

    seq_num_t                   seq_num,    rd_seq_num, wr_seq_num;

    always_comb begin
        valid                       = 1'b0;
        wr                          = 'bx;
        id                          = 'hx;
        len                         = 'hx;
        seq_num                     = 'hx;
        ba                          = 'hx;
        ra                          = 'hx;
        ca                          = 'hx;

        // temporary AW takes precedency over AR
        // because AW has buffered its data in W and has waited longer
        //
        // TODO: Support concurrent requests from AW and AR
        //       if they target different banks
        if (axi_aw_if.avalid) begin
            // WR (addr/data) are ready
            valid                       = 1'b1;
            wr                          = 1'b1;
            id                          = axi_aw_if.aid;
            len                         = axi_aw_if.alen;
            seq_num                     = wr_seq_num;
            ba                          = get_dram_ba(axi_aw_if.aaddr);
            ra                          = get_dram_ra(axi_aw_if.aaddr);
            ca                          = get_dram_ca(axi_aw_if.aaddr);
        end
        else if (axi_ar_if.avalid) begin
            // RD (addr) are ready
            valid                       = 1'b1;
            wr                          = 1'b0;
            id                          = axi_ar_if.aid;
            len                         = axi_ar_if.alen;
            seq_num                     = rd_seq_num;
            ba                          = get_dram_ba(axi_ar_if.aaddr);
            ra                          = get_dram_ra(axi_ar_if.aaddr);
            ca                          = get_dram_ca(axi_ar_if.aaddr);
        end
    end

    wire    [`DRAM_BK_CNT-1:0]      ready_bit_vector;

    genvar geni;
    generate
        for (geni=0; geni<`DRAM_BK_CNT; geni=geni+1) begin
            // broadcast signals
            assign  req_if_arr[geni].wr         = wr;
            assign  req_if_arr[geni].id         = id;
            assign  req_if_arr[geni].len        = len;
            assign  req_if_arr[geni].seq_num    = seq_num;
            assign  req_if_arr[geni].ra         = ra;
            assign  req_if_arr[geni].ca         = ca;

            // assert valid to selected bank only
            assign  req_if_arr[geni].valid      = valid & (ba==geni);
            // connect ready from the selected bank to the requesting
            // interface
            assign  ready_bit_vector[geni]      = req_if_arr[geni].ready & (ba==geni);
        end
    endgenerate

    assign  axi_aw_if.aready            = wr & (|ready_bit_vector);
    assign  axi_ar_if.aready            = !wr & (|ready_bit_vector);

    always_ff @(posedge clk)
        if (~rst_n) begin
            rd_seq_num                  <= 'd0;
            wr_seq_num                  <= 'd0;
        end
        else begin
            if (axi_ar_if.avalid & axi_ar_if.aready) begin
                rd_seq_num                  <= rd_seq_num + 'd1;
            end
            if (axi_aw_if.avalid & axi_aw_if.aready) begin
                wr_seq_num                  <= wr_seq_num + 'd1;
            end
        end

endmodule // SAL_ADDR_DECODER
