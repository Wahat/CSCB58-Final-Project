// Top level Entity - main project module
module projectVGA
	(CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
    KEY,
    SW,
		HEX0,
		HEX2,
		HEX5,
		LEDR,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   					//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,				//	VGA BLANK
		VGA_SYNC_N,					//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);
	input		CLOCK_50;			//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	input   [6:0]   HEX0;
	input   [6:0]   HEX2;
	input   [6:0]   HEX5;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			   VGA_CLK;   			//	VGA Clock
	output			   VGA_HS;					//	VGA H_SYNC
	output			   VGA_VS;					//	VGA V_SYNC DE2 Blackjack
	output			   VGA_BLANK_N;	  //	VGA BLANK
	output			   VGA_SYNC_N;			//	VGA SYNC
	output	[9:0]	 VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	 VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	 VGA_B;   				//	VGA Blue[9:0]

	wire resetn;
	assign resetn = KEY[0];

	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire controlA, controlB, controlC;
	wire [3:0] winout;
	wire [3:0] loseout;
	wire [3:0] numBlocks;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.

	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

  // Instansiate datapath
	datapath d0(
		// input switches
		.clk(CLOCK_50),
		.reset_n(resetn),
		.pos(SW[6:0]),
		// input registers from FSM
		.ld_start(controlA),
		.ld_block(controlB),
		.ld_set(controlC),
		.ld_setgame(writeEn),
		// output registers to VGA
		.xout(x),
		.yout(y),
		.colourout(colour),
		// output to HEX displays
		.wins(winout),
		.losses(loseout),
		.startingBlocks(numBlocks)
		);

  // Instansiate FSM control
	// KEY[0] - reset_n
	// KEY[1] - Start after chosen # of starting blocks
	// KEY[2] - Choose Block
	// KEY[3] - Where to move
	// KEY[1] - Start Game
	control c0(
		// input keys
		.clk(CLOCK_50),
		.startkey(KEY[1]),
		.blockkey(KEY[2]),
		.setkey(KEY[3]),
		.startgamekey(KEY[1]),
		.reset_n(resetn),
		.ld_x(controlA),
		.ld_y(controlB),
		.ld_colour(controlC),
		.ld_out(writeEn)
		);

	// output wins to HEX0
	hex_decoder hex0(
		.hex_digit(winout[3:0]),
		.segments(HEX0)
		);

	// output losses to HEX2
	hex_decoder hex2(
		.hex_digit(loseout[3:0]),
		.segments(HEX1)
		);

  // output # of starting blocks counter
	// using default 4 for now
	hex_decoder hex5(
		.hex_digit(numBlocks),
		.segments(HEX5)
		);

endmodule

// -------------------------------------------------------------------------
// Datapath module
//Runs depending on state and stores input and output registers
module datapath (
	input clk,
	input reset_n,
	input [2:0] pos,
	// input states
	input ld_start,
	input ld_block,
	input ld_set,
	input ld_startgame,

	// registers to output to VGA
	output reg [7:0] xout,
	output reg [6:0] yout,
	output reg [2:0] colourout,
	// Registers for the end of the game
	output reg [3:0] wins,
	output reg [3:0] losses,
	// number of blocks at start
	output reg [3:0] startingBlocks
	);

	// input registers
	reg [7:0] x_in;
	reg [6:0] y_in;
	reg [3:0] counter;
	// rgb(0,0,0)

	// Registers start, block, set,startgame with respective input logic
	always@(posedge clk) begin
		 if(!reset_n) begin
				 x_in <= 7'b0;
				 y_in <= 6'b0;
				 colour_in <= 3'b0;
				 wins <= 3'b0;
				 losses <= 3'b0;
				 // begin with default 4 blocks
				 startingBlocks <= 4'b0100;
		 end
		 else begin

				// From control FSM, Press Key[0]
				if(ld_start) begin
						 // clear module
						 // draw target and startblock - drawStart module
						 // init writeText module
						 // writeText - highlight start
						 // number of blocks - 4
						 startingBlocks <= 4'b0100;
				end

				// From control FSM, Press Key[1]
				if(ld_block) begin
						//writeText module - highlight block
						//If SW[0] then make block vertical
						//elif SW[1] then make block horizontal
						// display block

				end

				 // From control FSM, Press Key[2]
				if(ld_set) begin
						 //writeText module - highlight set
						 // For numbers from input
						 // Setting Position (red)
						 // When set make color gray
						 // block module, draw vertical or horizontal block depending on what was chosen
						 // set to register
				 end

					// From control FSM, Press Key[1]
				 if (ld_startgame) begin
						//writeText module - highlight startgame
						//if up (SW[0]) then move startblock up
						//elif (SW[1]) then move startblock down
						// run game
						//increment win or loss using HEX
						//HEX[0] for win
						//HEX[1] for loss
				 end
		  end
		end

		// Determines who wins or loses
		endgamemux endofgame(
			.reg_win(wins),
			.reg_lose(losses),
			.in()
			.out(HEX0),
			.out1(HEX2)
			);

endmodule

// -------------------------------------------------------------------------
// FSM Control module
// Controls the states using KEY
module control(
	input clk,
	input reset_n,
	// State control keys
	input startkey,
	input blockkey,
	input setkey,
	input startgamekey,

	// output states to datapath
	output reg ld_startgame,
	output reg ld_start,
	output reg ld_block,
	output reg ld_set
	);
	reg [5:0] current_state, next_state;

	localparam  	S_START              = 3'd0,
						    S_START_WAIT         = 3'd1,
						    S_LOAD_BLOCK         = 3'd2,
						    S_LOAD_BLOCK_WAIT    = 3'd3,
						    S_LOAD_SET           = 3'd4,
						    S_LOAD_SET_WAIT      = 3'd5,
						    S_OUT_STARTGAME      = 3'd6,
						    S_OUT_STARTGAME_WAIT = 3'd7;

	// Next state logic aka our state table
	always@(*)
	begin: state_table
			case (current_state)
					S_START: next_state = startkey ? S_START_WAIT : S_START; // Loop in current state until value is input
					S_START_WAIT: next_state = startkey ? S_START_WAIT : S_LOAD_BLOCK; // Loop in current state until go signal goes low
					S_LOAD_BLOCK: next_state = blockkey ? S_LOAD_BLOCK_WAIT : S_LOAD_BLOCK; // Loop in current state until value is input
					S_LOAD_BLOCK_WAIT: next_state = blockkey ? S_LOAD_BLOCK_WAIT : S_LOAD_SET; // Loop in current state until go signal goes low
					S_LOAD_SET: next_state = setkey ? S_LOAD_SET_WAIT : S_LOAD_SET; // Loop in current state until value is input
					S_LOAD_SET_WAIT: next_state = setkey ? S_LOAD_SET_WAIT : S_OUT_STARTGAME; // Loop in current state until go signal goes low
					S_OUT_STARTGAME: next_state =  startgamekey ? S_OUT_STARTGAME_WAIT : S_OUT_STARTGAME; // Loop in current state until value is input
					S_OUT_STARTGAME_WAIT: next_state = startgamekey ? S_OUT_STARTGAME_WAIT : S_START;  // we will be done our two operations, start over after
					default: next_state = S_START;
			endcase
	end // state_table

	// Output logic aka all of our datapath control signals
	always @(*) begin
			// By default make all our signals 0
			ld_start = 1'b0;
			ld_block = 1'b0;
			ld_set = 1'b0;
			ld_startgame = 1'b0;

			case (current_state)
					S_START: begin
							ld_start = 1'b1;
					end
					S_LOAD_BLOCK: begin
							ld_block = 1'b1;
					end
					S_LOAD_SET: begin
							ld_set = 1'b1;
					end
					S_OUT_STARTGAME: begin
							ld_startgame = 1'b1;
					end
					// default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
			endcase
	end // enable_signals

	// current_state registers
	always@(posedge clk) begin
			if(!reset_n)
					current_state <= S_START;
			else
					current_state <= next_state;
	end // state_FFS

endmodule

// -------------------------------------------------------------------------
// HEX Decoder module
// outputs binary to the HEX display
module hex_decoder(hex_digit, segments);
  input [3:0] hex_digit;
  output reg [6:0] segments;

  always @(*)
      case (hex_digit)
          4'h0: segments = 7'b100_0000;
          4'h1: segments = 7'b111_1001;
          4'h2: segments = 7'b010_0100;
          4'h3: segments = 7'b011_0000;
          4'h4: segments = 7'b001_1001;
          4'h5: segments = 7'b001_0010;
          4'h6: segments = 7'b000_0010;
          4'h7: segments = 7'b111_1000;
          4'h8: segments = 7'b000_0000;
          4'h9: segments = 7'b001_1000;
          4'hA: segments = 7'b000_1000;
          4'hB: segments = 7'b000_0011;
          4'hC: segments = 7'b100_0110;
          4'hD: segments = 7'b010_0001;
          4'hE: segments = 7'b000_0110;
          4'hF: segments = 7'b000_1110;
          default: segments = 7'h7f;
      endcase

endmodule

// -------------------------------------------------------------------------
// Startblock counter module
// counter that will keep counting the from 1-4
// module startblockcounter(out)
