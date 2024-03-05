module top;

bit CLK = '0;
bit MNMX = '1;
bit TEST = '1;
bit RESET = '0;
bit READY = '1;
bit NMI = '0;
bit INTR = '0;
bit HOLD = '0;

wire logic [7:0] AD;
logic [19:8] A;
logic HLDA;
logic IOM;
logic WR;
logic RD;
logic SSO;
logic INTA;
logic ALE;
logic DTR;
logic DEN;
logic OE,WD;
logic IO_CS0,IO_CS1;
logic M_CS0,M_CS1;


logic [19:0] Address;
wire [7:0]  Data;

Intel8088 P(CLK, MNMX, TEST, RESET, READY, NMI, INTR, HOLD, AD, A, HLDA, IOM, WR, RD, SSO, INTA, ALE, DTR, DEN);
IOM M0 	  (CLK,RESET,Address,M_CS0,RD,WR,ALE);
IOM M1 	  (CLK,RESET,Address,M_CS1,RD,WR,ALE);
IOM IO_0  (CLK,RESET,Address,IO_CS0,RD,WR,ALE);
IOM IO_1  (CLK,RESET,Address,IO_CS1,RD,WR,ALE);

// 8282 Latch to latch bus address
always_latch
begin
if (ALE)
	Address <= {A, AD};
end

// 8286 transceiver
assign Data =  (DTR & ~DEN) ? AD   : 'z;
assign AD   = (~DTR & ~DEN) ? Data : 'z;

//Chipselect Logic
assign M_CS0=~(Address[19] & ~IOM);							//Active Low
assign M_CS1=~(~Address[19] & ~IOM);							//Active Low
assign IO_CS0=~((Address[15:8] & ~Address[7:4]) & IOM);				//Active Low
assign IO_CS1=~((~Address[15:13] & Address[12:10] & ~Address[9]) & IOM);	//Active Low

always #50 CLK = ~CLK;

initial
begin
$dumpfile("dump.vcd"); $dumpvars;

repeat (2) @(posedge CLK);
RESET = '1;
repeat (5) @(posedge CLK);
RESET = '0;

repeat(10000) @(posedge CLK);
$finish();
end

endmodule
