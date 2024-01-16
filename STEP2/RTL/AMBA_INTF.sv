`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

// For clocking block (verification part)
// sample -0.1ns before a posedge
`define ISAMPLE_TIME        0.1
// drive 0.1ns after a posedge
`define OSAMPLE_TIME        0.1

interface AXI_A_IF
(
    input                       clk,
    input                       rst_n
);
    logic                       avalid;
    logic                       aready;
    axi_id_t                    aid;
    axi_addr_t                  aaddr;
    axi_len_t                   alen;
    axi_size_t                  asize;
    axi_burst_t                 aburst;

    // synthesizable, for design
    modport                     SRC (
        output                      avalid, aid, aaddr, alen, asize, aburst,
        input                       aready
    );

    modport                     DST (
        input                       avalid, aid, aaddr, alen, asize, aburst,
        output                      aready
    );

    // for verification only
    // synthesis translate_off
    clocking SRC_CB @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        output                      avalid, aid, aaddr, alen, asize, aburst;
        input                       aready;
    endclocking

    clocking DST_CB @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        input                       avalid, aid, aaddr, alen, asize, aburst;
        output                      aready;
    endclocking

    clocking MON_CB @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        input                       avalid, aid, aaddr, alen, asize, aburst;
        input                       aready;
    endclocking

    modport SRC_TB (clocking SRC_CB, input clk, rst_n);
    modport DST_TB (clocking DST_CB, input clk, rst_n);

    task automatic init();
        avalid                      = 1'b0;
        aid                         = 'hx;
        aaddr                       = 'hx;
        alen                        = 'hx;
        asize                       = 'hx;
        aburst                      = 'hx;
    endtask

    task automatic send (
        input   axi_id_t            id,
        input   axi_addr_t          addr,
        input   axi_len_t           len,
        input   axi_size_t          size,
        input   logic               burst
    );
        SRC_CB.avalid               <= 1'b1;
        SRC_CB.aid                  <= id;
        SRC_CB.aaddr                <= addr;
        SRC_CB.alen                 <= len;
        SRC_CB.asize                <= size;
        SRC_CB.aburst               <= burst;
        @(posedge clk);
        while (aready!=1'b1) begin
            @(posedge clk);
        end
        SRC_CB.avalid               <= 1'b0;
        SRC_CB.aid                  <= 'hx;
        SRC_CB.aaddr                <= 'hx;
        SRC_CB.alen                 <= 'hx;
        SRC_CB.asize                <= 'hx;
        SRC_CB.aburst               <= 'hx;
    endtask
    // synthesis translate_on
endinterface

interface AXI_W_IF
(
    input                       clk,
    input                       rst_n
);
    logic                       wvalid;
    logic                       wready;
    axi_id_t                    wid;
    axi_data_t                  wdata;
    axi_strb_t                  wstrb;
    logic                       wlast;

    // synthesizable, for design
    modport                     SRC (
        output                      wvalid, wid, wdata, wstrb, wlast,
        input                       wready
    );

    modport                     DST (
        input                       wvalid, wid, wdata, wstrb, wlast,
        output                      wready
    );

    modport                     MON (
        input                       wvalid, wid, wdata, wstrb, wlast,
        input                       wready
    );

    // for verification only
    // synthesis translate_off
    clocking SRC_CB @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        output                      wvalid, wid, wdata, wstrb, wlast;
        input                       wready;
    endclocking

    clocking DST_CB @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        input                       wvalid, wid, wdata, wstrb, wlast;
        output                      wready;
    endclocking

    clocking MON_CB @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        input                       wvalid, wid, wdata, wstrb, wlast;
        input                       wready;
    endclocking

    modport SRC_TB (clocking SRC_CB, input clk, rst_n);
    modport DST_TB (clocking DST_CB, input clk, rst_n);

    task automatic init();
        wvalid                      = 1'b0;
        wid                         = 'hx;
        wdata                       = 'hx;
        wstrb                       = 'hx;
        wlast                       = 'hx;
    endtask

    task automatic send (
      input   axi_id_t              id,
      input   axi_data_t            data,
      input   axi_strb_t            strb,
      input   logic                 last
    );
        SRC_CB.wvalid               <= 1'b1;
        SRC_CB.wid                  <= id;
        SRC_CB.wdata                <= data;
        SRC_CB.wstrb                <= strb;
        SRC_CB.wlast                <= last;
        @(posedge clk);
        while (wready!=1'b1) begin
            @(posedge clk);
        end
        SRC_CB.wvalid               <= 1'b0;
        SRC_CB.wid                  <= 'hx;
        SRC_CB.wdata                <= 'hx;
        SRC_CB.wstrb                <= 'hx;
        SRC_CB.wlast                <= 'hx;
    endtask
    // synthesis translate_on
endinterface

interface AXI_B_IF
(
    input                       clk,
    input                       rst_n
);
    logic                       bvalid;
    logic                       bready;
    axi_id_t                    bid;
    axi_resp_t                  bresp;

    // synthesizable, for design
    modport                     SRC (
        output                      bvalid, bid, bresp,
        input                       bready
    );

    modport                     DST (
        input                       bvalid, bid, bresp,
        output                      bready
    );

    // for verification only
    // synthesis translate_off
    clocking SRC_CB @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        output                      bvalid, bid, bresp;
        input                       bready;
    endclocking

    clocking DST_CB @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        input                       bvalid, bid, bresp;
        output                      bready;
    endclocking

    clocking MON_CB @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        input                       bvalid, bid, bresp;
        input                       bready;
    endclocking

    modport SRC_TB (clocking SRC_CB, input clk, rst_n);
    modport DST_TB (clocking DST_CB, input clk, rst_n);

    task automatic init();
        bready                      = 1'b0;
    endtask

    task automatic recv (
        output  axi_id_t             id,
        output  axi_resp_t           resp
    );
        DST_CB.bready               <= 1'b1;
        @(posedge clk);
        while (bvalid!=1'b1) begin
            @(posedge clk);
        end
        id                          = bid;
        resp                        = bresp;
        DST_CB.bready               <= 1'b0;
    endtask
    // synthesis translate_on
endinterface



interface AXI_R_IF
(
    input                       clk,
    input                       rst_n
);
    logic                       rvalid;
    logic                       rready;
    axi_id_t                    rid;
    axi_data_t                  rdata;
    axi_resp_t                  rresp;
    logic                       rlast;

    // synthesizable, for design
    modport                     SRC (
        output                      rvalid, rid, rdata, rresp, rlast,
        input                       rready
    );

    modport                     DST (
        input                       rvalid, rid, rdata, rresp, rlast,
        output                      rready
    );

    // For verification
    // synthesis translate_off
    clocking SRC_CB @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        output                      rvalid, rid, rdata, rresp, rlast;
        input                       rready;
    endclocking

    clocking DST_CB @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        input                       rvalid, rid, rdata, rresp, rlast;
        output                      rready;
    endclocking

    clocking MON_CB @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        input                       rvalid, rid, rdata, rresp, rlast;
        input                       rready;
    endclocking

    modport SRC_TB (clocking SRC_CB, input clk, rst_n);
    modport DST_TB (clocking DST_CB, input clk, rst_n);

    task automatic init();
        rready                      = 1'b0;
    endtask

    task automatic send  (
      input   axi_id_t              id,
      input   axi_data_t            data,
      input   axi_resp_t            resp,
      input   logic                 last
    );
        SRC_CB.rvalid               <= 1'b1;
        SRC_CB.rid                  <= id;
        SRC_CB.rdata                <= data;
        SRC_CB.rresp                <= resp;
        SRC_CB.rlast                <= last;
        @(posedge clk);
        while (rready!=1'b1) begin
            @(posedge clk);
        end
        SRC_CB.rvalid               <= 1'b0;
        SRC_CB.rid                  <= 'hx;
        SRC_CB.rdata                <= 'hx;
        SRC_CB.rresp                <= 'hx;
        SRC_CB.rlast                <= 'hx;
    endtask

    task automatic recv (
      output  axi_id_t              id,
      output  axi_data_t            data,
      output  axi_resp_t            resp,
      output  logic                 last
    );
        DST_CB.rready               <= 1'b1;
        @(posedge clk);
        while (rvalid!=1'b1) begin
            @(posedge clk);
        end
        id                          = rid;
        data                        = rdata;
        resp                        = rresp;
        last                        = rlast;
        DST_CB.rready               <= 1'b0;
    endtask
    // synthesis translate_on
endinterface

interface APB_IF (
    input                       clk,
    input                       rst_n
);
    logic                       psel;
    logic                       penable;
    logic   [31:0]              paddr;
    logic                       pwrite;
    logic   [31:0]              pwdata;
    logic                       pready;
    logic   [31:0]              prdata;
    logic                       pslverr;

    // synthesizable, for design
    modport MST (
        output                  psel, penable, paddr, pwrite, pwdata,
        input                   pready, prdata, pslverr
    );

    modport SLV (
        input                   psel, penable, paddr, pwrite, pwdata,
        output                  pready, prdata, pslverr
    );

    // for verification only
    // synthesis translate_off
    clocking MST_CB @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        output                      psel, penable, paddr, pwrite, pwdata;
        input                       pready, prdata, pslverr;
    endclocking

    clocking SLV_CB @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        input                       psel, penable, paddr, pwrite, pwdata;
        output                      pready, prdata, pslverr;
    endclocking

    clocking MON_CB @(posedge clk);
        default input #`ISAMPLE_TIME output #`OSAMPLE_TIME;

        input                       psel, penable, paddr, pwrite, pwdata;
        input                       pready, prdata, pslverr;
    endclocking

    modport MST_TB (clocking MST_CB, input clk, rst_n);
    modport SLV_TB (clocking SLV_CB, input clk, rst_n);

    task automatic init();
        psel                        = 1'b0;
        penable                     = 'hx;
        paddr                       = 'hx;
        pwrite                      = 'hx;
        pwdata                      = 'hx;
    endtask

    task automatic write (
        input    [31:0]  addr,
        input    [31:0]  data
    );
        MST_CB.psel                 <= 1'b1;
        MST_CB.penable              <= 1'b0;
        MST_CB.paddr                <= addr;
        MST_CB.pwrite               <= 1'b1;
        MST_CB.pwdata               <= data;
        @(posedge clk);
        MST_CB.penable              <= 1'b1;
        @(posedge clk);

        while (pready!=1'b1) begin
            @(posedge clk);
        end

        MST_CB.psel                 <= 1'b0;
        MST_CB.penable              <= 'hx;
        MST_CB.paddr                <= 'hx;
        MST_CB.pwrite               <= 'hx;
        MST_CB.pwdata               <= 'hx;
    endtask

    task automatic read (
        input     [31:0]  addr,
        output    [31:0]  data
    );
        MST_CB.psel                 <= 1'b1;
        MST_CB.penable              <= 1'b0;
        MST_CB.paddr                <= addr;
        MST_CB.pwrite               <= 1'b0;
        MST_CB.pwdata               <= 'hx;
        @(posedge clk);
        MST_CB.penable              <= 1'b1;
        @(posedge clk);

        while (pready==1'b0) begin
            @(posedge clk);
        end
        while (pready!=1'b1) begin
            @(posedge clk);
        end

        MST_CB.psel                 <= 1'b0;
        MST_CB.penable              <= 'hx;
        MST_CB.paddr                <= 'hx;
        MST_CB.pwrite               <= 'hx;
        MST_CB.pwdata               <= 'hx;

        data                        = prdata;
    endtask
    // synthesis translate_on

endinterface
