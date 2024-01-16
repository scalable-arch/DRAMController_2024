`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

interface AXI_A_IF
#(
    parameter   ADDR_WIDTH      = `AXI_ADDR_WIDTH,      // 32
    parameter   ID_WIDTH        = `AXI_ID_WIDTH,        // 4
    parameter   ADDR_LEN        = 4                               // question 04.07
 )
(
    input                       clk,
    input                       rst_n
);
    logic                       avalid;
    logic                       aready;
    logic   [ID_WIDTH-1:0]      aid;
    logic   [ADDR_WIDTH-1:0]    aaddr;
    logic   [ADDR_LEN-1:0]      alen;
    logic   [2:0]               asize;
    logic   [1:0]               aburst;

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
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        output                      avalid, aid, aaddr, alen, asize, aburst;
        input                       aready;
    endclocking

    clocking DST_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        input                       avalid, aid, aaddr, alen, asize, aburst;
        output                      aready;
    endclocking

    clocking MON_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        input                       avalid, aid, aaddr, alen, asize, aburst;
        input                       aready;
    endclocking

    modport SRC_TB (clocking SRC_CB, input clk, rst_n);
    modport DST_TB (clocking DST_CB, input clk, rst_n);

    function void init();   // does not consume timing
        avalid                      = 1'b0;
        aid                         = 'hx;
        aaddr                       = 'hx;
        alen                        = 'hx;
        asize                       = 'hx;
        aburst                      = 'hx;
    endfunction

    task automatic transfer(  input   [ID_WIDTH-1:0]      id,
                              input   [ADDR_WIDTH-1:0]    addr,
                              input   [ADDR_LEN-1:0]      len,
                              input   [2:0]               size,
                              input   [1:0]               burst);
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
#(
    parameter   DATA_WIDTH      = `AXI_DATA_WIDTH,
    parameter   ID_WIDTH        = `AXI_ID_WIDTH
 )
(
    input                       clk,
    input                       rst_n
);
    logic                       wvalid;
    logic                       wready;
    logic   [ID_WIDTH-1:0]      wid;
    logic   [DATA_WIDTH-1:0]    wdata;
    logic   [DATA_WIDTH/8-1:0]  wstrb;
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
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        output                      wvalid, wid, wdata, wstrb, wlast;
        input                       wready;
    endclocking

    clocking DST_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        input                       wvalid, wid, wdata, wstrb, wlast;
        output                      wready;
    endclocking

    clocking MON_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        input                       wvalid, wid, wdata, wstrb, wlast;
        input                       wready;
    endclocking

    modport SRC_TB (clocking SRC_CB, input clk, rst_n);
    modport DST_TB (clocking DST_CB, input clk, rst_n);

    function void init();   // does not consume timing
        wvalid                      = 1'b0;
        wid                         = 'hx;
        wdata                       = 'hx;
        wstrb                       = 'hx;
        wlast                       = 'hx;
    endfunction

    task automatic transfer(  input   [ID_WIDTH-1:0]      id,
                    input   [DATA_WIDTH-1:0]    data,
                    input   [DATA_WIDTH/8-1:0]  strb,
                    input                       last);
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
#(
    parameter   ID_WIDTH        = `AXI_ID_WIDTH
 )
(
    input                       clk,
    input                       rst_n
);
    logic                       bvalid;
    logic                       bready;
    logic   [ID_WIDTH-1:0]      bid;
    logic   [1:0]               bresp;

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
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        output                      bvalid, bid, bresp;
        input                       bready;
    endclocking

    clocking DST_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        input                       bvalid, bid, bresp;
        output                      bready;
    endclocking

    clocking MON_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        input                       bvalid, bid, bresp;
        input                       bready;
    endclocking

    modport SRC_TB (clocking SRC_CB, input clk, rst_n);
    modport DST_TB (clocking DST_CB, input clk, rst_n);

    function void init();   // does not consume timing
        bready                      = 1'b0;
        /*
        bvalid                      = 1'b0;
        bid                         = 'hx;
        bresp                       = 'hx;
        */
    endfunction

    task automatic receive(   output  [ID_WIDTH-1:0]      id,
                    output  [1:0]               resp);
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
#(
    parameter   DATA_WIDTH      = `AXI_DATA_WIDTH,
    parameter   ID_WIDTH        = `AXI_ID_WIDTH
 )
(
    input                       clk,
    input                       rst_n
);
    logic                       rvalid;
    logic                       rready;
    logic   [ID_WIDTH-1:0]      rid;
    logic   [DATA_WIDTH-1:0]    rdata;
    logic   [1:0]               rresp;
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
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        output                      rvalid, rid, rdata, rresp, rlast;
        input                       rready;
    endclocking

    clocking DST_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        input                       rvalid, rid, rdata, rresp, rlast;
        output                      rready;
    endclocking

    clocking MON_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        input                       rvalid, rid, rdata, rresp, rlast;
        input                       rready;
    endclocking

    modport SRC_TB (clocking SRC_CB, input clk, rst_n);
    modport DST_TB (clocking DST_CB, input clk, rst_n);

    function void init();   // does not consume timing
        rready                      = 1'b0;
        /*
        rvalid                      = 1'b0;
        rid                         = 'hx;
        rdata                       = 'hx;
        rresp                       = 'hx;
        rlast                       = 'hx;
        */
    endfunction

    task automatic transfer(  input   [ID_WIDTH-1:0]      id,
                    input   [DATA_WIDTH-1:0]    data,
                    input   [1:0]               resp,
                    input                       last);
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

    task automatic receive (  output  [ID_WIDTH-1:0]      id,
                    output  [DATA_WIDTH-1:0]    data,
                    output  [1:0]               resp,
                    output                      last);
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
    modport SRC (
        output                  psel, penable, paddr, pwrite, pwdata,
        input                   pready, prdata, pslverr
    );

    modport DST (
        input                   psel, penable, paddr, pwrite, pwdata,
        output                  pready, prdata, pslverr
    );

    // for verification only
    // synthesis translate_off
    clocking SRC_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        output                      psel, penable, paddr, pwrite, pwdata;
        input                       pready, prdata, pslverr;
    endclocking

    clocking DST_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        input                       psel, penable, paddr, pwrite, pwdata;
        output                      pready, prdata, pslverr;
    endclocking

    clocking MON_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge
        input                       psel, penable, paddr, pwrite, pwdata;
        input                       pready, prdata, pslverr;
    endclocking

    modport SRC_TB (clocking SRC_CB, input clk, rst_n);
    modport DST_TB (clocking DST_CB, input clk, rst_n);

    task init();
        psel                        = 1'b0;
        penable                     = 'hx;
        paddr                       = 'hx;
        pwrite                      = 'hx;
        pwdata                      = 'hx;
    endtask

    task automatic write(input    [31:0]  addr,
               input    [31:0]  data);
        SRC_CB.psel                 <= 1'b1;
        SRC_CB.penable              <= 1'b0;
        SRC_CB.paddr                <= addr;
        SRC_CB.pwrite               <= 1'b1;
        SRC_CB.pwdata               <= data;
        @(posedge clk);
        SRC_CB.penable              <= 1'b1;
        @(posedge clk);

        while (pready!=1'b1) begin
            @(posedge clk);
        end

        SRC_CB.psel                 <= 1'b0;
        SRC_CB.penable              <= 'hx;
        SRC_CB.paddr                <= 'hx;
        SRC_CB.pwrite               <= 'hx;
        SRC_CB.pwdata               <= 'hx;
    endtask

    task automatic read(input     [31:0]  addr,
              output    [31:0]  data);
        SRC_CB.psel                 <= 1'b1;
        SRC_CB.penable              <= 1'b0;
        SRC_CB.paddr                <= addr;
        SRC_CB.pwrite               <= 1'b0;
        SRC_CB.pwdata               <= 'hx;
        @(posedge clk);
        SRC_CB.penable              <= 1'b1;
        @(posedge clk);

        while (pready==1'b0) begin
            @(posedge clk);
        end
        while (pready!=1'b1) begin
            @(posedge clk);
        end

        SRC_CB.psel                 <= 1'b0;
        SRC_CB.penable              <= 'hx;
        SRC_CB.paddr                <= 'hx;
        SRC_CB.pwrite               <= 'hx;
        SRC_CB.pwdata               <= 'hx;

        data                        = prdata;
    endtask
    // synthesis translate_on

endinterface
