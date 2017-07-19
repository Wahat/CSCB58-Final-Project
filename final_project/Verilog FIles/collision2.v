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
		value_x <= 11'b10;
		value_y <= 11'b1110100;
	end

	always @ (posedge clk) begin
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
	//dir_x,		// 0 = LEFT, 1 = RIGHT
	//dir_y,		// 0 = UP, 1 = DOWN
	input clk, reset, mode;
	input [10:0] ball_x, ball_y;
	output dir_x, dir_y, hit, oob;

	reg dir_x, dir_y, hit, oob;
	initial begin
		dir_x <= 1;
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
		else if (!oob) begin
			// out of bounds (i.e. one of the players missed the ball)
			if (ball_x <= 1) begin
				oob <= 1;
			end
			else begin
				oob <= 0;
				hit <= 0;
			end

			// collision with top & bottom walls
			if (ball_y <= 3) begin
				dir_y <= 1;
			end
			if (ball_y >= 116) begin
				dir_y <= 0;
			end

			// collision with wall
			if (ball_x >= 115) begin

				dir_x <= 0;	// reverse direction
				hit <= 1;

			end
		end
	end

endmodule
