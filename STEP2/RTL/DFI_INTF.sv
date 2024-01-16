`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

interface DFI_CTRL_IF
(
    input                       clk,
    input                       rst_n
);
    logic                       cke;
    logic   [`DFI_CS_WIDTH-1:0] cs_n;
    logic                       ras_n;
    logic                       cas_n;
    logic                       we_n;
    logic   [`DFI_BA_WIDTH-1:0] ba;
    logic   [`DFI_ADDR_WIDTH-1:0]   addr;
    logic                       odt;

    // synthesizable, for design
    modport                     SRC (
        output                      cke, cs_n, ras_n, cas_n, we_n, ba, addr, odt
    );

    modport                     DST (
        input                       cke, cs_n, ras_n, cas_n, we_n, ba, addr, odt
    );

endinterface

interface DFI_WR_IF
(
    input                       clk,
    input                       rst_n
);
    logic                       wrdata_en;
    logic   [127:0]             wrdata;
    logic   [15:0]              wrdata_mask;

    // synthesizable, for design
    modport                     SRC (
        output                      wrdata_en, wrdata, wrdata_mask
    );

    modport                     DST (
        input                       wrdata_en, wrdata, wrdata_mask
    );
endinterface

interface DFI_RD_IF
(
    input                       clk,
    input                       rst_n
);
    logic                       rddata_en;
    logic   [127:0]             rddata;
    logic                       rddata_valid;
    logic   [15:0]              rddata_dnv;


    // synthesizable, for design
    modport                     SRC (
        output                      rddata, rddata_valid, rddata_dnv,
        input                       rddata_en
    );

    modport                     DST (
        input                       rddata, rddata_valid, rddata_dnv,
        output                      rddata_en
    );
endinterface
