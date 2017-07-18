module chooseblock(

block1,
block2,
block3,
block4,

choose,

numblocks

);


input [3:0] numblocks;
output [15:0] block1;
output [15:0] block2;
output [15:0] block3;
output [15:0] block4;

reg [15:0] block1;
reg [15:0] block2;
reg [15:0] block3;
reg [15:0] block4;

input choose;

always@(*) begin

	case (numblocks[3:0])
			3'b000: begin // if block1
					  //set vertical or horz
					  block1[0] <= choose;

			end
			3'b001: begin // block2
			block2[0] <= choose;

			end
			3'b010: begin // block3
			block3[0] <= choose;

			end
			3'b011: begin // block4
			block4[0] <= choose;

			end
	endcase
end
endmodule


module moveblock(
b1,
b2,
b3,
b4,

movexleft,
movexright,
moveyup,
moveydown,

set,
select,
);

input [15:0] b1;
input [15:0] b2;
input [15:0] b3;
input [15:0] b4;
input [2:0] select;

input set;

input movexleft;
input movexright;
input moveyup;
input moveydown;

reg [15:0] block1 = b1[15:0];
reg [15:0] block2 = b2[15:0];
reg [15:0] block3 = b3[15:0];
reg [15:0] block4 = b4[15:0];

reg [6:0] currentx;
reg [6:0] currenty;

always@(*) begin

	if (select == 2'b00) begin
		if (movexleft)
			block1[1:8] <= block1[1:8] - 1'b1;
		if (movexright)
			block1[1:8] <= block1[1:8] + 1'b1;
		if (moveyup)
			block1[9:15] <= block1[9:15] - 1'b1;
		if (moveyup)
			block1[9:15] <= block1[9:15] + 1'b1;

	end

	if (select == 2'b01) begin
		if (movexleft)
			block2[1:8] <= block2[1:8] - 1'b1;
		if (movexright)
			block2[1:8] <= block2[1:8] + 1'b1;
		if (moveyup)
			block2[9:15] <= block2[9:15] - 1'b1;
		if (moveyup)
			block2[9:15] <= block2[9:15] + 1'b1;
	end

	if (select == 2'b10) begin
		if (movexleft)
			block3[1:8] <= block3[1:8] - 1'b1;
		if (movexright)
			block3[1:8] <= block3[1:8] + 1'b1;
		if (moveyup)
			block3[9:15] <= block3[9:15] - 1'b1;
		if (moveyup)
			block3[9:15] <= block3[9:15] + 1'b1;
	end

	if (select == 2'b11) begin
		if (movexleft)
			block4[1:8] <= block4[1:8] - 1'b1;
		if (movexright)
			block4[1:8] <= block4[1:8] + 1'b1;
		if (moveyup)
			block4[9:15] <= block4[9:15] - 1'b1;
		if (moveyup)
			block4[9:15] <= block4[9:15] + 1'b1;
	end
end

endmodule
