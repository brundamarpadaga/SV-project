interface Intel8088Pins( input wire CLK , RESET);

bit MNMX = '1;
bit TEST = '1;
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


logic [19:0] Address;
wire [7:0]  Data;




  
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
	output SSO,
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
	input DTR,
	input Address,
	inout Data
);
endinterface



module top;

bit CLK = '0;
bit RESET = '0;

logic IO_CS0,IO_CS1;
logic M_CS0,M_CS1;

Intel8088Pins pins (  .CLK(CLK) , .RESET(RESET) );

Intel8088 P( pins.Processor );

//Instantiate 4 Modules
IOM #(.size(2**19)) Mem0 (M_CS0,pins.Peripheral);
IOM #(.size(2**19)) Mem1 (M_CS1,pins.Peripheral);
IOM #(.size(2**4)) IO_0 (IO_CS0,pins.Peripheral);
IOM #(.size(2**9)) IO_1 (IO_CS1,pins.Peripheral);

// 8282 Latch to latch bus address
always_latch
begin
if (pins.ALE)
	pins.Address <= {pins.A, pins.AD};
end

// 8286 transceiver
assign pins.Data =  (pins.DTR & ~pins.DEN) ? pins.AD   : 'z;
assign pins.AD   = (~pins.DTR & ~pins.DEN) ? pins.Data : 'z;

//Chipselect Logic
assign M_CS0=~(pins.Address[19] & ~pins.IOM);											//Active Low
assign M_CS1=~(~pins.Address[19] & ~pins.IOM);										//Active Low
assign IO_CS0=~((pins.Address[15:8] & ~pins.Address[7:4]) & pins.IOM);						//Active Low
assign IO_CS1=~((~pins.Address[15:13] & pins.Address[12:10] & ~pins.Address[9]) & pins.IOM);	//Active Low

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
