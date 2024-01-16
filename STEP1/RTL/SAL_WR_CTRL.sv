`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_WR_CTRL
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // write data from AXI
    AXI_W_IF.DST                axi_w_if,

    // timing parameters
    TIMING_IF.MON               timing_if,

    // scheduling output
    SCHED_IF.WR_CTRL            sched_if,

    // write data to DDR PHY
    DFI_WR_IF.SRC               dfi_wr_if
);

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
