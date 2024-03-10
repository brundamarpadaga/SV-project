module IOM(clk,rst,Address,CS,RD,WR,ALE,Data);
parameter M = 0;
parameter size = 2**19;
input logic [19:0] Address;
input logic clk,rst,CS,RD,WR,ALE;
inout logic [7:0] Data;
logic OE,WD;

typedef enum logic[4:0]{T1 = 5'b00001, T2 = 5'b00010, R = 5'b00100, W = 5'b01000, T4 = 5'b10000} states;
logic [19:0] A;
states next_state,current_state;

assign A = Address;

genvar i;
generate
	if(M==0)
		M0 #(size) Mem0(clk,rst,Address,Data,OE,WD);
	else if(M==1)
		M1 #(size) Mem1(clk,rst,Address,Data,OE,WD);
	else if(M==2)
		I_0 #(size) IO_0(clk,rst,Address,Data,OE,WD);
	else
		I_1 #(size) IO_1(clk,rst,Address,Data,OE,WD);
endgenerate

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
				if(!CS && ALE)
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
		T4: begin if(!CS && ALE)
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

module M0(clk,rst,Address,Data,OE,WD);
parameter size = 2**19;
input logic clk,rst,OE,WD;
input logic [19:0] Address;
inout logic [7:0] Data;

logic [7:0] M[2*size-1:size];
logic [7:0] data_internal;

initial begin
	$readmemh("init.txt",M);
end

assign data_internal = M[Address];
assign Data = !OE?data_internal:'z;
    
    always_ff @(posedge clk) begin
        if (!WD && OE)
            M[Address] <= Data;
		else
			M[Address] <= M[Address];
    end
endmodule

module M1(clk,rst,Address,Data,OE,WD);
parameter size = 2**19;
input logic clk,rst,OE,WD;
input logic [19:0] Address;
inout logic [7:0] Data;

logic [7:0] M[size-1:0];
logic [7:0] data_internal;

initial begin
	$readmemh("init.txt",M);
end

assign data_internal = M[Address];
assign Data = !OE?data_internal:'z;
    
    always_ff @(posedge clk) begin
        if (!WD)
            M[Address] <= Data;
		else
			M[Address] <= M[Address];
    end
endmodule

module I_0(clk,rst,Address,Data,OE,WD);
parameter size = 2**19;
localparam K = 16'hFF00;
input logic clk,rst,OE,WD;
input logic [19:0] Address;
inout logic [7:0] Data;

logic [7:0] I[K+size-1:K];
logic [7:0] data_internal;

initial begin
	$readmemh("IO_init0.txt",I);
end

assign data_internal = I[Address];
assign Data = !OE?data_internal:'z;
    
    always_ff @(posedge clk) begin
        if (!WD)
            I[Address] <= Data;
		else
			I[Address] <= I[Address];
    end
endmodule

module I_1(clk,rst,Address,Data,OE,WD);
parameter size = 2**19;
localparam K = 16'h1C00;
input logic clk,rst,OE,WD;
input logic [19:0] Address;
inout logic [7:0] Data;

logic [7:0] I[K+size-1:K];  
logic [7:0] data_internal;

initial begin
	$readmemh("IO_init1.txt",I);
end

assign data_internal = I[Address];
assign Data = !OE?data_internal:'z;
    
    always_ff @(posedge clk) begin
        if (!WD)
            I[Address] <= Data;
		else
			I[Address] <= I[Address];
    end
endmodule