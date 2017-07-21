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

	dir_xstart,
	dir_ystart,

	bar1;
	bar2;
	bar3;
	bar4;
	);
	//dir_x,		// 0 = LEFT, 1 = RIGHT
	//dir_y,		// 0 = UP, 1 = DOWN
	input clk, reset, mode;
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
		dir_x <= 1;
		dir_y <= 1;
		oob <= 0;
		hit <= 0;
	end

	always @ (posedge clk) begin
		if (!reset) begin
			dir_x <= dir_xstart;
			dir_y <= dir_ystart;
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



			// check if vertical bar
			if (bar1[0] == 1'b1) begin

				// check if it hit top
				if (((ball_y == (bar1[15:9] - 2'b10)) && (ball_x >= (bar1[8:1] - 1'b1)) && (ball_x <= (bar1[8:1] + 1'b1)))  begin
					dir_y <= 0;
				end

				// check if hit bottom
				if  ((ball_y == (bar1[15:9] + 4'b1010)) && (ball_x >= (bar1[8:1] - 1'b1)) && (ball_x <= (bar1[8:1] + 1'b1))) begin
					dir_y <= 1;
				end

				// check if hit left
				if ((ball_y >= (bar1[15:9] - 1'b1)) && (ball_y <= (bar1[15:9] + 4'b1001)) && (ball_x == (bar1[8:1] + 2'b10))) begin
					 dir_x = 0;
				end

				// check if hit right
			  if ((ball_y >= (bar1[15:9] - 1'b1)) && (ball_y <= (bar1[15:9] + 4'b1001)) && (ball_x == (bar1[8:1] - 2'b10))) begin
					dir_x <= 1;
				end
		  end

		// check if horz block
		if (bar1[0] == 1'b1) begin

			// check if it hit top
			if (((ball_y == (bar1[15:9] - 2'b10)) && (ball_x >= (bar1[8:1] - 1'b1)) && (ball_x <= (bar1[8:1] + 4'b1001)))  begin
				dir_y <= 0;
			end

			// check if hit bottom
			if  ((ball_y == (bar1[15:9] + 2'b10)) && (ball_x >= (bar1[8:1] - 1'b1)) && (ball_x <= (bar1[8:1] + 4'b1001))) begin
				dir_y <= 1;
			end

			// check if hit left
			if ((ball_y >= (bar1[15:9] - 1'b1)) && (ball_y <= (bar1[15:9] + 1'b1001)) && (ball_x == (bar1[8:1] - 2'b10))) begin
				 dir_x = 0;
			end

			// check if hit right
			if ((ball_y >= (bar1[15:9] - 1'b1)) && (ball_y <= (bar1[15:9] + 1'b1001)) && (ball_x == (bar1[8:1] + 4'b1010))) begin
				dir_x <= 1;
			end
		end


					// check if vertical bar
					if (bar2[0] == 1'b1) begin

						// check if it hit top
						if (((ball_y == (bar2[15:9] - 2'b10)) && (ball_x >= (bar2[8:1] - 1'b1)) && (ball_x <= (bar2[8:1] + 1'b1)))  begin
							dir_y <= 0;
						end

						// check if hit bottom
						if  ((ball_y == (bar2[15:9] + 4'b1010)) && (ball_x >= (bar2[8:1] - 1'b1)) && (ball_x <= (bar2[8:1] + 1'b1))) begin
							dir_y <= 1;
						end

						// check if hit left
						if ((ball_y >= (bar2[15:9] - 1'b1)) && (ball_y <= (bar2[15:9] + 4'b1001)) && (ball_x == (bar2[8:1] + 2'b10))) begin
							 dir_x = 0;
						end

						// check if hit right
					  if ((ball_y >= (bar2[15:9] - 1'b1)) && (ball_y <= (bar2[15:9] + 4'b1001)) && (ball_x == (bar2[8:1] - 2'b10))) begin
							dir_x <= 1;
						end
				  end

				// check if horz block
				if (bar2[0] == 1'b1) begin

					// check if it hit top
					if (((ball_y == (bar2[15:9] - 2'b10)) && (ball_x >= (bar2[8:1] - 1'b1)) && (ball_x <= (bar2[8:1] + 4'b1001)))  begin
						dir_y <= 0;
					end

					// check if hit bottom
					if  ((ball_y == (bar2[15:9] + 2'b10)) && (ball_x >= (bar2[8:1] - 1'b1)) && (ball_x <= (bar2[8:1] + 4'b1001))) begin
						dir_y <= 1;
					end

					// check if hit left
					if ((ball_y >= (bar2[15:9] - 1'b1)) && (ball_y <= (bar2[15:9] + 1'b1001)) && (ball_x == (bar2[8:1] - 2'b10))) begin
						 dir_x = 0;
					end

					// check if hit right
					if ((ball_y >= (bar2[15:9] - 1'b1)) && (ball_y <= (bar2[15:9] + 1'b1001)) && (ball_x == (bar2[8:1] + 4'b1010))) begin
						dir_x <= 1;
					end
				end

							// check if vertical bar
							if (bar3[0] == 1'b1) begin

								// check if it hit top
								if (((ball_y == (bar3[15:9] - 2'b10)) && (ball_x >= (bar3[8:1] - 1'b1)) && (ball_x <= (bar3[8:1] + 1'b1)))  begin
									dir_y <= 0;
								end

								// check if hit bottom
								if  ((ball_y == (bar3[15:9] + 4'b1010)) && (ball_x >= (bar3[8:1] - 1'b1)) && (ball_x <= (bar3[8:1] + 1'b1))) begin
									dir_y <= 1;
								end

								// check if hit left
								if ((ball_y >= (bar3[15:9] - 1'b1)) && (ball_y <= (bar3[15:9] + 4'b1001)) && (ball_x == (bar3[8:1] + 2'b10))) begin
									 dir_x = 0;
								end

								// check if hit right
							  if ((ball_y >= (bar3[15:9] - 1'b1)) && (ball_y <= (bar3[15:9] + 4'b1001)) && (ball_x == (bar3[8:1] - 2'b10))) begin
									dir_x <= 1;
								end
						  end

						// check if horz block
						if (bar3[0] == 1'b1) begin

							// check if it hit top
							if (((ball_y == (bar3[15:9] - 2'b10)) && (ball_x >= (bar3[8:1] - 1'b1)) && (ball_x <= (bar3[8:1] + 4'b1001)))  begin
								dir_y <= 0;
							end

							// check if hit bottom
							if  ((ball_y == (bar3[15:9] + 2'b10)) && (ball_x >= (bar3[8:1] - 1'b1)) && (ball_x <= (bar3[8:1] + 4'b1001))) begin
								dir_y <= 1;
							end

							// check if hit left
							if ((ball_y >= (bar3[15:9] - 1'b1)) && (ball_y <= (bar3[15:9] + 1'b1001)) && (ball_x == (bar3[8:1] - 2'b10))) begin
								 dir_x = 0;
							end

							// check if hit right
							if ((ball_y >= (bar3[15:9] - 1'b1)) && (ball_y <= (bar3[15:9] + 1'b1001)) && (ball_x == (bar3[8:1] + 4'b1010))) begin
								dir_x <= 1;
							end
						end

									// check if vertical bar
									if (bar4[0] == 1'b1) begin

										// check if it hit top
										if (((ball_y == (bar4[15:9] - 2'b10)) && (ball_x >= (bar4[8:1] - 1'b1)) && (ball_x <= (bar4[8:1] + 1'b1)))  begin
											dir_y <= 0;
										end

										// check if hit bottom
										if  ((ball_y == (bar4[15:9] + 4'b1010)) && (ball_x >= (bar4[8:1] - 1'b1)) && (ball_x <= (bar4[8:1] + 1'b1))) begin
											dir_y <= 1;
										end

										// check if hit left
										if ((ball_y >= (bar4[15:9] - 1'b1)) && (ball_y <= (bar4[15:9] + 4'b1001)) && (ball_x == (bar4[8:1] + 2'b10))) begin
											 dir_x = 0;
										end

										// check if hit right
									  if ((ball_y >= (bar4[15:9] - 1'b1)) && (ball_y <= (bar4[15:9] + 4'b1001)) && (ball_x == (bar4[8:1] - 2'b10))) begin
											dir_x <= 1;
										end
								  end

								// check if horz block
								if (bar4[0] == 1'b1) begin

									// check if it hit top
									if (((ball_y == (bar4[15:9] - 2'b10)) && (ball_x >= (bar4[8:1] - 1'b1)) && (ball_x <= (bar4[8:1] + 4'b1001)))  begin
										dir_y <= 0;
									end

									// check if hit bottom
									if  ((ball_y == (bar4[15:9] + 2'b10)) && (ball_x >= (bar4[8:1] - 1'b1)) && (ball_x <= (bar4[8:1] + 4'b1001))) begin
										dir_y <= 1;
									end

									// check if hit left
									if ((ball_y >= (bar4[15:9] - 1'b1)) && (ball_y <= (bar4[15:9] + 1'b1001)) && (ball_x == (bar4[8:1] - 2'b10))) begin
										 dir_x = 0;
									end

									// check if hit right
									if ((ball_y >= (bar4[15:9] - 1'b1)) && (ball_y <= (bar4[15:9] + 1'b1001)) && (ball_x == (bar4[8:1] + 4'b1010))) begin
										dir_x <= 1;
									end
								end

		// check if ball hit target
		if ((ball_x == 3'd120) && (ball_y <= 3'd65) && (ball_y >= 3'd55)) begin
			hit = 1'b1;
		end // ends if !oob block
	end  // ends always block

endmodule
