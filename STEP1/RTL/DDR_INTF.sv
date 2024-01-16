`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

interface DDR_IF ();
    logic                           ck;
    logic                           ck_n;
    logic                           cke;
    logic   [`DRAM_CS_WIDTH-1:0]    cs_n;
    logic                           ras_n;
    logic                           cas_n;
    logic                           we_n;
    logic   [`DRAM_BA_WIDTH-1:0]    ba;
    logic   [`DRAM_ADDR_WIDTH-1:0]  addr;
    logic                           odt;
    
    wire    [63:0]                  dq;
    wire    [7:0]                   dqs;
    wire    [7:0]                   dqs_n;
    wire    [7:0]                   dm_rdqs;
    wire    [7:0]                   rdqs_n;
    
    // synthesizable, for design
    modport                     DDRPHY (
        output                      ck, ck_n, cke, ras_n, cas_n, we_n, ba, addr, odt,
        output                      cs_n,
        inout                       dq, dqs, dqs_n, dm_rdqs, rdqs_n
    );

    modport                     DIMM (
        input                       ck, ck_n, cke, ras_n, cas_n, we_n, ba, addr, odt,
        inout                       dq, dqs, dqs_n, dm_rdqs, rdqs_n
    );

endinterface