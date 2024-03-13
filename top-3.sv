interface Intel8088Pins( input wire CLK , RESET);

logic MNMX;
logic TEST;

logic READY;
logic NMI;
logic INTR;
logic HOLD;

logic HLDA;
tri [7:0] AD;
tri [19:8] A;

logic IOM;
logic WR;
logic RD;
logic SSO;
logic INTA;
logic ALE;
logic DTR;
logic DEN;






  
modport Processor (
	input CLK,
	input RESET,    
	input MNMX,
	input TEST,
	output READY,
	input NMI,
	input INTR,
	input HOLD,
	inout AD,
	output A,
	input HLDA,
	output IOM,
	output WR,
	output RD,
	input SSO,
	output INTA,
	output ALE,
	output DTR,
	output DEN
  );

  modport Peripheral (
    input CLK,
    input RESET,
    output IOM,
    output WR,
    output RD,

    input ALE,
    input DTR
    

  );
endinterface



module top;
parameter M = 0;
bit CLK = '0;
bit RESET = '0;

logic IO_CS0,IO_CS1;
logic M_CS0,M_CS1;

logic [19:0] Address;
wire  [7:0] Data;

Intel8088Pins pins (  .CLK(CLK) , .RESET(RESET) );

Intel8088 P(pins.Processor);

//Instantiate 4 Modules
IOM #(.size(2**19)) Mem0 (Address,Data,M_CS0,pins.Peripheral);
IOM #(.size(2**19)) Mem1 (Address,Data,M_CS1,pins.Peripheral);
IOM #(.size(2**4)) IO_0 (Address,Data,IO_CS0,pins.Peripheral);
IOM #(.size(2**9)) IO_1 (Address,Data,IO_CS1,pins.Peripheral);

// 8282 Latch to latch bus address
always_latch
begin
if (pins.ALE)
	Address <= {pins.A, pins.AD};
end

// 8286 transceiver
assign Data =  (pins.DTR & ~pins.DEN) ? pins.AD   : 'z;
assign pins.AD   = (~pins.DTR & ~pins.DEN) ? Data : 'z;

//Chipselect Logic
assign M_CS0=~(Address[19] & ~pins.IOM);											//Active Low
assign M_CS1=~(~Address[19] & ~pins.IOM);										//Active Low
assign IO_CS0=~((Address[15:8] & ~Address[7:4]) & pins.IOM);						//Active Low
assign IO_CS1=~((~Address[15:13] & Address[12:10] & ~Address[9]) & pins.IOM);	//Active Low

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
