module SAL_FIFO #(
    parameter       DEPTH_LG2           = 4,
    parameter       DATA_WIDTH          = 32,
    parameter       AFULL_THRES         = ((1<<DEPTH_LG2)-1),
    parameter       AEMPTY_THRES        = 1
)
(
    input   wire                        clk,
    input   wire                        rst_n,

    output  wire                        full_o,
    output  wire                        afull_o,
    input   wire                        wren_i,
    input   wire    [DATA_WIDTH-1:0]    wdata_i,

    output  wire                        empty_o,
    output  wire                        aempty_o,
    input   wire                        rden_i,
    output  wire    [DATA_WIDTH-1:0]    rdata_o
);

    localparam  FIFO_DEPTH              = (1<<DEPTH_LG2);

    reg     [DATA_WIDTH-1:0]            data[FIFO_DEPTH];

    reg                                 full,       full_n,
                                        afull,      afull_n,
                                        empty,      empty_n,
                                        aempty,     aempty_n;
    reg     [DEPTH_LG2:0]               wrptr,      wrptr_n,
                                        rdptr,      rdptr_n;
    reg     [DEPTH_LG2-1:0]             cnt,        cnt_n;                                

    // reset entries to all 0s
    always_ff @(posedge clk)
        if (!rst_n) begin
            full                        <= 1'b0;
            afull                       <= 1'b0;
            empty                       <= 1'b1;    // empty after as reset
            aempty                      <= 1'b1;

            wrptr                       <= {(DEPTH_LG2+1){1'b0}};
            rdptr                       <= {(DEPTH_LG2+1){1'b0}};
            cnt                         <= {DEPTH_LG2{1'b0}};

            for (int i=0; i<FIFO_DEPTH; i++) begin
                data[i]                     <= {DATA_WIDTH{1'b0}};
            end
        end
        else begin
            full                        <= full_n;
            afull                       <= afull_n;
            empty                       <= empty_n;
            aempty                      <= aempty_n;

            wrptr                       <= wrptr_n;
            rdptr                       <= rdptr_n;
            cnt                         <= cnt_n;

            if (wren_i) begin
                data[wrptr[DEPTH_LG2-1:0]]  <= wdata_i;
            end
        end

    always_comb begin
        wrptr_n                     = wrptr;
        rdptr_n                     = rdptr;
        cnt_n                       = cnt;

        if (wren_i & ~full) begin
            wrptr_n                     = wrptr + 'd1;
        end

        if (rden_i & ~empty) begin
            rdptr_n                     = rdptr + 'd1;
        end

        if (wren_i & ~rden_i) begin
            cnt_n                       = cnt + 'd1;
        end
        else if (~wren_i & rden_i) begin
            cnt_n                       = cnt - 'd1;
        end

        full_n                      = (wrptr_n[DEPTH_LG2]!=rdptr_n[DEPTH_LG2])
                                     &(wrptr_n[DEPTH_LG2-1:0]==rdptr_n[DEPTH_LG2-1:0]);
        afull_n                     = (cnt_n >= AFULL_THRES);
        empty_n                     = (wrptr_n == rdptr_n);
        aempty_n                    = (cnt_n <= AFULL_THRES);
    end

    // synthesis translate_off
    always @(posedge clk) begin
        if (full_o & wren_i) begin
            $display("@%t FIFO %m overflow", $time);
            @(posedge clk);
            $finish;
        end
    end

    always @(posedge clk) begin
        if (empty_o & rden_i) begin
            $display("@%t FIFO %m underflow", $time);
            @(posedge clk);
            $finish;
        end
    end
    // synthesis translate_on

    assign  full_o                      = full;
    assign  afull_o                     = afull;
    assign  empty_o                     = empty;
    assign  aempty_o                    = aempty;
    assign  rdata_o                     = data[rdptr[DEPTH_LG2-1:0]];

endmodule
