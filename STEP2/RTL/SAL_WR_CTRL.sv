`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_WR_CTRL
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // timing parameters
    TIMING_IF.MON               timing_if,

    // scheduling output
    SCHED_IF.WR_CTRL            sched_if,

    // write data from AXI
    AXI_A_IF.DST                axi_aw_if,
    AXI_W_IF.DST                axi_w_if,
    AXI_B_IF.SRC                axi_b_if,

    // request to address decoder
    AXI_A_IF.SRC                axi_aw2_if,

    // write data to DDR PHY
    DFI_WR_IF.SRC               dfi_wr_if
);

    //----------------------------------------------------------
    // buffer AXI AW requests
    //----------------------------------------------------------
    wire                        aw_fifo_full,
                                aw_fifo_empty;
    SAL_FIFO
    #(
        .DEPTH_LG2                  (2),
        .DATA_WIDTH                 (`AXI_ID_WIDTH+`AXI_ADDR_WIDTH+`AXI_LEN_WIDTH+3+2)
    )
    aw_fifo
    (
        .clk                        (clk),
        .rst_n                      (rst_n),
        .full_o                     (aw_fifo_full),
        .afull_o                    (/* NC */),
        .wren_i                     (axi_aw_if.avalid & axi_aw_if.aready),
        .wdata_i                    ({axi_aw_if.aid,
                                      axi_aw_if.aaddr,
                                      axi_aw_if.alen,
                                      axi_aw_if.asize,
                                      axi_aw_if.aburst}),

        .empty_o                    (aw_fifo_empty),
        .aempty_o                   (/* NC */),
        .rden_i                     (axi_aw2_if.avalid & axi_aw2_if.aready),
        .rdata_o                    ({axi_aw2_if.aid,
                                      axi_aw2_if.aaddr,
                                      axi_aw2_if.alen,
                                      axi_aw2_if.asize,
                                      axi_aw2_if.aburst})
    );
    assign  axi_aw_if.aready            = ~aw_fifo_full;

    //----------------------------------------------------------
    // buffer AXI W data
    //----------------------------------------------------------
    wire                                w_fifo_full;
    SAL_FIFO
    #(
        .DEPTH_LG2                      (3),
        .DATA_WIDTH                     (128+16)
    )
    w_fifo
    (
        .clk                            (clk),
        .rst_n                          (rst_n),
        .full_o                         (w_fifo_full),
        .afull_o                        (/* NC */),
        .wren_i                         (axi_w_if.wvalid & axi_w_if.wready),
        .wdata_i                        ({axi_w_if.wdata, ~axi_w_if.wstrb}),    // inversion to convert strobe to mask

        .empty_o                        (/* NC */),
        .aempty_o                       (/* NC */),
        .rden_i                         (dfi_wr_if.wrdata_en),
        .rdata_o                        ({dfi_wr_if.wrdata, dfi_wr_if.wrdata_mask})
    );
    assign  axi_w_if.wready             = ~w_fifo_full;

    //----------------------------------------------------------
    // forward a AW request to AW2 only if it has full wdata
    //----------------------------------------------------------
    logic   [4:0]               w_trans_cnt,    w_trans_cnt_n;

    always_ff @(posedge clk)
        if (~rst_n) begin
            w_trans_cnt                 <= 'd0;
        end
        else begin
            w_trans_cnt                 <= w_trans_cnt_n;
        end

    logic                       aw2_hs,     wlast_hs;
    always_comb begin
        aw2_hs                      = axi_aw2_if.avalid & axi_aw2_if.aready;
        wlast_hs                    = axi_w_if.wvalid & axi_w_if.wready & axi_w_if.wlast;

        if (~aw2_hs & wlast_hs) begin
            w_trans_cnt_n               = w_trans_cnt + 'd1;
        end
        else if (aw2_hs & ~wlast_hs) begin
            w_trans_cnt_n               = w_trans_cnt - 'd1;
        end
        else begin
            w_trans_cnt_n               = w_trans_cnt;
        end
    end

    assign  axi_aw2_if.avalid           = ~aw_fifo_empty & (w_trans_cnt!='d0);

    //----------------------------------------------------------
    // AXI B path
    //----------------------------------------------------------
    // return a write response on receiving into the wdata FIFO
    // : it is okay because after the wdata FIFO, there's no reordering
    // in this implementation.
    wire                                bid_fifo_empty;
    SAL_FIFO
    #(
        .DEPTH_LG2                      (3),
        .DATA_WIDTH                     (`AXI_ID_WIDTH)
    )
    bid_fifo
    (
        .clk                            (clk),
        .rst_n                          (rst_n),
        .full_o                         (/* NC */),
        .afull_o                        (/* NC */),
        .wren_i                         (axi_w_if.wvalid & axi_w_if.wready & axi_w_if.wlast),
        .wdata_i                        (axi_w_if.wid),

        .empty_o                        (bid_fifo_empty),
        .aempty_o                       (/* NC */),
        .rden_i                         (axi_b_if.bvalid & axi_b_if.bready),
        .rdata_o                        (axi_b_if.bid)
    );

    assign  axi_b_if.bresp              = `AXI_RESP_OKAY;
    assign  axi_b_if.bvalid             = ~bid_fifo_empty;

    //----------------------------------------------------------
    // DFI write enable
    //----------------------------------------------------------
    reg     [15:0]              wren_shift_reg;

    always_ff @(posedge clk)
        if (~rst_n) begin
            wren_shift_reg              <= 16'h0;
        end
        else if (sched_if.wr_gnt) begin
            wren_shift_reg              <= {wren_shift_reg[14:1], 2'b11};
        end
        else begin
            wren_shift_reg              <= {wren_shift_reg[14:0], 1'b0};
        end

    assign  dfi_wr_if.wrdata_en         = wren_shift_reg[timing_if.dfi_wren_lat];

endmodule
