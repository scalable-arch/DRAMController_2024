module INV (A,Y);
output  Y;
input   A;
not #0.1 (Y,A);
endmodule

module AND2 (A1,A2,Y);
output  Y;
input   A1,A2;
and #0.2 (Y,A2,A1);
endmodule

module AND3 (A1,A2,A3,Y);
output  Y;
input   A1,A2,A3;
and #0.2 (Y,A3,A2,A1);
endmodule

module NAND2 (A1,A2,Y);
output  Y;
input   A1,A2;
nand #0.1 (Y,A2,A1);
endmodule

module NAND3 (A1,A2,A3,Y);
output  Y;
input   A1,A2,A3;
nand #0.1 (Y,A3,A2,A1);
endmodule

module OR2 (A1,A2,Y);
output  Y;
input   A1,A2;
or #0.2 (Y,A2,A1);
endmodule

module OR3 (A1,A2,A3,Y);
output  Y;
input   A1,A2,A3;
or #0.2 (Y,A3,A2,A1);
endmodule


module NOR2 (A1,A2,Y);
output  Y;
input   A1,A2;
nor #0.1 (Y,A2,A1);
endmodule

module NOR3 (A1,A2,A3,Y);
output  Y;
input   A1,A2,A3;
nor #0.1 (Y,A3,A2,A1);
endmodule

module XOR2 (A1,A2,Y);
output  Y;
input   A1,A2;
xor #0.3 (Y,A2,A1);
endmodule

module XOR3 (A1,A2,A3,Y);
output  Y;
input   A1,A2,A3;
xor #0.4 (Y,A3,A2,A1);
endmodule


module XNOR2 (A1,A2,Y);
output  Y;
input   A1,A2;
xnor #0.3 (Y,A2,A1);
endmodule

module XNOR3 (A1,A2,A3,Y);
output  Y;
input   A1,A2,A3;
xnor #0.4 (Y,A3,A2,A1);
endmodule

module MUX21 (A1,A2,S0,Y);
output   Y;
input   A1,A2,S0;
assign #0.3 Y = S0 ? A1 : A2;
endmodule

module DFF (D, RST_n, CLK, Q, QN);
input D, RST_n, CLK;
output reg Q;
output QN;
always@(posedge CLK or negedge RST_n)
    Q <= #0.3 RST_n ? D : 1'b0;
assign QN = ~Q;
endmodule
    