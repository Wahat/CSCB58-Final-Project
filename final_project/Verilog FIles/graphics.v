// graphics module
// controls and outputs the graphics to the vga adapter
module graphics(clk, reset_n, state, oob, hit, xout, yout, colourout, plot);
input clk;
input reset_n;
input [3:0] state;

output hit;
output outofbounds;
output reg [11:0] xout;
output reg [10:0] yout;
output reg [2:0] colourout;
output reg plot;

wire rsquareplot;
wire rsxout;
wire rsyout;
wire [8:0] cxpos;
wire [8:0] cypos;
wire bxout;
wire byout;
wire bcolourout;
wire ballplot;

reg [2:0] colourin;

always @ (posedge clk)
begin
	case (state[3:0])
	3'b000: begin // begin state
	end
	3'b001: begin // load block
	end
	3'b010: begin // load set
	end
	3'b011: begin // load start game
		xout <= bxout;
		yout <= byout;
		colourout <= bcolourout;
		plot <= ballplot;
	end
	3'b100: begin // load end game
		xout <= rsxout;
		yout <= rsyout;
		plot <= rsquareplot;
	end
endcase
end

drawsquare state(
	.clk(clk),
	.reset_n(reset_n),
	.xpos(11'b10010100),
	.ypos(yposr[10:0]),
	.colourin(colourin[2:0]),
	.ld_enable(enablered),
	.xout(rsxout),
	.yout(rsyout),
	.colourout(colourout[2:0]),
	.plot(rsquareplot)
	);

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

ball whiteball(
	.clk(clk),
	.reset_n(reset_n),
	.hit(hit),
	.outofbounds(obb),
	.xout(byout),
	.yout(byout),
	.colourout(bcolourout),
	.plot(ballplot)
	);

endmodule

/*
module highlightstate(clk, reset_n, colourin, state, xout, yout, colourout, plot);
	input clk;
	input reset_n;
	input [2:0] colourin;
	input [3:0] state;
	output [11:0] xout;
	output [10:0] yout;
	output [2:0] colourout;
	output plot;

	reg [10:0] yposb;
	reg [10:0] yposr;
	reg vga_out = 1'b0;
	reg [1:0] draw = 2'b00;
	reg enableblack = 1'b0;
	reg enablered = 1'b0;

	always @ (*)
	begin
		case (state[3:0])
			3'b000: begin // begin state
							if (draw == 2'b00) begin
							  yposb[10:0] <= 11'b1011110;
								draw <= draw + 1'b1;
								vga_out <= 1'b1;
								enableblack <= 1'b1;
							end
							else if (draw == 2'b01) begin
								yposr[10:0] <= 11'b10010;
								draw <= draw + 1'b1;
								vga_out <= 1'b1;
								enablered <= 1'b1;
							end
							vga_out <= 1'b0;
							enableblack <= 1'b0;
							enablered <= 1'b0;
			end
			3'b001: begin // load block
							if (draw == 2'b00) begin
							  yposb[10:0] <= 11'b10010;
								draw <= draw + 1'b1;
								vga_out = 1'b1;
								enableblack <= 1'b1;
							end
							else if (draw == 2'b01) begin
								yposr[10:0] <= 11'b100111;
								draw <= draw + 1'b1;
								vga_out <= 1'b1;
								enablered <= 1'b1;
							end
							vga_out <= 1'b0;
							enableblack <= 1'b0;
							enablered <= 1'b0;

			end
			3'b010: begin // load set
							if (draw == 2'b00) begin
							  yposb[10:0] <= 11'b100111;
								draw <= draw + 1'b1;
								vga_out <= 1'b1;
								enableblack <= 1'b1;
							end
							else if (draw == 2'b01) begin
								yposr[10:0] <= 11'b111010;
								draw <= draw + 1'b1;
								vga_out <= 1'b1;
								enablered <= 1'b1;
							end
							vga_out <= 1'b0;
							enableblack <= 1'b0;
							enablered <= 1'b0;
			end
			3'b011: begin // load start game
							if (draw == 2'b00) begin
							  yposb[10:0] <= 11'b111010;
								draw <= draw + 1'b1;
								vga_out = 1'b1;
								enableblack <= 1'b1;
							end
							else if (draw == 2'b01) begin
								yposr[10:0] <= 11'b1001100;
								draw <= draw + 1'b1;
								vga_out <= 1'b1;
								enablered <= 1'b1;
							end
							vga_out <= 1'b0;
							enableblack <= 1'b0;
							enablered <= 1'b0;
			end
			3'b100: begin // load end game
							if (draw == 2'b00) begin
							  yposb[10:0] <= 11'b1001100;
								draw <= draw + 1'b1;
								vga_out = 1'b1;
								enableblack <= 1'b1;
							end
							else if (draw == 2'b01) begin
								yposr[10:0] <= 11'b1011110;
								draw <= draw + 1'b1;
								vga_out <= 1'b1;
								enablered <= 1'b1;
							end
							vga_out <= 1'b0;
							enableblack <= 1'b0;
							enablered <= 1'b0;
			end

	    endcase
	end

	drawsquare red(
		.clk(clk),
		.reset_n(resetn),
		.xpos(11'b10010100),
		.ypos(yposr[10:0]),
		.colourin(colourin[2:0]),
		.ld_enable(enablered),
		.xout(xout),
		.yout(yout),
		.colourout(colourout[2:0]),
		.plot(plot)
		);

	drawsquare black(
		.clk(clk),
		.reset_n(resetn),
		.xpos(11'b10010100),
		.ypos(yposb[10:0]),
		.colourin(colourin[2:0]),
		.ld_enable(enableblack),
		.xout(xout),
		.yout(yout),
		.colourout(colourout[2:0]),
		.plot(plot)
		);
	assign plot = vga_out;


endmodule
*/
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

module clearscreen (
	 input clk,
	 input reset_n,
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
endmodule

module ball(clk, reset_n, outofbounds, xout, yout, colourout, plot);
	input clk;
	input reset_n;

	output outofbounds;
	output xout;
	output yout;
	output colourout;
	output plot;

  wire clock60hz;
	wire [8:0] xposout;
	wire [8:0] yyposout;
	wire dirx;
	wire diry;

drawsquare ball(
	.clk(clk),
	.reset_n(reset_n),
	.xpos(xposout),
	.ypos(yposout),
	.colourin(3'b111), // make white
	.ld_enable(outofbounds), // only move if the ball is not outofbounds
	.xout(xout),
	.yout(yout),
	.colourout(colourout),
	.plot(plot)
	);

ballpos ballpos(
	.clk(clock60hz),
	.reset(reset_n),
	.speed(1'b1),
	.dir_x(dirx),		// 0 = LEFT, 1 = RIGHT
	.dir_y(diry),		// 0 = UP, 1 = DOWN
	// output to drawsquare
	.value_x(xposout),
	.value_y(yposout)
	);

counterhz clock60hz(
	.enable(1'b1),
	.clk(clk),
	.reset_n(reset_n),
	.speed(3'b100), // 60hz
	.counterlimit(4'b0001), // only count up to 1
	.counterOut(clock60hz) // set the number of blocks
	);

endmodule
