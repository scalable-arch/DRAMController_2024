`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module ddr2_dimm (
    DDR_IF.DIMM                 ddr_if,
    input   wire                cs_n
);

    ddr2_model                      u_dram0
        (
            // command and address
            .ck                         (ddr_if.ck),
            .ck_n                       (ddr_if.ck_n),
            .cke                        (ddr_if.cke),
            .cs_n                       (cs_n),
            .ras_n                      (ddr_if.ras_n),
            .cas_n                      (ddr_if.cas_n),
            .we_n                       (ddr_if.we_n),
            .ba                         (ddr_if.ba),
            .addr                       (ddr_if.addr),
            .odt                        (ddr_if.odt),

            // data
            .dq                         (ddr_if.dq[7:0]),
            .dqs                        (ddr_if.dqs[0]),
            .dqs_n                      (ddr_if.dqs_n[0]),
            .dm_rdqs                    (ddr_if.dm_rdqs[0]),
            .rdqs_n                     (ddr_if.rdqs_n[0])
        );

        ddr2_model                      u_dram1
        (
            // command and address
            .ck                         (ddr_if.ck),
            .ck_n                       (ddr_if.ck_n),
            .cke                        (ddr_if.cke),
            .cs_n                       (cs_n),
            .ras_n                      (ddr_if.ras_n),
            .cas_n                      (ddr_if.cas_n),
            .we_n                       (ddr_if.we_n),
            .ba                         (ddr_if.ba),
            .addr                       (ddr_if.addr),
            .odt                        (ddr_if.odt),

            // data
            .dq                         (ddr_if.dq[15:8]),
            .dqs                        (ddr_if.dqs[1]),
            .dqs_n                      (ddr_if.dqs_n[1]),
            .dm_rdqs                    (ddr_if.dm_rdqs[1]),
            .rdqs_n                     (ddr_if.rdqs_n[1])
        );

        ddr2_model                      u_dram2
        (
            // command and address
            .ck                         (ddr_if.ck),
            .ck_n                       (ddr_if.ck_n),
            .cke                        (ddr_if.cke),
            .cs_n                       (cs_n),
            .ras_n                      (ddr_if.ras_n),
            .cas_n                      (ddr_if.cas_n),
            .we_n                       (ddr_if.we_n),
            .ba                         (ddr_if.ba),
            .addr                       (ddr_if.addr),
            .odt                        (ddr_if.odt),

            // data
            .dq                         (ddr_if.dq[23:16]),
            .dqs                        (ddr_if.dqs[2]),
            .dqs_n                      (ddr_if.dqs_n[2]),
            .dm_rdqs                    (ddr_if.dm_rdqs[2]),
            .rdqs_n                     (ddr_if.rdqs_n[2])
        );

        ddr2_model                      u_dram3
        (
            // command and address
            .ck                         (ddr_if.ck),
            .ck_n                       (ddr_if.ck_n),
            .cke                        (ddr_if.cke),
            .cs_n                       (cs_n),
            .ras_n                      (ddr_if.ras_n),
            .cas_n                      (ddr_if.cas_n),
            .we_n                       (ddr_if.we_n),
            .ba                         (ddr_if.ba),
            .addr                       (ddr_if.addr),
            .odt                        (ddr_if.odt),

            // data
            .dq                         (ddr_if.dq[31:24]),
            .dqs                        (ddr_if.dqs[3]),
            .dqs_n                      (ddr_if.dqs_n[3]),
            .dm_rdqs                    (ddr_if.dm_rdqs[3]),
            .rdqs_n                     (ddr_if.rdqs_n[3])
        );

        ddr2_model                      u_dram4
        (
            // command and address
            .ck                         (ddr_if.ck),
            .ck_n                       (ddr_if.ck_n),
            .cke                        (ddr_if.cke),
            .cs_n                       (cs_n),
            .ras_n                      (ddr_if.ras_n),
            .cas_n                      (ddr_if.cas_n),
            .we_n                       (ddr_if.we_n),
            .ba                         (ddr_if.ba),
            .addr                       (ddr_if.addr),
            .odt                        (ddr_if.odt),

            // data
            .dq                         (ddr_if.dq[39:32]),
            .dqs                        (ddr_if.dqs[4]),
            .dqs_n                      (ddr_if.dqs_n[4]),
            .dm_rdqs                    (ddr_if.dm_rdqs[4]),
            .rdqs_n                     (ddr_if.rdqs_n[4])
        );

        ddr2_model                      u_dram5
        (
            // command and address
            .ck                         (ddr_if.ck),
            .ck_n                       (ddr_if.ck_n),
            .cke                        (ddr_if.cke),
            .cs_n                       (cs_n),
            .ras_n                      (ddr_if.ras_n),
            .cas_n                      (ddr_if.cas_n),
            .we_n                       (ddr_if.we_n),
            .ba                         (ddr_if.ba),
            .addr                       (ddr_if.addr),
            .odt                        (ddr_if.odt),

            // // data
            .dq                         (ddr_if.dq[47:40]),
            .dqs                        (ddr_if.dqs[5]),
            .dqs_n                      (ddr_if.dqs_n[5]),
            .dm_rdqs                    (ddr_if.dm_rdqs[5]),
            .rdqs_n                     (ddr_if.rdqs_n[5])
        );

        ddr2_model                      u_dram6
        (
            // command and address
            .ck                         (ddr_if.ck),
            .ck_n                       (ddr_if.ck_n),
            .cke                        (ddr_if.cke),
            .cs_n                       (cs_n),
            .ras_n                      (ddr_if.ras_n),
            .cas_n                      (ddr_if.cas_n),
            .we_n                       (ddr_if.we_n),
            .ba                         (ddr_if.ba),
            .addr                       (ddr_if.addr),
            .odt                        (ddr_if.odt),

            // data
            .dq                         (ddr_if.dq[55:48]),
            .dqs                        (ddr_if.dqs[6]),
            .dqs_n                      (ddr_if.dqs_n[6]),
            .dm_rdqs                    (ddr_if.dm_rdqs[6]),
            .rdqs_n                     (ddr_if.rdqs_n[6])
        );

        ddr2_model                      u_dram7
        (
            // command and address
            .ck                         (ddr_if.ck),
            .ck_n                       (ddr_if.ck_n),
            .cke                        (ddr_if.cke),
            .cs_n                       (cs_n),
            .ras_n                      (ddr_if.ras_n),
            .cas_n                      (ddr_if.cas_n),
            .we_n                       (ddr_if.we_n),
            .ba                         (ddr_if.ba),
            .addr                       (ddr_if.addr),
            .odt                        (ddr_if.odt),

            // data
            .dq                         (ddr_if.dq[63:56]),
            .dqs                        (ddr_if.dqs[7]),
            .dqs_n                      (ddr_if.dqs_n[7]),
            .dm_rdqs                    (ddr_if.dm_rdqs[7]),
            .rdqs_n                     (ddr_if.rdqs_n[7])
        );


        initial begin
            repeat (5) @(posedge ddr_if.ck);
            u_dram0.initialize({1'b0,    // reserved
                               1'd0,    // fast exit
                               3'd5,    // write recover=6
                               1'b0,    // DLL reset
                               1'b0,    // normal
                               3'd`CAS_LATENCY,    // CAS latency=5
                               1'b0,    // interleaved
                               3'd2},   // BL4
                              'h0, 'h0, 'h0
                              );
            u_dram1.initialize({1'b0,    // reserved
                               1'd0,    // fast exit
                               3'd5,    // write recover=6
                               1'b0,    // DLL reset
                               1'b0,    // normal
                               3'd`CAS_LATENCY,    // CAS latency=5
                               1'b0,    // interleaved
                               3'd2},   // BL4
                              'h0, 'h0, 'h0
                              );
            u_dram2.initialize({1'b0,    // reserved
                               1'd0,    // fast exit
                               3'd5,    // write recover=6
                               1'b0,    // DLL reset
                               1'b0,    // normal
                               3'd`CAS_LATENCY,    // CAS latency=5
                               1'b0,    // interleaved
                               3'd2},   // BL4
                              'h0, 'h0, 'h0
                              );
            u_dram3.initialize({1'b0,    // reserved
                               1'd0,    // fast exit
                               3'd5,    // write recover=6
                               1'b0,    // DLL reset
                               1'b0,    // normal
                               3'd`CAS_LATENCY,    // CAS latency=5
                               1'b0,    // interleaved
                               3'd2},   // BL4
                              'h0, 'h0, 'h0
                              );
            u_dram4.initialize({1'b0,    // reserved
                               1'd0,    // fast exit
                               3'd5,    // write recover=6
                               1'b0,    // DLL reset
                               1'b0,    // normal
                               3'd`CAS_LATENCY,    // CAS latency=5
                               1'b0,    // interleaved
                               3'd2},   // BL4
                              'h0, 'h0, 'h0
                              );
            u_dram5.initialize({1'b0,    // reserved
                               1'd0,    // fast exit
                               3'd5,    // write recover=6
                               1'b0,    // DLL reset
                               1'b0,    // normal
                               3'd`CAS_LATENCY,    // CAS latency=5
                               1'b0,    // interleaved
                               3'd2},   // BL4
                              'h0, 'h0, 'h0
                              );
            u_dram6.initialize({1'b0,    // reserved
                               1'd0,    // fast exit
                               3'd5,    // write recover=6
                               1'b0,    // DLL reset
                               1'b0,    // normal
                               3'd`CAS_LATENCY,    // CAS latency=5
                               1'b0,    // interleaved
                               3'd2},   // BL4
                              'h0, 'h0, 'h0
                              );
            u_dram7.initialize({1'b0,    // reserved
                               1'd0,    // fast exit
                               3'd5,    // write recover=6
                               1'b0,    // DLL reset
                               1'b0,    // normal
                               3'd`CAS_LATENCY,// CAS latency=5
                               1'b0,    // sequential
                               3'd2},   // BL4
                              'h0,      // ('h400: DQS# Disable)
                              'h0, 'h0
                              );
        end

endmodule
