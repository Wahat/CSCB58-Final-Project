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
/*
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
*/

endmodule

// Module with counters that determining the ball position
module ballpos(
	clk,
	reset,
	speed,
	dir_x,		// 0 = LEFT, 1 = RIGHT
	dir_y,		// 0 = UP, 1 = DOWN
	value_x,
	value_y,
	);

	input clk;
	input [4:0] speed;					// # of px to increment bat by
	input reset;
	input dir_x, dir_y;
	output [10:0] value_x, value_y;		// max value is 1024 (px), 11 bits wide

	reg [10:0] value_x, value_y;

	// the initial position of the ball is at the top of the screen, in the middle,
	initial begin
		value_x <= 11'b1010;
		value_y <= 11'b1010000;
	end

	always @ (posedge clk or posedge reset) begin
		if (!reset) begin
			value_x <= 11'b1010;
		   value_y <= 11'b1010000;
		end
		else begin
			// increment x
			if (dir_x) begin
				// right
				value_x <= value_x + speed;
			end
			else begin
				// left
				value_x <= value_x - speed;
			end

			// increment y
			if (dir_y) begin
				// down
				value_y <= value_y + speed;
			end
			else begin
				// up
				value_y <= value_y - speed;
			end
		end
	end

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

module ballcollisions(
	clk,
	reset,
	ball_x,
	ball_y,
	dir_x,
	dir_y,
	oob,	// whether ball is out of bounds
	hit,
	mode
	);

	input clk, reset, mode;
	input [10:0] ball_x, ball_y;
	output dir_x, dir_y, hit, oob;

	reg dir_x, dir_y, hit, oob;
	initial begin
		dir_x <= 0;
		dir_y <= 1;
		oob <= 0;
		hit <= 0;
	end

	always @ (posedge clk) begin
		if (!reset) begin
			dir_x <= 0;
			dir_y <= 1;
			oob <= 0;
			hit <= 0;
		end
		else begin
			// out of bounds (i.e. one of the players missed the ball)
			if (ball_x <= 0) begin
				oob <= 1;
			end
			else begin
				oob <= 0;
				hit <= 0;
			end

			// collision with top & bottom walls
			if (ball_y <= 16) begin
				dir_y <= 1;
			end
			if (ball_y >= 104) begin
				dir_y <= 0;
			end

			// collision with wall
			if (ball_x >= 120) begin

				dir_x <= 1;	// reverse direction
				hit <= 1;

			end
		end
	end

endmodule
