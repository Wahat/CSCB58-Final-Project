// graphics module
// controls and outputs the graphics to the vga adapter depending on the state
module graphics(clk, select, reset_n, ps2_key_data, ps2_key_pressed, blockselected,
	 							setblock, block1, block2, block3, block4, state, oob, hit, xout, yout, colourout,
								plot, blockout, resetps2);
	input clk;
	input reset_n;
	// input the state from datapath
	input [3:0] state;
	// The controls from the switches
	// Used to select the direction of the ball or the type of block the user wants
	input select;
	// PS2 controls input
	input [7:0] ps2_key_data;
	input ps2_key_pressed;
	// Block currently selected
	input blockselected;
	// Registers for the blocks
	input setblock;
	input [15:0] block1;
	input [15:0] block2;
	input [15:0] block3;
	input [15:0] block4;
	// outputs if the ball hits the target or goes out of bounds
	output hit;
	output oob;
	// Output x, y, colour and plot back into datapath
	output reg [11:0] xout;
	output reg [10:0] yout;
	output reg [2:0] colourout;
	output reg plot;
	// outputs the x and y values of the block
	output [15:0] blockout;
	// sends a value to tell the PS2 module if it needs to be reset
	output reg resetps2;

	// VGA outputs
	// wires for red state sqaure
	wire statesqplot;
	wire [10:0] statexout;
	wire [10:0] stateyout;
	wire [2:0] statecolourout;
	// wires for black erase square output
	wire bsquareplot;
	wire [10:0] bsxout;
	wire [10:0] bsyout;
	wire [2:0] bscolourout;

	// wires for block output
	wire blplot;
	wire [10:0] blxout;
	wire [10:0] blyout;
	wire [2:0] blcolourout;
	wire [15:1] bblockout;

	// wires for the ball output
	wire [10:0] bxout;
	wire [10:0] byout;
	wire [2:0] bcolourout;
	wire ballplot;

	// enable registers
	reg balldraw = 1'b0;
	reg resetball = 1'b0;
	reg drawblock = 1'b0;
	reg resetblock = 1'b0;
	reg [7:0] ps2_data;

	// registers for the red and black square positions
	reg [10:0] stateypos;
	reg [10:0] bypos;
	// register for the colour
	reg [2:0] colourin;

	always @ (posedge clk) begin
		// default set registers to 0
		balldraw <= 1'b0;
		drawblock <= 1'b0;

		case (state[3:0])
			4'b0000: begin // begin state
				// hightlight Select on the screen
				colourin <= 3'b100;
				stateypos <= 11'b10010;
				xout[10:0] <= statexout[10:0];
				yout[10:0] <= stateyout[10:0];
				colourout[2:0] <= statecolourout[2:0];
				resetblock = 1'b1;
			end

			4'b0001: begin //begin erase state
				// Erase Select highlight on the screen
				colourin <= 3'b000;
				xout[10:0] <= statexout[10:0];
				yout[10:0] <= stateyout[10:0];
				colourout[2:0] <= statecolourout[2:0];
			end

			4'b0010: begin // load block state
				// Hightlight Choose on the screen
				stateypos <= 11'b100111;
				colourin <= 3'b100;
				xout[10:0] <= statexout[10:0];
				yout[10:0] <= stateyout[10:0];
				colourout[2:0] <= statecolourout[2:0];

				// reset ps2 and the drawblock modules
				resetblock = 1'b1;

			end

			4'b0011: begin // erase bload block state
			// Erase Choose on the screen
				colourin <= 3'b000;
				xout[10:0] <= statexout[10:0];
				yout[10:0] <= stateyout[10:0];
				colourout[2:0] <= statecolourout[2:0];
			end

			4'b0100: begin // load set state
			// Hightlight Set on the screen
				resetps2 = 1'b1;
				stateypos[10:0] <= 11'b111010;
				xout[10:0] <= statexout[10:0];
				yout[10:0] <= stateyout[10:0];
				colourout[2:0] <= statecolourout[2:0];
				colourin <= 3'b100;
				resetblock = 1'b1;
				drawblock <= 1'b1;
			end

			4'b0101: begin // draw block state
				// Turn off reset on blocks
				resetblock = 1'b0;
				resetps2 = 1'b0;
				drawblock <= 1'b1;
				xout[10:0] <= blxout[10:0];
				yout[10:0] <= blyout[10:0];
				colourout[2:0] <= blcolourout[2:0];
			end

			4'b0110: begin // load set erase
				colourin <= 3'b000;
				xout[10:0] <= statexout[10:0];
				yout[10:0] <= stateyout[10:0];
				colourout[2:0] <= statecolourout[2:0];
			end

			4'b0111: begin // start game load
				colourin <= 3'b100;
			  stateypos[10:0] <= 11'b1001100;
				xout[10:0] <= statexout[10:0];
	 			yout[10:0] <= stateyout[10:0];
	 			colourout[2:0] <= statecolourout[2:0];
			end

			4'b1000: begin // start game
				balldraw <= 1'b1;
				resetball = 1'b0;
				xout[10:0] <= bxout[10:0];
				yout[10:0] <= byout[10:0];
				colourout[2:0] <= bcolourout[2:0];
				plot <= ballplot;
			end

			4'b1001: begin // start game erase
				colourin <= 3'b000;
				xout[10:0] <= statexout[10:0];
				yout[10:0] <= stateyout[10:0];
				colourout[2:0] <= statecolourout[2:0];
			end

			4'b1010: begin // endgame
				colourin <= 3'b100;
				stateypos[10:0] <= 11'b1011110;
				xout[10:0] <= statexout[10:0];
				yout[10:0] <= stateyout[10:0];
				colourout[2:0] <= statecolourout[2:0];
			end

			4'b1011: begin // endgame erase
				colourin <= 3'b000;
				xout[10:0] <= statexout[10:0];
				yout[10:0] <= stateyout[10:0];
				colourout[2:0] <= statecolourout[2:0];
			end

			4'b1100: begin // erase set after transistioning
				colourin <= 3'b000;
				xout[10:0] <= statexout[10:0];
				yout[10:0] <= stateyout[10:0];
				colourout[2:0] <= statecolourout[2:0];
				resetball = 1'b1;
			end

		endcase
	end

	// instance of the drawsquare module
	// hightlights the state on the screen
	drawsquare statesquare(
		.clk(clk),
		.reset_n(!reset_n),
		.xpos(10'b1111011),
		.ypos(stateypos),
		.colourin(colourin),
		.ld_enable(1'b1),
		.xout(statexout),
		.yout(stateyout),
		.colourout(statecolourout),
		.plot(statesqplot)
		);

	// instance of the drawblock module
	drawblock block (
		.clk(clk & drawblock),
		.reset_n(!reset_n || resetblock),
		.enable(1'b1),
		.blocktype(blockselected),
		.setblock(setblock),
		.ps2_key_data(ps2_key_data),
		.ps2_key_pressed(ps2_key_pressed),
		.xout(blxout),
		.yout(blyout),
		.colourout(blcolourout),
		.plot(blplot),
		.blockout(blockout)
		);

	// instance of the drawball module
	drawball whiteball(
		.clk(clk & balldraw),
		.reset_n(!reset_n || resetball),
		.enable(balldraw),
		.select(select),
		.hit(hit),
		.outofbounds(oob),
		.block1(block1),
		.block2(block2),
		.block3(block3),
		.block4(block4),
		.xout(bxout),
		.yout(byout),
		.colourout(bcolourout),
		.plot(ballplot)
		);
endmodule

// ##########################################################################
// drawball module
// Uses drawsquare, ballposition, ball collison and counter modules
// Draws and moves the ball depending on the position
module drawball (clk, reset_n, select, enable, block1, block2, block3, block4,
								hit, outofbounds, xout, yout, colourout, plot);
	input clk;
	input reset_n;
	input select;
	input enable;
	input [15:0] block1;
	input [15:0] block2;
	input [15:0] block3;
	input [15:0] block4;

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

	wire clk240;
	wire clk120;

	reg [3:0] current_state, next_state;
	reg [27:0] count;
	reg [11:0] xpos;
	reg [10:0] ypos;
	reg [3:0] colour;
	reg clkenable;

	localparam  INIT      = 3'd0,
							START     = 3'd1,
							DRAWBALL  = 3'd2,
							WAIT1     = 3'd3,
							ERASEBALL = 3'd4,
							CHECK     = 3'd5;

	always @ (posedge clk & enable & !outofbounds & !hit) begin
		case(current_state)
			INIT: begin // Intialize state
				xpos <= 11'b0010;
				ypos <= 11'b110111;
				count = 27'b0;
				next_state = DRAWBALL;
				colour = 3'b000;
			end
			DRAWBALL: begin // Draws the white ball
				clkenable = 1'b0;
				if (count < 6'b100000) begin
					 count = count + 1'b1;
					 colour = 3'b111;
				end
				else begin
					count = 27'b0;
					next_state = WAIT1;
					end
			end
			WAIT1: begin // Give time for the white ball to stay on the screen
				next_state = clock60hz ? ERASEBALL : WAIT1;
			end
			ERASEBALL: begin // Draws a black ball on top of the white ball
				if (count < 6'b100000) begin
					 count = count + 1'b1;
					 colour = 3'b000;
				end
				else begin
					count = 27'b0;
					next_state = CHECK;
				end
			end
			CHECK: begin // Enable the clocks and sends the next x and y value to the registers
			if (count < 28'b11001011011100110100) begin
					count = count + 1'b1;
			end
			else begin
				count <= 28'b0;
				clkenable = 1'b1;
				xpos = xposout;
				ypos = yposout;
				next_state = DRAWBALL;
			end
			end
		endcase
		end

		always @ (posedge clk) begin
				if(reset_n)
						current_state <= INIT;
				else
						current_state <= next_state;
				end // state_FFS

	counterhz clock_60hz(
		.enable(1'b1),
		.clk(clk),
		.reset_n(1'b0),
		.speed(3'b100), // 60hz
		.counterlimit(4'b0001), // only count up to 1
		.counterOut(clock60hz) // set the number of blocks
		);

  // draw a 4x4 square ball
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

	// Ball position module to determine the position of the ball
	ballpos ballpos(
		.clk(clk & clkenable),
		.reset(reset_n),
		.speed(3'b001),
		.dir_x(dirx),		// 0 = LEFT, 1 = RIGHT
		.dir_y(diry),		// 0 = UP, 1 = DOWN
		// output to drawsquare
		.value_x(xposout),
		.value_y(yposout)
		);

	// Ball collision module to determine direction (up down left right)
	ballcollisions collide(
		.clk(clk & clkenable),
		.reset(reset_n),
		.ball_x(xposout),
		.ball_y(yposout),
		.dir_x(dirx),
		.dir_y(diry),
		.oob(outofbounds),	// whether ball is out of bounds
		.hit(hit),
		.dir_ystart(select),
		.bar1(block1),
		.bar2(block2),
		.bar3(block3),
		.bar4(block4)
		);

	counterhz count120hz(
		.enable(1'b1),
		.reset_n(1'b0),
		.clk(clk),
		.speed(3'b111),
		.counterlimit(4'b001),
		.counterOut(clk120)
		);

	counterhz count240hz(
		.enable(1'b1),
		.reset_n(1'b0),
		.clk(clk),
		.speed(3'b110),
		.counterlimit(4'b001),
		.counterOut(clk240)
		);

endmodule

// ##########################################################################
// drawblock module
// Uses draw vblock, hblock, PS2 Keyboard and counter modules
// Draws a vertical or horizontal block (depending on input)
// Uses PS2 Keyboard to move the blocks up or down
// outputs the block data so it can be used in collision
module drawblock (clk, blocktype, reset_n, enable, ps2_key_data, ps2_key_pressed, block,
									 setblock, xout, yout, colourout, plot, blockout);
	input clk;
	input blocktype;
	input reset_n;
	input enable;
	input ps2_key_pressed;
	input [7:0] ps2_key_data;
	input [15:0] block;
	input setblock;

	output reg [11:0] xout;
	output reg [11:0] yout;
	output reg [3:0] colourout;
	output reg plot;
	output reg [15:0] blockout;

	wire clock60hz;
	wire clk240;
	wire clock120;
	reg [3:0] colour;

	// wires for the vertical block output
	wire vblplot;
	wire [10:0] vblxout;
	wire [10:0] vblyout;
	wire [2:0]  vblcolourout;
	wire [15:1] vblockout;

	// wires for the horizontal block output
	wire hblplot;
	wire [10:0] hblxout;
	wire [10:0] hblyout;
	wire [2:0] hblcolourout;
	wire [15:1] hblockout;

	// Registers for states
	reg [3:0] current_state, next_state;
	reg [27:0] count;

	localparam  INIT       = 3'd0,
							DRAWBLOCK  = 3'd2,
							WAIT1      = 3'd3,
							ERASEBLOCK = 3'd4,
							CHECK      = 3'd5,
							END        = 3'd6;

	always @(posedge clk) begin
		case(current_state)
				INIT: begin
					blockout[15:9] = 7'b00111;
					blockout[8:1]  = 7'b001000;
					count = 28'b0;
					next_state = DRAWBLOCK;
					colour = 3'b100;
				end
				DRAWBLOCK: begin
					if (count < 15'b100000000000000) begin
						 count = count + 1'b1;
						 colour = 3'b100;
					end
					else begin
						count = 28'b0;
						next_state = WAIT1;
					end
				end
				WAIT1: begin
						next_state = clock60hz ? ERASEBLOCK : WAIT1;
				end
				ERASEBLOCK: begin
					if (count < 15'b100000000000000) begin
						 count = count + 1'b1;
						 colour = 3'b000;
					end
					else begin
						count = 27'b0;
						next_state = CHECK;
					end
				end
				CHECK: begin
						if (count <= 28'b11001011011100110100) begin
								count = count + 1'b1;
						end
						else begin
							if (blocktype == 1'b1) begin
								if (ps2_key_data == 8'h6b & ((blockout[8:1] - 1'b1) > 7'b111)) begin
									blockout[8:1] = blockout[8:1] - 1'b1;
								end
								if (ps2_key_data == 8'h74 & ((blockout[8:1] + 1'b1) < 7'b1110100)) begin
									blockout[8:1] = blockout[8:1] + 1'b1;
								end
								if (ps2_key_data == 8'h75 & ((blockout[15:9] - 1'b1) > 7'b11)) begin
									blockout[15:9] = blockout[15:9] - 1'b1;
								end
								if (ps2_key_data == 8'h72 & ((blockout[15:9] + 1'b1) < 7'b1110100 - 5'b11111)) begin
									blockout[15:9] = blockout[15:9] + 1'b1 ;
									// correct for h
								end
							end
							else begin
								if (ps2_key_data == 8'h6b & ((blockout[8:1] - 1'b1) > 7'b111)) begin
									blockout[8:1] = blockout[8:1] - 1'b1;
									// incorrect for v
								end
								if (ps2_key_data == 8'h74 & ((blockout[8:1] + 1'b1) < 7'b1110100 - 5'b11111)) begin
									blockout[8:1] = blockout[8:1] + 1'b1;
									// correct for v
								end
								if (ps2_key_data == 8'h75 & ((blockout[15:9] - 1'b1) > 7'b11)) begin
									blockout[15:9] = blockout[15:9] - 1'b1;
									// in correct for v
								end
								if (ps2_key_data == 8'h72 & ((blockout[15:9] + 1'b1) < 7'b1110100)) begin
									blockout[15:9] = blockout[15:9] + 1'b1;
									// correct for h
								end
							end
							if (ps2_key_data == 8'h29) begin
								next_state = END;
							end
							else begin
								next_state = DRAWBLOCK;
							end
							 count = 28'b0;
						end

				end
				END: begin
						colour = 3'b101;
				end
		endcase
	end

	always @ (posedge clk) begin
			if(reset_n)
					current_state <= INIT;
			else
					current_state <= next_state;
			end // state_FFS

	always @ (posedge clk) begin
			// if the selected block is 0 then set the VGA outputs to the
			// vertical block
			if (blocktype == 1'b1) begin
					xout[10:0] = vblxout[10:0];
					yout[10:0] = vblyout[10:0];
					colourout[2:0] = vblcolourout[2:0];
			end
			// if the selected block is 0 then set the VGA outputs to the
			// horizontal block
			else begin
				xout[10:0] = hblxout[10:0];
				yout[10:0] = hblyout[10:0];
				colourout[2:0] = hblcolourout[2:0];
			end
		end

	 counterhz count240hz(
		.enable(1'b1),
		.clk(clk),
		.reset_n(1'b0),
		.speed(3'b110),
		.counterlimit(4'b001),
		.counterOut(clk240)
		);

  // horizontal block
	hblock hblock(
	 .clk(clk),
	 .reset_n(reset_n),
	 .xpos(blockout[8:1]),
	 .ypos(blockout[15:9]),
	 .colourin(colour),
	 .ld_enable(1'b1),
	 .xout(hblxout),
	 .yout(hblyout),
	 .colourout(hblcolourout),
	 .plot(hblplot)
	 );

	// vertical block
  vblock vblock(
	 .clk(clk),
	 .reset_n(reset_n),
	 .xpos(blockout[8:1]),
	 .ypos(blockout[15:9]),
	 .colourin(colour),
	 .ld_enable(1'b1),
	 .xout(vblxout),
	 .yout(vblyout),
	 .colourout(vblcolourout),
	 .plot(vblplot)
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

// ##########################################################################
// hblock module
// draws a 10x2 px horizontal block
module hblock (
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
	 reg [5:0] counter = 5'b000;
	 reg vga_out = 1'b0;

	 always @ (posedge clk) begin
			 if(reset_n) begin
				 x_in <= 11'b0;
				 y_in <= 10'b0;
				 vga_out <= 1'b0;
				 counter <= 3'b000;
			 end
			 else begin
				 x_in[11:0] <= {1'b0, xpos[10:0]};
				 y_in[10:0] <= ypos[10:0];
				 if(vga_out) begin
						 counter <= counter + 1'b1;
						 if (counter == 5'b10000) begin
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

// ##########################################################################
// vblock module
// draws a 2x10 px vertical block
module vblock (
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
	 reg [14:0] counter = 4'b000;
	 reg vga_out = 1'b0;

	 always@(posedge clk) begin
			 if(reset_n) begin
					 x_in <= 11'b0;
					 y_in <= 10'b0;
					 vga_out <= 1'b0;
					 counter <= 3'b000;
			 end
			 else begin
						 x_in[11:0] <= {1'b0, xpos[10:0]};
						 y_in[10:0] <= ypos[10:0];
					 if(vga_out) begin
							 counter <= counter + 1'b1;
							 if (counter == 5'b10000) begin
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

// ##########################################################################
// drawsquare module
// draws a 4x4 px square
module drawsquare (
	 input clk,
	 input reset_n,
	 input [10:0] xpos,
	 input [10:0] ypos,
	 input [2:0] colourin,
   input ld_enable,
	 // outputs for the VGA adapter
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
			 if(reset_n) begin
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

// ##########################################################################
// clearscreen module
// Clears the 120 x 120 playing field
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
	 reg [7:0] counter = 7'b000;
	 reg vga_out = 1'b0;

	 always @ (posedge clk) begin
			 if(!reset_n) begin
					 x_in <= 11'b0;
					 y_in <= 10'b0;
					 vga_out <= 1'b0;
					 counter <= 7'b000;
					 colourout <= 1'b0;
			 end
			 else begin
		 			 colourout <= 1'b0;
					 x_in[11:0] <= 11'b01;
					 y_in[10:0] <= 11'b100;
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
