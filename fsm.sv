module IOM(CS, pins);
parameter size = 2**19;
input logic CS;

Intel8088Pins pins;
logic OE,WD;

typedef enum logic[4:0]{T1 = 5'b00001, T2 = 5'b00010, R = 5'b00100, W = 5'b01000, T4 = 5'b10000} states;
states next_state,current_state;

Mem #(.size(size)) MEM(pins.CLK,pins.RESET,pins.Address,pins.Data,OE,WD);

always_ff @(posedge pins.CLK)
	begin
		if(pins.RESET)
			current_state<=T1;
		else
			current_state<=next_state;
	end	
	
always_comb
	begin
		
		unique case(current_state)                 
			T1: begin
					if(!CS && pins.ALE)
						next_state=T2;
					else
						next_state=T1;
				end
			T2: begin
					if(!pins.RD)
						next_state=R;
					else if(!pins.WR)
						next_state=W;
				end
			R: next_state = T4;
			W: next_state = T4;
			T4: next_state = T1;
		default: next_state = T1;
		endcase
	end
	
always_comb
	begin	
		{OE,WD} = 2'b11;
		case(current_state)
			T1: {OE,WD} = 2'b11;
			T2: {OE,WD} = 2'b11;
			R:  {OE,WD} = 2'b01;
			W:  {OE,WD} = 2'b10;
			T4: {OE,WD} = 2'b11;
		endcase
	end	
endmodule

module Mem(clk,rst,Address,Data,OE,WD);
parameter size = 2**19;
input logic clk,rst,OE,WD;
input logic [19:0] Address;
inout logic [7:0] Data;

logic [$clog2(size)-1:0] AR;	//using least significant bits of Address
logic [7:0] M[size-1:0];

initial begin
	$readmemh("init.txt",M);	//Initialising the memory array
end

assign AR = Address;
assign Data = !OE ? M[AR] : 'z;
    
    always_ff @(posedge clk) begin
		if (!WD)
            M[AR] <= Data;
		else
			M[AR] <= M[AR];
    end
endmodule