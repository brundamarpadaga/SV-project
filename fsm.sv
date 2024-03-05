module IOM(clk,rst,Address,CS,RD,WR,ALE);
parameter SIZE = 2**19;
input logic [19:0] Address;
input logic clk,rst,CS,RD,WR,ALE;

logic OE,WD;

typedef enum logic[4:0]{T1 = 5'b00001, T2 = 5'b00010, R = 5'b00100, W = 5'b01000, T4 = 5'b10000} states;
logic [19:0] A;
states next_state,current_state;

assign A = Address;

always_ff @(posedge clk)
	begin
		if(rst)
			current_state=T1;
		else
			current_state=next_state;
	end	
	
always_comb
	begin
		case(current_state)
		T1: begin
				if(CS && ALE)
					next_state=T2;
				else
					next_state=T1;
			end
		T2: begin
				if(!RD)
					next_state=R;
				else if(!WR)
					next_state=W;
			end
		R: next_state=T4;
		W: next_state=T4;
		T4: begin if(CS && ALE)
				next_state=T2;
			else
				next_state=T1;
			end
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