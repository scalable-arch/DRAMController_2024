`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_TB_TOP;

    logic                       clk;
    logic                       rst_n;

    // clock generation
    initial begin
        clk                         = 1'b0;
        forever
            #(`CLK_PERIOD/2) clk         = ~clk;
    end

    // reset generation
    initial begin
        // activate the reset (active low)
        rst_n                       = 1'b0;
        repeat (3) @(posedge clk);
        // release the reset after 10 cycles
        rst_n                       = 1'b1;
    end

    APB_IF                          apb_if      (.clk(clk), .rst_n(rst_n));

    REQ_IF                          req_if      (.clk(clk), .rst_n(rst_n));
    AXI_R_IF                        axi_r_if    (.clk(clk), .rst_n(rst_n));
    AXI_W_IF                        axi_w_if    (.clk(clk), .rst_n(rst_n));

    DFI_CTRL_IF                     dfi_ctrl_if (.clk(clk), .rst_n(rst_n));
    DFI_WR_IF                       dfi_wr_if   (.clk(clk), .rst_n(rst_n));
    DFI_RD_IF                       dfi_rd_if   (.clk(clk), .rst_n(rst_n));

    DDR_IF                          ddr_if      ();

    SAL_DDR_CTRL                    u_dram_ctrl
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        // APB interface
        .apb_if                     (apb_if),

        // request interface
        .req_if                     (req_if),

        .axi_w_if                   (axi_w_if),
        .axi_r_if                   (axi_r_if),

        // DFI interface
        .dfi_ctrl_if                (dfi_ctrl_if),
        .dfi_wr_if                  (dfi_wr_if),
        .dfi_rd_if                  (dfi_rd_if)
    );

    DDRPHY                          u_ddrphy
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .dfi_ctrl_if                (dfi_ctrl_if),
        .dfi_wr_if                  (dfi_wr_if),
        .dfi_rd_if                  (dfi_rd_if),

        .ddr_if                     (ddr_if)
    );

    ddr2_dimm                       u_rank0
    (
        .ddr_if                     (ddr_if),
        .cs_n                       (ddr_if.cs_n[0])
    );

    ddr2_dimm                       u_rank1
    (
        .ddr_if                     (ddr_if),
        .cs_n                       (ddr_if.cs_n[1])
    );

    task init();
        req_if.init();            
        axi_w_if.init();
        axi_r_if.init();

        // wait for a reset release
        @(posedge rst_n);

        // wait enough cycles for DRAM to finish their initialization
        repeat (250) @(posedge clk);
    endtask

    logic       [`AXI_ID_WIDTH-1:0]     simple_id;
    logic   [255:0]             wdata;
    logic   [255:0]             rdata;

    task automatic write32B(
        input [`AXI_ID_WIDTH-1:0]   wid,
        input [`AXI_ADDR_WIDTH-1:0] addr,
        input [255:0]               data
    );
        logic   [1:0]               rresp;
        // drive to AW and W
        fork
            begin
                req_if.transfer(wid, get_dram_ra(addr), get_dram_ca(addr), 1'b1, 'd1);
            end
            begin
                axi_w_if.transfer(wid, data[127:0], 16'hFFFF, 1'b0);
                axi_w_if.transfer(wid, data[255:128], 16'hFFFF, 1'b1);
            end
        join
    endtask

    task automatic read32B(
        input [`AXI_ID_WIDTH-1:0]   rid_i,
        input [`AXI_ADDR_WIDTH-1:0] addr,
        output [255:0]              data
    );
        logic   [`AXI_ID_WIDTH-1:0] rid_o;
        logic   [1:0]               rresp;
        logic                       rlast;

        // drive to AR
        req_if.transfer(rid_i, get_dram_ra(addr), get_dram_ca(addr), 1'b0, 'd1);

        // receive from R
        axi_r_if.receive(rid_o, data[127:0], rresp, rlast);
        axi_r_if.receive(rid_o, data[255:128], rresp, rlast);
    endtask

    // yoojin
    task automatic read32Bx2(
        input [`AXI_ID_WIDTH-1:0]   rid_i1,
        input [`AXI_ADDR_WIDTH-1:0] addr1,
        input [`AXI_ID_WIDTH-1:0]   rid_i2,
        input [`AXI_ADDR_WIDTH-1:0] addr2
    );
        logic   [`AXI_ID_WIDTH-1:0] rid_o;
        logic   [255:0]             data;
        logic   [1:0]               rresp;
        logic                       rlast;

        fork
            begin
                // drive to AR 1
                req_if.transfer(rid_i1, get_dram_ra(addr1), get_dram_ca(addr1), 1'b0, 'd1);
                // drive to AR 2
                req_if.transfer(rid_i2, get_dram_ra(addr2), get_dram_ca(addr2), 1'b0, 'd1);
            end
            begin
                // receive from R 1
                axi_r_if.receive(rid_o, data[127:0], rresp, rlast);
                axi_r_if.receive(rid_o, data[255:128], rresp, rlast);
                rdata           = data;
                // receive from R 2
                axi_r_if.receive(rid_o, data[127:0], rresp, rlast);
                axi_r_if.receive(rid_o, data[255:128], rresp, rlast);
                rdata           = data;
            end
        join
    endtask


    initial begin
        init();

        wdata                   = {256'h1111_1111_2222_2222_3333_3333_4444_4444_5555_5555_6666_6666_7777_7777_8888_8888};
        write32B('d0, 'd0, wdata); // bank 0, row 0, col 0~3
        write32B('d1, 'd32, {{4{32'h33663366}}, {4{32'h22442244}}}); // bank 0, row 0, col 4~7
        read32Bx2('d0, 'd32, 'd1, 'd0); // id1, addr1, id2, addr2

        repeat (100) @(posedge clk);

        write32B('d2, 'd0,   {8{32'h12345432}}); // bank 0, row 0, col 0~3
        write32B('d3, 'd32,  {8{32'h10011100}}); // bank 0, row 0, col 4~7
        read32B('d2, 'd0, rdata);
        read32B('d3, 'd32, rdata);

        repeat (10) @(posedge clk);
        $finish;
    end

endmodule // sim_tb_top
