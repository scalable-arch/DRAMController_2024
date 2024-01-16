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
    AXI_A_IF                        axi_ar_if   (.clk(clk), .rst_n(rst_n));
    AXI_R_IF                        axi_r_if    (.clk(clk), .rst_n(rst_n));
    AXI_A_IF                        axi_aw_if   (.clk(clk), .rst_n(rst_n));
    AXI_W_IF                        axi_w_if    (.clk(clk), .rst_n(rst_n));
    AXI_B_IF                        axi_b_if    (.clk(clk), .rst_n(rst_n));

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

        // AXI interface
        .axi_ar_if                  (axi_ar_if),
        .axi_aw_if                  (axi_aw_if),
        .axi_w_if                   (axi_w_if),
        .axi_b_if                   (axi_b_if),
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
        axi_aw_if.init();
        axi_w_if.init();
        axi_b_if.init();
        axi_ar_if.init();
        axi_r_if.init();

        // wait for a reset release
        @(posedge rst_n);

        // wait enough cycles for DRAM to finish their initialization
        repeat (250) @(posedge clk);
    endtask

    axi_id_t                        simple_id;
    assign  simple_id               = 'd0;

    task automatic write32B (
        input   axi_addr_t          addr,
        input   [0:255]             data
    );
        axi_id_t                    rid;
        axi_resp_t                  rresp;

        // drive to AW and W
        fork
            begin
                axi_aw_if.send(simple_id, addr, 'd1, `AXI_SIZE_128, `AXI_BURST_INCR);
            end
            begin
                axi_w_if.send(simple_id, data[0:127], 16'hFFFF, 1'b0);
                axi_w_if.send(simple_id, data[128:255], 16'hFFFF, 1'b1);
            end
        join

        // receive from B
        axi_b_if.recv(rid, rresp);

        // check responses
        if (rid!==simple_id) begin $display("ID mismatch (expected: %d, received: %d)", simple_id, rid); $finish; end
        if (rresp!==2'b00) begin $display("Non-OK response (received: %d)", rresp); $finish; end
    endtask

    task automatic read32B(
        input   axi_addr_t          addr,
        output  [0:255]             data
    );
        axi_id_t                    rid;
        axi_resp_t                  rresp;
        logic                       rlast;

        // drive to AR
        axi_ar_if.send(simple_id, addr, 'd1, `AXI_SIZE_128, `AXI_BURST_INCR);

        // receive from R
        axi_r_if.recv(rid, data[0:127], rresp, rlast);
        if (rlast!==1'b0) begin $display("RLAST mismatch (expected: %d, received: %d)", 0, rlast); $finish; end
        if (rid!==simple_id) begin $display("ID mismatch (expected: %d, received: %d)", simple_id, rid); $finish; end
        if (rresp!==2'b00) begin $display("Non-OK response (received: %d)", rresp); $finish; end

        axi_r_if.recv(rid, data[128:255], rresp, rlast);
        if (rlast!==1'b1) begin $display("RLAST mismatch (expected: %d, received: %d)", 1, rlast); $finish; end
        if (rid!==simple_id) begin $display("ID mismatch (expected: %d, received: %d)", simple_id, rid); $finish; end
        if (rresp!==2'b00) begin $display("Non-OK response (received: %d)", rresp); $finish; end
    endtask


    logic   [0:255]             data;
    logic   [0:255]             wdata;
    initial begin
        init();

        wdata = 256'h1111_1111_2222_2222_3333_3333_4444_4444_5555_5555_6666_6666_7777_7777_8888_8888;
        write32B('h0008,    wdata); // bank 0, row 0, col 1,2,3,0
        write32B('h2000,    wdata); // bank 1, row 0, col 0,1,2,3
        write32B('h4010,    {8{32'h99999999}}); // bank 2, row 0, col 0~3
        write32B('h6018,    {8{32'h88888888}}); // bank 3, row 0, col 0~3
        write32B('h8020,    {8{32'h77777777}}); // bank 0, row 1, col 4~7
        write32B('hA028,    {8{32'h11111111}}); // bank 1, row 1, col 4~7
        read32B('h0000, data);                  // bank 0, row 0, col 0,1,2,3
        read32B('h2000, data);                  // bank 1, row 0, col 0,1,2,3
        read32B('h2008, data);                  // bank 1, row 0, col 1,2,3,0
        read32B('h2010, data);                  // bank 1, row 0, col 2,3,0,1
        read32B('h2018, data);                  // bank 1, row 0, col 3,0,1,2

        repeat (100) @(posedge clk);

        write32B('h4A38,    {8{32'h01234567}}); // bank 2, row 0, col 144~147
        write32B('h0020,    {8{32'h01234567}}); // bank 0, row 0, col 4~7
        read32B('h0000, data);                  // bank 0, row 0, col 0~3
        read32B('h0008, data);                  // bank 0, row 0, col 0~3
        read32B('h0020, data);                  // bank 0, row 0, col 4~7

        $finish;
    end

endmodule // sim_tb_top
