`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_RD_CTRL
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // timing parameters
    TIMING_IF.MON               timing_if,

    // scheduling output
    SCHED_IF.RD_CTRL            sched_if,

    // read data from DDR PHY
    DFI_RD_IF.DST               dfi_rd_if,
    // read data to AXI
    AXI_R_IF.SRC                axi_r_if
);

    //----------------------------------------------------------
    // DDR PHY control
    //----------------------------------------------------------
    // : assert rddata_en signal (for data duration) with some latency
    //----------------------------------------------------------
    // read enable path
    reg     [15:0]              rden_shift_reg;

    always_ff @(posedge clk)
        if (~rst_n) begin
            rden_shift_reg              <= 16'h0;
        end
        else if (sched_if.rd_gnt) begin
            rden_shift_reg              <= {rden_shift_reg[14:1], 2'b11};
        end
        else begin
            rden_shift_reg              <= {rden_shift_reg[14:0], 1'b0};
        end

    assign  dfi_rd_if.rddata_en         = rden_shift_reg[timing_if.dfi_rden_lat];

    //----------------------------------------------------------
    // Buffer AXI ID and AXI LEN
    // to generate RID and RLAST of AXI R channel
    //----------------------------------------------------------
    wire                                rid_fifo_empty;
    wire    [`AXI_LEN_WIDTH-1:0]        rlen;
    logic   [`AXI_LEN_WIDTH-1:0]        rdata_cnt;

    SAL_FIFO
    #(
        .DEPTH_LG2                      (4),
        .DATA_WIDTH                     (`AXI_ID_WIDTH+`AXI_LEN_WIDTH)
    )
    rid_fifo
    (
        .clk                            (clk),
        .rst_n                          (rst_n),
        .full_o                         (/* NC */),
        .afull_o                        (/* NC */),
        .wren_i                         (sched_if.rd_gnt),
        .wdata_i                        ({sched_if.id, sched_if.len}),

        .empty_o                        (/* NC */),
        .aempty_o                       (/* NC */),
        .rden_i                         (axi_r_if.rvalid & axi_r_if.rready & axi_r_if.rlast),
        .rdata_o                        ({axi_r_if.rid, rlen})  // used as RID
    );

    always_ff @(posedge clk)
        if (~rst_n) begin
            rdata_cnt                   <= 'd0;
        end
        else if (axi_r_if.rvalid & axi_r_if.rready) begin
            if (& axi_r_if.rlast) begin // Burst finished. Initialize 
                rdata_cnt                   <= 'd0;
            end
            else begin
                rdata_cnt                   <= rdata_cnt+'d1;
            end
        end

    assign  axi_r_if.rlast              = (rdata_cnt==rlen);    // used as RLAST

    //----------------------------------------------------------
    // read data path
    wire                                rdata_fifo_empty;
    logic [`AXI_DATA_WIDTH-1:0]         buf_rdata;

    always_ff @(posedge clk) begin
        if (~rst_n)
            buf_rdata                   <= 'dx;
        else
            buf_rdata                   <= dfi_rd_if.rddata;
    end

    SAL_FIFO
    #(
        .DEPTH_LG2                      (3),
        .DATA_WIDTH                     (128)
    )
    rdata_fifo
    (
        .clk                            (clk),
        .rst_n                          (rst_n),
        .full_o                         (/* NC */),
        .afull_o                        (/* NC */),
        .wren_i                         (dfi_rd_if.rddata_valid),
        .wdata_i                        (buf_rdata),

        .empty_o                        (rdata_fifo_empty),
        .aempty_o                       (/* NC */),
        .rden_i                         (axi_r_if.rvalid & axi_r_if.rready),
        .rdata_o                        (axi_r_if.rdata)    // used as RDATA
    );
    assign  axi_r_if.rresp              = `AXI_RESP_OKAY;
    assign  axi_r_if.rvalid             = ~rdata_fifo_empty;

endmodule
