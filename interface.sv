interface  Intel8088Pins (input logic CLK,RESET);  

	//8088 Signals
	logic MNMX = '1;
	logic TEST = '1;
	logic READY = '1;
	logic NMI = '0;
	logic INTR = '0;
	logic HOLD = '0;

	logic HLDA;
	tri [7:0] AD;
	tri [19:8] A;
	logic CS;
	logic IOM;
	logic WR;
	logic RD;
	logic SSO;
	logic INTA;
	logic ALE;
	logic DTR;
	logic DEN;

	//Address and Data bus
	logic [19:0] Address;	
	wire [7:0]  Data;

    modport  Processor (input CLK, RESET, MNMX,TEST,READY,NMI,INTR,HOLD,
                        output ALE,IOM,WR,RD,DTR,DEN,SSO,A,HLDA,INTA,	
						inout AD
                         );

    modport Peripheral (
						input CLK,
						input RESET,
						inout Data,
						input Address,
						input ALE,
						input RD,
						input WR);   

endinterface