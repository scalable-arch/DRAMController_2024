`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_CTRL_ENCODER
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // scheduling interface
    SCHED_IF.CTRL_ENCODER       sched_if,

    // request to DDR PHY
    DFI_CTRL_IF.SRC             dfi_ctrl_if
);

    // Follow the command truth table in the spec
    always_ff @(posedge clk)
        // grants are one-hot encoded
        // -> only one at a time is 1
        // -> can be restructured to improve timing further
        if (sched_if.ref_gnt) begin
            dfi_ctrl_if.cke             <= 1'b1;
            dfi_ctrl_if.cs_n[0]         <= 1'b0;
            dfi_ctrl_if.ras_n           <= 1'b0;
            dfi_ctrl_if.cas_n           <= 1'b0;
            dfi_ctrl_if.we_n            <= 1'b1;
            dfi_ctrl_if.ba              <= 'hx;
            dfi_ctrl_if.addr            <= 'hx;
            dfi_ctrl_if.odt             <= 'hx;
        end
        else if (sched_if.act_gnt) begin
            dfi_ctrl_if.cke             <= 1'b1;
            dfi_ctrl_if.cs_n[0]         <= 1'b0;
            dfi_ctrl_if.ras_n           <= 1'b0;
            dfi_ctrl_if.cas_n           <= 1'b1;
            dfi_ctrl_if.we_n            <= 1'b1;
            dfi_ctrl_if.ba              <= sched_if.ba;
            dfi_ctrl_if.addr            <= sched_if.ra;
            dfi_ctrl_if.odt             <= 'h0;
        end
        else if (sched_if.wr_gnt) begin
            dfi_ctrl_if.cke             <= 1'b1;
            dfi_ctrl_if.cs_n[0]         <= 1'b0;
            dfi_ctrl_if.ras_n           <= 1'b1;
            dfi_ctrl_if.cas_n           <= 1'b0;
            dfi_ctrl_if.we_n            <= 1'b0;
            dfi_ctrl_if.ba              <= sched_if.ba;
            dfi_ctrl_if.addr            <= sched_if.ca;
            dfi_ctrl_if.odt             <= 'h0;
        end
        else if (sched_if.rd_gnt) begin
            dfi_ctrl_if.cke             <= 1'b1;
            dfi_ctrl_if.cs_n[0]         <= 1'b0;
            dfi_ctrl_if.ras_n           <= 1'b1;
            dfi_ctrl_if.cas_n           <= 1'b0;
            dfi_ctrl_if.we_n            <= 1'b1;
            dfi_ctrl_if.ba              <= sched_if.ba;
            dfi_ctrl_if.addr            <= sched_if.ca;
            dfi_ctrl_if.odt             <= 'h0;
        end else if (sched_if.pre_gnt) begin
            dfi_ctrl_if.cke             <= 1'b1;
            dfi_ctrl_if.cs_n[0]         <= 1'b0;
            dfi_ctrl_if.ras_n           <= 1'b0;
            dfi_ctrl_if.cas_n           <= 1'b1;
            dfi_ctrl_if.we_n            <= 1'b0;
            dfi_ctrl_if.ba              <= sched_if.ba;
            // per-bank refresh
            dfi_ctrl_if.addr            <= 'hx & 16'b1111_1011_1111_1111;
            dfi_ctrl_if.odt             <= 'hx;
        end
        else begin      // DESELECT
            dfi_ctrl_if.cke             <= 1'b1;
            dfi_ctrl_if.cs_n            <= {`DFI_CS_WIDTH{1'b1}};
            dfi_ctrl_if.ras_n           <= 1'bx;
            dfi_ctrl_if.cas_n           <= 1'bx;
            dfi_ctrl_if.we_n            <= 1'bx;
            dfi_ctrl_if.ba              <= 'hx;
            dfi_ctrl_if.addr            <= 'hx;
            dfi_ctrl_if.odt             <= 'hx;
        end

endmodule // SAL_CTRL_ENCODER
