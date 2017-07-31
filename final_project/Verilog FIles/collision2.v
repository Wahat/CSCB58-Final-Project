// Module with counters that determining the ball position
// Moves the ball according to the direction given and outputs the position
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
	input [4:0] speed;
	input reset;
	input dir_x, dir_y;
	output [10:0] value_x, value_y;

	reg [10:0] value_x, value_y;

	// the initial position of the ball is at the top of the screen, in the middle
	initial begin
		value_x <= 11'b0010;
		value_y <= 11'b110111;
	end

	always @ (posedge clk) begin
		if (reset) begin
			  value_x <= 11'b1100;
		    value_y <= 11'b110111;
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

// ballcollisions module
// Determines if the ball hits a block or the wall of the playing field
// Outputs the next direction of the ball given the position of the ball
module ballcollisions(
	clk,
	reset,
	ball_x,
	ball_y,
	dir_x,
	dir_y,
	oob,
	hit,
	// selected start direction from user
	dir_ystart,
	// input blocks
	bar1,
	bar2,
	bar3,
	bar4,
	);
	//dir_x,		// 0 = LEFT, 1 = RIGHT
	//dir_y,		// 0 = UP, 1 = DOWN
	// 1 if vertical
	// 0 if horz
	input clk, reset;
	input dir_ystart;
	input [10:0] ball_x, ball_y;
	input [15:0] bar1;
	input [15:0] bar2;
	input [15:0] bar3;
	input [15:0] bar4;
	// hit = 1 if it hits the target, 0 o/w
	// oob = 1 if it hits left wall,
	output dir_x, dir_y, hit, oob;
	reg dir_x, dir_y, hit, oob;

	initial begin
		dir_x <= 1; // Start right bc left is outofbounds
		dir_y <= dir_ystart; // Selected direction for y from user
		oob <= 0;
		hit <= 0;
	end

	always @ (posedge clk) begin
		if (reset) begin
			dir_x <= 1; // Start right bc left is outofbounds
			dir_y <= dir_ystart; // Selected direction for y from user
			oob <= 0;
			hit <= 0;
		end
		else if (!oob) begin
			// out of bounds (i.e. one of the players missed the ball)
			if (ball_x <= 1) begin
				oob <= 1;
			end

			// collision with top & bottom walls
			if (ball_y <= 3) begin
				dir_y = 1; // change direction to down
			end
			if (ball_y >= 115) begin
				dir_y = 0; // change direction to up
			end

			// collision with wall
			if (ball_x >= 114) begin
				dir_x = 0;	// reverse direction
			end

			// Block Collisions - Each Block is 30 x 2 px or 2 x 30px
			// Since Ball x and Y coord start at the top left of the ball and the ball is 4x4
			// We have to see if it collides of the x and y coord which is usually 3px away
			// from the tail of the ball

			// ###################### BLOCK1 ###################################
			// check if vertical block
			if (bar1[0] == 1'b1) begin

			  // check if it hit top of the block
				// Between 3px away on Y and 2px away from X to width 2 of block
			  if (((ball_y == (bar1[15:9] - 2'b11)) && (ball_x >= (bar1[8:1] - 2'b11))
			      && (ball_x <= (bar1[8:1] + 1'b1))))  begin

			    dir_y <= 0; // change the direction to up
			  end

			  // check if hit bottom
				// Collide with bottom Y value of block and 2px away from X to width 2 of block
			  if  ((ball_y == (bar1[15:9] + 5'b11111)) && (ball_x >= (bar1[8:1] - 2'b11))
			      && (ball_x <= (bar1[8:1] + 1'b1))) begin

			    dir_y <= 1; // change the direction to down
			  end

				// check if hit left
				// Between 3px away and length of the block on Y and 3px away on X
			  if ((ball_y >= (bar1[15:9] - 2'b11)) && (ball_y <= (bar1[15:9] + 5'b11111))
			     && (ball_x == (bar1[8:1] - 3'b100))) begin

			    dir_x <= 0; // change the direction to left
			  end

			  // check if hit right
				// Between 3px away and length of the block on Y and the right side of the block
			  if ((ball_y >= (bar1[15:9])) && (ball_y <= (bar1[15:9] + 5'b11111))
			     && (ball_x == (bar1[8:1] + 2'b10))) begin

			     dir_x <= 1; // change the direction to right
			  end
			end

			// ---------------------------------------------------------------------------
			// check if horz block
			if (bar1[0] == 1'b0) begin

			  // check if it hit top
				// 2px away from Y and between 3px away and length of the block on X
			  if (((ball_y == (bar1[15:9] - 3'b100)) && (ball_x >= (bar1[8:1] - 2'b11))
			     && (ball_x <= (bar1[8:1] + 5'b11111))))  begin

			    dir_y <= 0; // change the direction to up
			  end

			  // check if hit bottom
				// hit bottom side of block and between 3px away and length of the block on X
			  if  ((ball_y == (bar1[15:9] + 2'b10)) && (ball_x >= (bar1[8:1] - 2'b11))
			      && (ball_x <= (bar1[8:1] + 5'b11111))) begin

			    dir_y <= 1; // change the direction to down
			  end

			  // check if hit left
				// Between 3px away and length of the block on Y and 3px away on X
			  if ((ball_y >= (bar1[15:9] - 3'b100)) && (ball_y <= (bar1[15:9] + 1'b1))
			     && (ball_x == (bar1[8:1] - 2'b11))) begin

			     dir_x <= 0; // change the direction to left
			  end

			  // check if hit right
				// Between 3px away and length of the block on Y and 3px away on X
			  if ((ball_y >= (bar1[15:9])) && (ball_y <= (bar1[15:9] + 1'b1))
			     && (ball_x == (bar1[8:1] + 5'b11111))) begin

			    dir_x <= 1; // change the direction to right
			  end
			end


			// ###################### BLOCK2 ###################################
			// check if vertical block
			if (bar2[0] == 1'b1) begin

			  // check if it hit top of the block
				// Between 3px away on Y and 2px away from X to width 2 of block
			  if (((ball_y == (bar2[15:9] - 2'b11)) && (ball_x >= (bar2[8:1] - 2'b11))
			      && (ball_x <= (bar2[8:1] + 1'b1))))  begin

			    dir_y <= 0; // change the direction to up
			  end

			  // check if hit bottom
				// Collide with bottom Y value of block and 2px away from X to width 2 of block
			  if  ((ball_y == (bar2[15:9] + 5'b11111)) && (ball_x >= (bar2[8:1] - 2'b11))
			      && (ball_x <= (bar2[8:1] + 1'b1))) begin

			    dir_y <= 1; // change the direction to down
			  end

				// check if hit left
				// Between 3px away and length of the block on Y and 3px away on X
			  if ((ball_y >= (bar2[15:9] - 2'b11)) && (ball_y <= (bar2[15:9] + 5'b11111))
			     && (ball_x == (bar2[8:1] - 3'b100))) begin

			    dir_x <= 0; // change the direction to left
			  end

			  // check if hit right
				// Between 3px away and length of the block on Y and the right side of the block
			  if ((ball_y >= (bar2[15:9])) && (ball_y <= (bar2[15:9] + 5'b11111))
			     && (ball_x == (bar2[8:1] + 2'b10))) begin

			     dir_x <= 1; // change the direction to right
			  end
			end

			// ---------------------------------------------------------------------------
			// check if horz block
			if (bar2[0] == 1'b0) begin

			  // check if it hit top
				// 2px away from Y and between 3px away and length of the block on X
			  if (((ball_y == (bar2[15:9] - 3'b100)) && (ball_x >= (bar2[8:1] - 2'b11))
			     && (ball_x <= (bar2[8:1] + 5'b11111))))  begin

			    dir_y <= 0; // change the direction to up
			  end

			  // check if hit bottom
				// hit bottom side of block and between 3px away and length of the block on X
			  if  ((ball_y == (bar2[15:9] + 2'b10)) && (ball_x >= (bar2[8:1] - 2'b11))
			      && (ball_x <= (bar2[8:1] + 5'b11111))) begin

			    dir_y <= 1; // change the direction to down
			  end

			  // check if hit left
				// Between 3px away and length of the block on Y and 3px away on X
			  if ((ball_y >= (bar2[15:9] - 3'b100)) && (ball_y <= (bar2[15:9] + 1'b1))
			     && (ball_x == (bar2[8:1] - 2'b11))) begin

			     dir_x <= 0; // change the direction to left
			  end

			  // check if hit right
				// Between 3px away and length of the block on Y and 3px away on X
			  if ((ball_y >= (bar2[15:9])) && (ball_y <= (bar2[15:9] + 1'b1))
			     && (ball_x == (bar2[8:1] + 5'b11111))) begin

			    dir_x <= 1; // change the direction to right
			  end
			end

			// ###################### BLOCK3 ###################################
			// check if vertical block
			if (bar3[0] == 1'b1) begin

			  // check if it hit top of the block
				// Between 3px away on Y and 2px away from X to width 2 of block
			  if (((ball_y == (bar3[15:9] - 2'b11)) && (ball_x >= (bar3[8:1] - 2'b11))
			      && (ball_x <= (bar3[8:1] + 1'b1))))  begin

			    dir_y <= 0; // change the direction to up
			  end

			  // check if hit bottom
				// Collide with bottom Y value of block and 2px away from X to width 2 of block
			  if  ((ball_y == (bar3[15:9] + 5'b11111)) && (ball_x >= (bar3[8:1] - 2'b11))
			      && (ball_x <= (bar3[8:1] + 1'b1))) begin

			    dir_y <= 1; // change the direction to down
			  end

				// check if hit left
				// Between 3px away and length of the block on Y and 3px away on X
			  if ((ball_y >= (bar3[15:9] - 2'b11)) && (ball_y <= (bar3[15:9] + 5'b11111))
			     && (ball_x == (bar3[8:1] - 3'b100))) begin

			    dir_x <= 0; // change the direction to left
			  end

			  // check if hit right
				// Between 3px away and length of the block on Y and the right side of the block
			  if ((ball_y >= (bar3[15:9])) && (ball_y <= (bar3[15:9] + 5'b11111))
			     && (ball_x == (bar3[8:1] + 2'b10))) begin

			     dir_x <= 1; // change the direction to right
			  end
			end

			// ---------------------------------------------------------------------------
			// check if horz block
			if (bar3[0] == 1'b0) begin

			  // check if it hit top
				// 2px away from Y and between 3px away and length of the block on X
			  if (((ball_y == (bar3[15:9] - 3'b100)) && (ball_x >= (bar3[8:1] - 2'b11))
			     && (ball_x <= (bar3[8:1] + 5'b11111))))  begin

			    dir_y <= 0; // change the direction to up
			  end

			  // check if hit bottom
				// hit bottom side of block and between 3px away and length of the block on X
			  if  ((ball_y == (bar3[15:9] + 2'b10)) && (ball_x >= (bar3[8:1] - 2'b11))
			      && (ball_x <= (bar3[8:1] + 5'b11111))) begin

			    dir_y <= 1; // change the direction to down
			  end

			  // check if hit left
				// Between 3px away and length of the block on Y and 3px away on X
			  if ((ball_y >= (bar3[15:9] - 3'b100)) && (ball_y <= (bar3[15:9] + 1'b1))
			     && (ball_x == (bar3[8:1] - 2'b11))) begin

			     dir_x <= 0; // change the direction to left
			  end

			  // check if hit right
				// Between 3px away and length of the block on Y and 3px away on X
			  if ((ball_y >= (bar3[15:9])) && (ball_y <= (bar3[15:9] + 1'b1))
			     && (ball_x == (bar3[8:1] + 5'b11111))) begin

			    dir_x <= 1; // change the direction to right
			  end
			end

			// ###################### BLOCK4 ###################################
			// check if vertical block
			if (bar4[0] == 1'b1) begin

			  // check if it hit top of the block
				// Between 3px away on Y and 2px away from X to width 2 of block
			  if (((ball_y == (bar4[15:9] - 2'b11)) && (ball_x >= (bar4[8:1] - 2'b11))
			      && (ball_x <= (bar4[8:1] + 1'b1))))  begin

			    dir_y <= 0; // change the direction to up
			  end

			  // check if hit bottom
				// Collide with bottom Y value of block and 2px away from X to width 2 of block
			  if  ((ball_y == (bar4[15:9] + 5'b11111)) && (ball_x >= (bar4[8:1] - 2'b11))
			      && (ball_x <= (bar4[8:1] + 1'b1))) begin

			    dir_y <= 1; // change the direction to down
			  end

				// check if hit left
				// Between 3px away and length of the block on Y and 3px away on X
			  if ((ball_y >= (bar4[15:9] - 2'b11)) && (ball_y <= (bar4[15:9] + 5'b11111))
			     && (ball_x == (bar4[8:1] - 3'b100))) begin

			    dir_x <= 0; // change the direction to left
			  end

			  // check if hit right
				// Between 3px away and length of the block on Y and the right side of the block
			  if ((ball_y >= (bar4[15:9])) && (ball_y <= (bar4[15:9] + 5'b11111))
			     && (ball_x == (bar4[8:1] + 2'b10))) begin

			     dir_x <= 1; // change the direction to right
			  end
			end

			// ---------------------------------------------------------------------------
			// check if horz block
			if (bar4[0] == 1'b0) begin

			  // check if it hit top
				// 2px away from Y and between 3px away and length of the block on X
			  if (((ball_y == (bar4[15:9] - 3'b100)) && (ball_x >= (bar4[8:1] - 2'b11))
			     && (ball_x <= (bar4[8:1] + 5'b11111))))  begin

			    dir_y <= 0; // change the direction to up
			  end

			  // check if hit bottom
				// hit bottom side of block and between 3px away and length of the block on X
			  if  ((ball_y == (bar4[15:9] + 2'b10)) && (ball_x >= (bar4[8:1] - 2'b11))
			      && (ball_x <= (bar4[8:1] + 5'b11111))) begin

			    dir_y <= 1; // change the direction to down
			  end

			  // check if hit left
				// Between 3px away and length of the block on Y and 3px away on X
			  if ((ball_y >= (bar4[15:9] - 3'b100)) && (ball_y <= (bar4[15:9] + 1'b1))
			     && (ball_x == (bar4[8:1] - 2'b11))) begin

			     dir_x <= 0; // change the direction to left
			  end

			  // check if hit right
				// Between 3px away and length of the block on Y and 3px away on X
			  if ((ball_y >= (bar4[15:9])) && (ball_y <= (bar4[15:9] + 1'b1))
			     && (ball_x == (bar4[8:1] + 5'b11111))) begin

			    dir_x <= 1; // change the direction to right
			  end
			end

		// check if ball hit target
		// Target is between 55px and 65px on the right edge on the playing board
		if ((ball_x == 10'b1110011) && (ball_y <= 10'b1000010) && (ball_y >= 10'b110111)) begin
			hit <= 1'b1;
		end // ends if !oob block
	end  // end else if
end // end always block
endmodule
