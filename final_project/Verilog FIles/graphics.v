// graphics module
// controls and outputs the graphics to the vga adapter
module graphics(clk, select, reset_n, state, oob, hit, xout, yout, colourout, plot);
input clk;
input reset_n;
input [3:0] state;
input [1:0] select;

output hit;
output oob;
output reg [11:0] xout;
output reg [10:0] yout;
output reg [2:0] colourout;
output reg plot;

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

wire [10:0] bxout;
wire [10:0] byout;
wire [2:0] bcolourout;
wire ballplot;
reg balldraw = 1'b0;
reg enablered;
reg enableblack;
reg draw = 1'b0;

reg [10:0] rypos;
reg [10:0] bypos;

reg [2:0] colourin;

wire clock60hz;

always @ (posedge clk)
begin
balldraw <= 1'b0;
enablered <= 1'b1;
enableblack <= 1'b1;
draw <= 1'b0;

	case (state[3:0])
		4'b0000: begin // begin state
			rypos <= 11'b10010;
			xout[10:0] <= rsxout[10:0];
			yout[10:0] <= rsyout[10:0];
			colourout[2:0] <= rscolourout[2:0];
			plot <= rsquareplot;
		end

		4'b0001: begin //begin wait
			bypos[10:0] <= 11'b10010;
			xout[10:0] <= bsxout[10:0];
			yout[10:0] <= bsyout[10:0];
			colourout[2:0] <= bscolourout[2:0];
			plot <= bsquareplot;
		end

		4'b0010: begin // load block
			rypos <= 11'b100111;
			xout[10:0] <= rsxout[10:0];
			yout[10:0] <= rsyout[10:0];
			colourout[2:0] <= rscolourout[2:0];
			plot <= rsquareplot;
		end

		4'b0011: begin // load block wait
		  bypos <= 11'b100111;
			xout[10:0] <= bsxout[10:0];
			yout[10:0] <= bsyout[10:0];
			colourout[2:0] <= bscolourout[2:0];
			plot = bsquareplot;
		end

		4'b0100: begin // load set
			rypos[10:0] <= 11'b111010;
			xout[10:0] <= rsxout[10:0];
			yout[10:0] <= rsyout[10:0];
			colourout[2:0] <= rscolourout[2:0];
			plot <= rsquareplot;
		end

		4'b0101: begin // load set wait
				bypos <= 11'b10010;
				xout[10:0] <= bsxout[10:0];
				yout[10:0] <= bsyout[10:0];
				colourout[2:0] <= bscolourout[2:0];
				plot <= bsquareplot;
		end

		4'b0110: begin // start game
		 // yposr[10:0] <= 11'b1001100;
			balldraw <= 1'b1;
			xout[10:0] <= bxout[10:0];
			yout[10:0] <= byout[10:0];
			colourout[2:0] <= bcolourout[2:0];
			plot <= ballplot;
		end

		4'b0111: begin // start game wait
		end

		4'b1000: begin // endgame
			rypos[10:0] <= 11'b1011110;
			xout[10:0] <= rsxout[10:0];
			yout[10:0] <= rsyout[10:0];
			colourout[2:0] <= rscolourout[2:0];
			plot <= rsquareplot;
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
		.ld_enable(1'b1),
		.xout(bsxout),
		.yout(bsyout),
		.colourout(bscolourout),
		.plot(bsquareplot)
		);
/*
	drawsquare state3(
		.clk(clk),
		.reset_n(reset_n),
		.xpos(11'b10010100),
		.ypos(11'b10010),
		.colourin(3'b100),
		.ld_enable(enablered),
		.xout(rsxout),
		.yout(rsyout),
		.colourout(rscolourout),
		.plot(rsquareplot)
		);

		drawsquare state4(
			.clk(clk),
			.reset_n(reset_n),
			.xpos(11'b10010100),
			.ypos(11'b10010),
			.colourin(3'b100),
			.ld_enable(enablered),
			.xout(rsxout),
			.yout(rsyout),
			.colourout(rscolourout),
			.plot(rsquareplot)
			);
*/
/*
drawsquare blackstate(
	.clk(clk),
	.reset_n(reset_n),
	.xpos(11'b10010100),
	.ypos(yposb[10:0]),
	.colourin(colourin[2:0]),
	.ld_enable(enableblack),
	.xout(xout),
	.yout(yout),
	.colourout(colourout[2:0]),
	.plot(plot)
	);
	*/

	counterhz clock260hz(
		.enable(1'b1),
		.clk(clk),
		.reset_n(1'b0),
		.speed(3'b100), // 60hz
		.counterlimit(4'b0001), // only count up to 1
		.counterOut(clock60hz) // set the number of blocks
		);

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
	 reg [3:0] counter = 4'b000;
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
	 assign xout[11:0] = x_in[11:0] + counter[1:0];
	 assign yout[10:0] = y_in[10:0] + counter[3:2];
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
	 reg [14:0] counter = 4'b000;
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
	 assign xout[11:0] = x_in[11:0] + counter[1:0];
	 assign yout[10:0] = y_in[10:0] + counter[3:2];
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
						 x_in[11:0] <= {1'b0, xpos[10:0]}; // load alu_out if load_alu_out signal is high, otherwise load from data_in
						 y_in[10:0] <= ypos[10:0]; // load alu_out if load_alu_out signal is high, otherwise load from data_in
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
