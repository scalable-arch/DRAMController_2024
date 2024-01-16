`timescale 1ns/1ps

module SAL_TIMING_CNTR
#(
    parameter                   CNTR_WIDTH      = 4
)
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // request from the address decoder
    input                       reset_cmd_i,
    input   [CNTR_WIDTH-1:0]    reset_value_i,
    //output                      is_zero_n_o,    // one-cycle earlier version
    output                      is_zero_o       // registered version
);

    // saturating counter (it does not decrease below 0)
    // - With a reset command, the counter values becomes the reset_value
    // - Without a reset command, the counter decreases down to 0 but does not
    // go below 0
    logic   [CNTR_WIDTH-1:0]    cntr,       cntr_n;

    always_ff @(posedge clk)
        if (!rst_n)
            cntr                    <= 'd0;
        else
            cntr                    <= cntr_n;

    always_comb begin
        if (reset_cmd_i)
            cntr_n                  = reset_value_i;
        else if (cntr != 'd0)
            cntr_n                  = cntr - 'd1;
        else
            cntr_n                  = cntr;
    end

    //assign  is_zero_n_o             = (cntr_n == 'd0);
    assign  is_zero_o               = (cntr == 'd0);

endmodule
