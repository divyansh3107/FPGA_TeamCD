//Testbench:

`timescale 1ns/1ps

module alutb;

reg [17:0] a, b, d;
reg [47:0] c;
reg  carryin,clk;
reg [1:0] select;

wire [47:0]P;

alu uut (a, b,c,d,carryin, select, P,clk );

initial begin

$dumpfile ("dff_out.vcd"); 
$dumpvars(0,alutb);

// Initialize Inputs
a=0;
b=0;
c=0;
d=0;
clk = 0;
carryin=0;
select=0;


#5
select=0;
c=4;
a=1;b=1;d=1;

#10
select=1;
c={48{1'b1}};
a=0;b=0;d=0;

#10
select=2;
c={48{1'b1}};
a=0;b=0;d=0;

#10
select=3;
c=0;
a=2;b=3;d=0;

end

always 
#3 clk=~clk;

endmodule

