// graphics module
// controls and outputs the graphics to the vga adapter
module graphics(clk, select, reset_n, ps2_key_data, ps2_key_pressed, blockselected, block1, block2, block3, block4, state, oob, hit, xout, yout, colourout, plot, blockout);
input clk;
input reset_n;
input [3:0] state;
input [1:0] select;
input [7:0] ps2_key_data;
input ps2_key_pressed;
input blockselected;
input [15:0] block1;
input [15:0] block2;
input [15:0] block3;
input [15:0] block4;

output hit;
output oob;
output reg [11:0] xout;
output reg [10:0] yout;
output reg [2:0] colourout;
output reg plot;
output [15:9] blockout;

// red sqaure
wire rsquareplot;
wire [10:0] rsxout;
wire [10:0] rsyout;
wire [2:0] rscolourout;
//black square
wire bsquareplot;
wire [10:0] bsxout;
wire [10:0] bsyout;
wire [2:0] bscolourout;

//vblock
wire vblplot;
wire [10:0] vblxout;
wire [10:0] vblyout;
wire [2:0] vblcolourout;

//hblock
wire hblplot;
wire [10:0] hblxout;
wire [10:0] hblyout;
wire [2:0] hblcolourout;

// ball
wire [10:0] bxout;
wire [10:0] byout;
wire [2:0] bcolourout;
wire ballplot;
reg balldraw = 1'b0;
reg enablered;
reg enableblack;
reg draw = 1'b0;
reg drawblockh = 1'b0;
reg drawblockv = 1'b0;
reg resetblock = 1'b0;

reg [10:0] rypos;
reg [10:0] bypos;

reg [2:0] colourin;

wire clock60hz;

always @ (posedge clk)
begin
balldraw <= 1'b0;
enablered <= 1'b0;
enableblack <= 1'b0;
draw <= 1'b0;
drawblockh <= 1'b0;
drawblockv <= 1'b0;

	case (state[3:0])
		4'b0000: begin // begin state
			rypos <= 11'b10010;
			xout[10:0] <= rsxout[10:0];
			yout[10:0] <= rsyout[10:0];
			colourout[2:0] <= rscolourout[2:0];
			enablered <= 1'b1;
		end

		4'b0001: begin //begin wait
			bypos[10:0] <= 11'b10010;
			xout[10:0] <= bsxout[10:0];
			yout[10:0] <= bsyout[10:0];
			colourout[2:0] <= bscolourout[2:0];
			enableblack <= 1'b1;
		end

		4'b0010: begin // load block
		rypos <= 11'b100111;
		xout[10:0] <= rsxout[10:0];
		yout[10:0] <= rsyout[10:0];
		colourout[2:0] <= rscolourout[2:0];
		enablered <= 1'b1;
		end

		4'b0011: begin // load block wait
		  bypos <= 11'b100111;
			xout[10:0] <= bsxout[10:0];
			yout[10:0] <= bsyout[10:0];
			colourout[2:0] <= bscolourout[2:0];
			enableblack <= 1'b1;
		end

		4'b0100: begin // load set
			rypos[10:0] <= 11'b111010;
			xout[10:0] <= rsxout[10:0];
			yout[10:0] <= rsyout[10:0];
			colourout[2:0] <= rscolourout[2:0];
			enablered <= 1'b1;
			resetblock = 1'b1;
		end

		4'b0101: begin // draw block
			resetblock = 1'b0;
			if (blockselected == 1'b1)
				drawblockv <= 1'b1;
			else
				drawblockh <= 1'b1;
		end

		4'b0110: begin // load set wait
				bypos <= 11'b10010;
				xout[10:0] <= bsxout[10:0];
				yout[10:0] <= bsyout[10:0];
				colourout[2:0] <= bscolourout[2:0];
				enableblack <= 1'b1;
		end
		4'b0111: begin // start game load
		   rypos[10:0] <= 11'b1001100;
			 xout[10:0] <= rsxout[10:0];
 			 yout[10:0] <= rsyout[10:0];
 			 colourout[2:0] <= rscolourout[2:0];
			 enablered <= 1'b1;

		end
		4'b1000: begin // start game
			balldraw <= 1'b1;
			xout[10:0] <= bxout[10:0];
			yout[10:0] <= byout[10:0];
			colourout[2:0] <= bcolourout[2:0];
			plot <= ballplot;
		end

		4'b1001: begin // start game wait
			bypos[10:0] <= 11'b1001100;
			xout[10:0] <= bsxout[10:0];
			yout[10:0] <= bsyout[10:0];
			colourout[2:0] <= bscolourout[2:0];
			enableblack <= 1'b1;
		end

		4'b1010: begin // endgame
			rypos[10:0] <= 11'b1011110;
			xout[10:0] <= rsxout[10:0];
			yout[10:0] <= rsyout[10:0];
			colourout[2:0] <= rscolourout[2:0];
			enablered <= 1'b1;
		end

		4'b1100: begin // endgame wait
			bypos[10:0] <= 11'b1011110;
			xout[10:0] <= bsxout[10:0];
			yout[10:0] <= bsyout[10:0];
			colourout[2:0] <= bscolourout[2:0];
			enableblack <= 1'b1;
		end

endcase
end

// old xpos = 10'b10000010
drawsquare redstate(
	.clk(clk),
	.reset_n(reset_n),
	.xpos(10'b1111010),
	.ypos(rypos),
	.colourin(3'b100),
	.ld_enable(enablered),
	.xout(rsxout),
	.yout(rsyout),
	.colourout(rscolourout),
	.plot(rsquareplot)
	);

	drawsquare blackstate(
		.clk(clk),
		.reset_n(reset_n),
		.xpos(10'b1111010),
		.ypos(bypos),
		.colourin(3'b000),
		.ld_enable(enableblack),
		.xout(bsxout),
		.yout(bsyout),
		.colourout(bscolourout),
		.plot(bsquareplot)
		);


	counterhz clock260hz(
		.enable(1'b1),
		.clk(clk),
		.reset_n(1'b0),
		.speed(3'b100), // 60hz
		.counterlimit(4'b0001), // only count up to 1
		.counterOut(clock60hz) // set the number of blocks
		);

/*
ball whiteball(
	.clk(clk & balldraw),
	.select(select),
	.enable(balldraw),
	.reset_n(reset_n),
	.hit(hit),
	.outofbounds(obb),
	.xout(bxout),
	.yout(byout),
	.colourout(bcolourout),
	.plot(ballplot)
	);
	*/
	drawvblock vblock (
		.clk(clk & drawblockv),
		.reset_n(resetblock),
		.enable(1'b1),
		.ps2_key_data(ps2_key_data),
		.ps2_key_pressed(ps2_key_pressed),
		.xout(vblxout),
		.yout(vblyout),
		.colourout(vblcolourout),
		.plot(vblplot)
		);

		drawhblock hblock (
			.clk(clk & drawblockh),
			.reset_n(resetblock),
			.enable(1'b1),
			.ps2_key_data(ps2_key_data),
			.ps2_key_pressed(ps2_key_pressed),
			.xout(hblxout),
			.yout(hblyout),
			.colourout(hblcolourout),
			.plot(hblplot)
			);

		drawball whiteball(
		.clk(clk & balldraw),
		.reset_n(reset_n),
		.enable(balldraw),
		.select(select),
		.hit(hit),
		.outofbounds(obb),
		.xout(bxout),
		.yout(byout),
		.colourout(bcolourout),
		.plot(ballplot)
		);


endmodule

module hdrawblock (
	 input clk,
	 input reset_n,
	 input [10:0] xpos,
	 input [10:0] ypos,
	 input [2:0] colourin,
   input ld_enable,

	 output [11:0] xout,
	 output [10:0] yout,
	 output [2:0] colourout,
	 output plot
	 );

	 // input registers
	 reg [11:0] x_in;
	 reg [10:0] y_in;
	 reg [2:0] colour_in;
	 reg [5:0] counter = 5'b000;
	 reg vga_out = 1'b0;

	 always@(posedge clk) begin
			 if(!reset_n) begin
					 x_in <= 11'b0;
					 y_in <= 10'b0;
					 colour_in <= 3'b0;
					 vga_out <= 1'b0;
					 counter <= 3'b000;
			 end
			 else begin
						 x_in[11:0] <= {1'b0, xpos[10:0]}; // load alu_out if load_alu_out signal is high, otherwise load from data_in
						 y_in[10:0] <= ypos[10:0]; // load alu_out if load_alu_out signal is high, otherwise load from data_in
					 if(vga_out) begin
							 counter <= counter + 1'b1;
							 if (counter == 4'b000) begin
							 		vga_out <= 1'b0;
								end
					  end
						if (ld_enable) begin
							vga_out <= 1'b1;
						end
			 end
	 end
	 assign plot = vga_out;
	 assign xout[11:0] = x_in[11:0] + counter[0];
	 assign yout[10:0] = y_in[10:0] + counter[5:1];
	 assign colourout = colourin;
endmodule

module vdrawblock (
	 input clk,
	 input reset_n,
	 input [10:0] xpos,
	 input [10:0] ypos,
	 input [2:0] colourin,
   input ld_enable,

	 output [11:0] xout,
	 output [10:0] yout,
	 output [2:0] colourout,
	 output plot
	 );

	 // input registers
	 reg [11:0] x_in;
	 reg [10:0] y_in;
	 reg [2:0] colour_in;
	 reg [14:0] counter = 5'b000;
	 reg vga_out = 1'b0;

	 always@(posedge clk) begin
			 if(!reset_n) begin
					 x_in <= 11'b0;
					 y_in <= 10'b0;
					 colour_in <= 3'b0;
					 vga_out <= 1'b0;
					 counter <= 3'b000;
			 end
			 else begin
						 x_in[11:0] <= {1'b0, xpos[10:0]};
						 y_in[10:0] <= ypos[10:0];
					 if(vga_out) begin
							 counter <= counter + 1'b1;
							 if (counter == 4'b000) begin
							 		vga_out <= 1'b0;
								end
					  end
						if (ld_enable) begin
							vga_out <= 1'b1;
						end
			 end
	 end
	 assign plot = vga_out;
	 assign xout[11:0] = x_in[11:0] + counter[4:0];
	 assign yout[10:0] = y_in[10:0] + counter[5];
	 assign colourout = colourin;
endmodule

module drawsquare (
	 input clk,
	 input reset_n,
	 input [10:0] xpos,
	 input [10:0] ypos,
	 input [2:0] colourin,
   input ld_enable,

	 output [11:0] xout,
	 output [10:0] yout,
	 output reg [2:0] colourout,
	 output plot
	 );

	 // input registers
	 reg [11:0] x_in;
	 reg [10:0] y_in;
	 reg [3:0] counter = 4'b000;
	 reg vga_out = 1'b0;

	 always@(posedge clk) begin
			 if(!reset_n) begin
					 x_in <= 11'b0;
					 y_in <= 10'b0;
					 colourout <= 3'b0;
					 vga_out <= 1'b0;
					 counter <= 3'b000;
			 end
			 else begin
						 x_in[11:0] <= {1'b0, xpos[10:0]};
						 y_in[10:0] <= ypos[10:0];
						 colourout <= colourin;
					 if(vga_out) begin
							 counter <= counter + 1'b1;
							 if (counter == 4'b000) begin
							 		vga_out <= 1'b0;
								end
					  end
						if (ld_enable) begin
							vga_out <= 1'b1;
						end
			 end
	 end
	 assign plot = vga_out;
	 assign xout[11:0] = x_in[11:0] + counter[1:0];
	 assign yout[10:0] = y_in[10:0] + counter[3:2];
endmodule


module clearscreen (
	 input clk,
	 input reset_n,
   input ld_enable,

	 output [11:0] xout,
	 output [10:0] yout,
	 output reg [2:0] colourout,
	 output plot
	 );

	 // input registers
	 reg [11:0] x_in;
	 reg [10:0] y_in;
	 reg [2:0] colour_in;
	 reg [7:0] counter = 7'b000;
	 reg vga_out = 1'b0;

	 always@(posedge clk) begin
			 if(!reset_n) begin
					 x_in <= 11'b0;
					 y_in <= 10'b0;
					 vga_out <= 1'b0;
					 counter <= 7'b000;
					 colourout <= 1'b0;
			 end
			 else begin
			 			 colourout <= 1'b0;
						 x_in[11:0] <= 11'b01; // load alu_out if load_alu_out signal is high, otherwise load from data_in
						 y_in[10:0] <= 11'b100; // load alu_out if load_alu_out signal is high, otherwise load from data_in
					 if(vga_out) begin
							 counter <= counter + 1'b1;
							 if (counter == 7'b000) begin
							 		vga_out <= 1'b0;
								end
					  end
						if (ld_enable) begin
							vga_out <= 1'b1;
						end
			 end
	 end
	 assign xout[11:0] = x_in[11:0] + counter[3:0];
	 assign yout[10:0] = y_in[10:0] + counter[7:4];
endmodule

module ball(clk, select, enable, reset_n, hit, outofbounds, xout, yout, colourout, plot);
	input clk;
	input reset_n;
	input [1:0] select;
	input enable;

	output hit;
	output outofbounds;
	output [10:0] xout;
	output [10:0] yout;
	output [2:0] colourout;
	output plot;

  wire clock60hz;
	wire [10:0] xposout;
	wire [10:0] yposout;
	wire dirx;
	wire diry;
	wire clockout;
	wire [2:0] cout;

counterhz clock_60hz(
	.enable(enable),
	.clk(clk),
	.reset_n(1'b0),
	.speed(3'b100), // 60hz
	.counterlimit(4'b0001), // only count up to 1
	.counterOut(clock60hz) // set the number of blocks
	);

drawsquare ball(
	.clk(clk),
	.reset_n(reset_n),
	.xpos(xposout),
	.ypos(yposout),
	.colourin(cout), // make white
	.ld_enable(!outofbounds), // only move if the ball is not outofbounds
	.xout(xout),
	.yout(yout),
	.colourout(colourout),
	.plot(plot)
	);

ballpos ballpos(
	.clk(clock60hz),
	.reset(reset_n),
	.speed(3'b001),
	.dir_x(dirx),		// 0 = LEFT, 1 = RIGHT
	.dir_y(diry),		// 0 = UP, 1 = DOWN
	// output to drawsquare
	.value_x(xposout),
	.value_y(yposout)
	);

ballcollisions collide(
	.clk(clock60hz),
	.reset(reset_n),
	.ball_x(xposout),
	.ball_y(yposout),
	.dir_x(dirx),
	.dir_y(diry),
	.oob(outofbounds),	// whether ball is out of bounds
	.hit(hit),
	.dir_xstart(select[0]),
	.dir_ystart(select[1]),
	.bar1(10'b1111111111),
	.bar2(10'b1111111111),
	.bar3(10'b1111111111),
	.bar4(10'b1111111111)
	);

	counterhz clock2hz(
		.enable(enable),
		.clk(clk),
		.reset_n(1'b0),
		.speed(3'b100), // 60hz
		.counterlimit(4'b001), // only count up to 1
		.counterOut(clockout) // set the number of blocks
		);

	ballcolour ballc(
		.clk(clockout),
		.colourout(cout)
		);
endmodule

module ballcolour(clk, colourout);
input clk;
output [3:0] colourout;
assign colourout = clk ? 3'b111: 3'b000;

endmodule

module drawball(clk, reset_n, select, enable, block1, block2, block3, block4, hit, outofbounds, xout, yout, colourout,plot);
input clk;
input reset_n;
input [1:0] select;
input enable;
input block1;
input block2;
input block3;
input block4;

output hit;
output outofbounds;
output [10:0] xout;
output [10:0] yout;
output [2:0] colourout;
output plot;

wire clock60hz;
wire [10:0] xposout;
wire [10:0] yposout;
wire dirx;
wire diry;
wire clockout;
wire [2:0] cout;
reg drawsquare;
reg [3:0] colour;
wire clk240;
wire clk120;

reg [3:0] current_state;
reg [27:0] count;
reg [11:0] xpos;
reg [10:0] ypos;
reg clkenable;

localparam  INIT    = 3'd0,
						START    = 3'd1,
						DRAWBALL = 3'd2,
						WAIT1    = 3'd3,
						ERASEBALL =3'd4,
						CHECK     =3'd5;
always @(posedge clock60hz & enable & !outofbounds)
begin
		case(current_state)
		INIT: begin
		xpos = 11'b10;
		ypos = 11'b11111;
		count = 27'b0;
		current_state = DRAWBALL;
		colour = 3'b000;
		end
		DRAWBALL: begin
			clkenable = 1'b0;
			if (count < 6'b100000) begin
				 count = count + 1'b1;
				 colour = 3'b111;
			end
		else begin
			count = 27'b0;
			current_state = WAIT1;
		end
		end
		WAIT1: begin
				current_state = clk120 ? WAIT1: ERASEBALL;
		end
		ERASEBALL: begin
		if (count < 6'b100000) begin
			 count = count + 1'b1;
			 colour = 3'b000;
		end
	else begin
		count = 27'b0;
		current_state = CHECK;
	end
	end
		CHECK: begin
			clkenable = 1'b1;
			xpos = xposout;
			ypos = yposout;
			current_state = DRAWBALL;
		end
		endcase
end

counterhz clock_60hz(
.enable(1'b1),
.clk(clk),
.reset_n(1'b0),
.speed(3'b100), // 60hz
.counterlimit(4'b0001), // only count up to 1
.counterOut(clock60hz) // set the number of blocks
);

drawsquare ball(
.clk(clk),
.reset_n(reset_n),
.xpos(xpos),
.ypos(ypos),
.colourin(colour), // make white
.ld_enable(!outofbounds), // only move if the ball is not outofbounds
.xout(xout),
.yout(yout),
.colourout(colourout),
.plot(plot)
);

ballpos ballpos(
.clk(clock60hz & clkenable),
.reset(reset_n),
.speed(3'b001),
.dir_x(dirx),		// 0 = LEFT, 1 = RIGHT
.dir_y(diry),		// 0 = UP, 1 = DOWN
// output to drawsquare
.value_x(xposout),
.value_y(yposout)
);

ballcollisions collide(
.clk(clock60hz & clkenable),
.reset(reset_n),
.ball_x(xposout),
.ball_y(yposout),
.dir_x(dirx),
.dir_y(diry),
.oob(outofbounds),	// whether ball is out of bounds
.hit(hit),
.dir_xstart(select[0]),
.dir_ystart(select[1]),
.bar1(10'b1111111111),
.bar2(10'b1111111111),
.bar3(10'b1111111111),
.bar4(10'b1111111111)
);

counterhz count120hz(
	.enable(1'b1),
	.reset_n(reset_n),
	.clk(clk),
	.speed(3'b111),
	.counterlimit(4'b001),
	.counterOut(clk120)
	);

	counterhz count240hz(
		.enable(1'b1),
		.reset_n(reset_n),
		.clk(clk),
		.speed(3'b110),
		.counterlimit(4'b001),
		.counterOut(clk240)
		);

endmodule

module drawhblock (clk, reset_n, enable,typeb, ps2_key_data, ps2_key_pressed, block, xout, yout, colourout, plot);
input clk;
input reset_n;
input enable;
input typeb;
input ps2_key_pressed;
input [7:0] ps2_key_data;
output [11:0] xout;
output [11:0] yout;
output [3:0] colourout;
output plot;

wire clock60hz;
wire clk240;
wire clock120;


input [15:0] block;

reg [15:0] blockout;
reg [3:0] colour;


reg [3:0] current_state;
reg [27:0] count;
reg [11:0] xpos;
reg [10:0] ypos;
reg clkenable;

// regs that hold the final positions of the blocks
initial begin
	blockout = block;
end

localparam  INIT    = 3'd0,
						DRAWBLOCK = 3'd2,
						WAIT1    = 3'd3,
						ERASEBLOCK =3'd4,
						CHECK     = 3'd5,
						END       = 3'd6;

		always @(posedge clock60hz)
		begin
				if (!reset_n) begin
					 current_state = INIT;
				end
				case(current_state)
				INIT: begin
				blockout[15:9] = 7'b0011111;
				blockout[8:1]  = 7'b0011111;
				count = 27'b0;
				current_state = DRAWBLOCK;
				colour = 3'b100;
				end
				DRAWBLOCK: begin
					clkenable = 1'b0;
					if (count < 6'b100000) begin
						 count = count + 1'b1;
						 colour = 3'b100;
					end
				else begin
					count = 27'b0;
					current_state = WAIT1;
				end
				end
				WAIT1: begin
						current_state = clk240 ? WAIT1: ERASEBLOCK;
				end
				ERASEBLOCK: begin
				if (count < 6'b100000) begin
					 count = count + 1'b1;
					 colour = 3'b000;
				end
			else begin
				count = 27'b0;
				current_state = CHECK;
			end
			end
				CHECK: begin
				if (ps2_key_data == 8'h6b) begin
					blockout[8:1] = blockout[8:1] - 2'b10;
					current_state = DRAWBLOCK;
				end
				if (ps2_key_data == 8'h74) begin
					blockout[8:1] = blockout[8:1] + 2'b10;
					current_state = DRAWBLOCK;
				end
				if (ps2_key_data == 8'h75) begin
					blockout[15:9] = blockout[15:9] - 2'b10;
					current_state = DRAWBLOCK;
					end
				if (ps2_key_data == 8'h72)begin
					blockout[15:9] = blockout[15:9] + 2'b10;
					current_state = DRAWBLOCK;
				end
				if (ps2_key_data == 8'h29)begin
					current_state = END;
				end
				end
				END: begin
						colour = 3'b101;
				end
				endcase
		end

counterhz count240hz(
	.enable(1'b1),
	.reset_n(reset_n),
	.clk(clk),
	.speed(3'b011),
	.counterlimit(4'b001),
	.counterOut(clk240)
	);

hdrawblock hblock(
	 .clk(clk),
	 .reset_n(reset_n),
	 .xpos(blockout[8:1]),
	 .ypos(blockout[15:9]),
	 .colourin(colour),
	 .ld_enable(1'b1),
	 .xout(xout),
	 .yout(yout),
	 .colourout(colourout),
	 .plot(plot)
	 );

counterhz clock_60hz(
.enable(1'b1),
.clk(clk),
.reset_n(1'b0),
.speed(3'b100), // 60hz
.counterlimit(4'b0001), // only count up to 1
.counterOut(clock60hz) // set the number of blocks
);
endmodule

	module drawvblock (clk, reset_n, enable, ps2_key_data, ps2_key_pressed, block, xout, yout, colourout, plot, blockout);
	input clk;
	input reset_n;
	input enable;
	input ps2_key_pressed;
	input [7:0] ps2_key_data;
	output [11:0] xout;
	output [11:0] yout;
	output [3:0] colourout;
	output plot;

	wire clock60hz;
	wire clk240;
	wire clock120;


	input [15:0] block;

	output reg [15:0] blockout;
	reg [3:0] colour;


	reg [3:0] current_state;
	reg [27:0] count;
	reg [11:0] xpos;
	reg [10:0] ypos;
	reg clkenable;

	// regs that hold the final positions of the blocks
	initial begin
		blockout = block;
	end

	localparam  INIT    = 3'd0,
							DRAWBLOCK = 3'd2,
							WAIT1    = 3'd3,
							ERASEBLOCK =3'd4,
							CHECK     = 3'd5,
							END       = 3'd6;

			always @(posedge clock60hz)
			begin
					if (!reset_n) begin
						 current_state = INIT;
					end
					case(current_state)
					INIT: begin
					blockout[15:9] = 7'b0011111;
					blockout[8:1]  = 7'b0011111;
					count = 27'b0;
					current_state = DRAWBLOCK;
					colour = 3'b100;
					end
					DRAWBLOCK: begin
						clkenable = 1'b0;
						if (count < 6'b100000) begin
							 count = count + 1'b1;
							 colour = 3'b100;
						end
					else begin
						count = 27'b0;
						current_state = WAIT1;
					end
					end
					WAIT1: begin
							current_state = clk240 ? WAIT1: ERASEBLOCK;
					end
					ERASEBLOCK: begin
					if (count < 6'b100000) begin
						 count = count + 1'b1;
						 colour = 3'b000;
					end
				else begin
					count = 27'b0;
					current_state = CHECK;
				end
				end
					CHECK: begin
					if (ps2_key_data == 8'h6b) begin
						blockout[8:1] = blockout[8:1] - 2'b10;
						current_state = DRAWBLOCK;
					end
					if (ps2_key_data == 8'h74) begin
						blockout[8:1] = blockout[8:1] + 2'b10;
						current_state = DRAWBLOCK;
					end
					if (ps2_key_data == 8'h75) begin
						blockout[15:9] = blockout[15:9] - 2'b10;
						current_state = DRAWBLOCK;
						end
					if (ps2_key_data == 8'h72)begin
						blockout[15:9] = blockout[15:9] + 2'b10;
						current_state = DRAWBLOCK;
					end
					if (ps2_key_data == 8'h29)begin
						current_state = END;
					end
					end
					END: begin
							colour = 3'b101;
					end
					endcase
			end

	counterhz count240hz(
		.enable(1'b1),
		.reset_n(reset_n),
		.clk(clk),
		.speed(3'b011),
		.counterlimit(4'b001),
		.counterOut(clk240)
		);

	vdrawblock vblock(
		.clk(clk),
		.reset_n(reset_n),
		.xpos(blockout[8:1]),
		.ypos(blockout[15:9]),
		.colourin(colour),
		.ld_enable(1'b1),
		.xout(xout),
		.yout(yout),
		.colourout(colourout),
		.plot(plot)
		);

	counterhz clock_60hz(
	.enable(1'b1),
	.clk(clk),
	.reset_n(1'b0),
	.speed(3'b100), // 60hz
	.counterlimit(4'b0001), // only count up to 1
	.counterOut(clock60hz) // set the number of blocks
	);
		endmodule
