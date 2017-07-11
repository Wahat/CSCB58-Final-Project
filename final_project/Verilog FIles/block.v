module chooseblock(

block1,
block2,
block3,
block4,

choose,

numblocks;


);


input [3:0] numblocks;
input [15:0] block1;
input [15:0] block2;
input [15:0] block3;
input [15:0] block4;

input choose;

always@(*) begin

	case (numblocks[3:0])
			3'b000: begin // if block1
					  //set vertical or horz
					  block1[0] = choose; 
					
			end
			3'b001: begin // block2
			block2[0] = choose; 
					  
			end
			3'b010: begin // block3
			block3[0] = choose; 
					 
			end
			3'b011: begin // block4
			block4[0] = choose; 
					  
			end
	endcase
end




endmodule


module moveblock(
block1,
block2,
block3,
block4,

movexleft,
movexright,
moveyup,
moveydown,

set
);

input [15:0] block1;
input [15:0] block2;
input [15:0] block3;
input [15:0] block4;

input set;

input movexleft;
input movexright;
input moveyup;
input moveydown;

reg [6:0] currentx;
reg [6:0] currenty;

endmodule