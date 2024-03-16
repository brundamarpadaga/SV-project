module IOM(Intel8088Pins i, input CS);
parameter size = 2**19;

logic OE,WD;

typedef enum logic[4:0]{T1 = 5'b00001, T2 = 5'b00010, R = 5'b00100, W = 5'b01000, T4 = 5'b10000} states;
states next_state,current_state;

Mem #(.size(size)) MEM(i.CLK,i.RESET,i.Address,i.Data,OE,WD);

always_ff @(posedge i.CLK)
    begin
        if(i.RESET)
            current_state<=T1;
        else
            current_state<=next_state;
    end
    
always_comb
    begin
        
        unique case(current_state)                 
            T1: begin
                    if(!CS && i.ALE)
                        next_state=T2;
                    else
                        next_state=T1;
                end
            T2: begin
                    if(!i.RD)
                        next_state=R;
                    else if(!i.WR)
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

module Mem(CLK, RESET, Address, Data,OE,WD);
parameter size = 2**19;
input logic CLK,RESET,OE,WD;
input logic [19:0] Address;
inout logic [7:0] Data;

logic [$clog2(size)-1:0] AR;
logic [7:0] M[size-1:0];

initial begin
    $readmemh("init.txt",M);
end

assign AR = Address;
assign Data = !OE ? M[AR] : 'z;
    
    always_ff @(posedge CLK) begin
        if (!WD)
            M[AR] <= Data;
        else
            M[AR] <= M[AR];
    end
endmodule