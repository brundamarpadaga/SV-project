module top;
logic CLK = '0;
logic RESET = '0;

logic IO_CS0,IO_CS1;
logic M_CS0,M_CS1;
	
Intel8088Pins i(CLK,RESET);
Intel8088 P(.i(i.Processor)); 

//Instantiate 4 Modules
IOM #(.size(2**19)) Mem0 (.i(i.Peripheral),.CS(M_CS0));
IOM #(.size(2**19)) Mem1 (.i(i.Peripheral),.CS(M_CS1));
IOM #(.size(2**4)) IO_0 (.i(i.Peripheral),.CS(IO_CS0));
IOM #(.size(2**9)) IO_1 (.i(i.Peripheral),.CS(IO_CS1));

// 8282 Latch to latch bus address
always_latch
begin
if (i.ALE)
	i.Address <= {i.A, i.AD};
end

// 8286 transceiver
assign i.Data =  (i.DTR & ~i.DEN) ? i.AD   : 'z;
assign i.AD   = (~i.DTR & ~i.DEN) ? i.Data : 'z;

//Chipselect Logic
assign M_CS0 = ~(~i.Address[19] & ~i.IOM);											//Active Low
assign M_CS1 = ~(i.Address[19] & ~i.IOM);										//Active Low
assign IO_CS0 = ~((i.Address[15:8] & ~i.Address[7:4]) & i.IOM);						//Active Low
assign IO_CS1 = ~((~i.Address[15:13] & i.Address[12:10] & ~i.Address[9]) & i.IOM);	//Active Low

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
