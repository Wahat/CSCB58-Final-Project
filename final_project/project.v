// Top level Entity - main project module
module projectVGA
	( CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
    KEY,
    SW,
		HEX0,
		HEX2,
		HEX4,
		HEX5,
		LEDR,
		LEDG,
		// Bidirectionals
		PS2_CLK,
		PS2_DAT,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   					//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,				//	VGA BLANK
		VGA_SYNC,					//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);
	input		CLOCK_50;			//	50 MHz
	// input switches
	input   [9:0]   SW;
	input   [3:0]   KEY;
	// Bidirectionals
	inout PS2_CLK;
	inout PS2_DAT;
	// output hex
	output  [6:0]   HEX0;
	output  [6:0]   HEX2;
	output  [6:0]   HEX4;
	output  [6:0]   HEX5;
   // output leds
	output  [6:0]   LEDG;
	output  [16:0]  LEDR;
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			    VGA_CLK;   			//	VGA Clock
	output			    VGA_HS;				//	VGA H_SYNC
	output			    VGA_VS;				//	VGA V_SYNC DE2 Blackjack
	output			    VGA_BLANK;	   //	VGA BLANK
	output			    VGA_SYNC;			//	VGA SYNC
	output	[9:0]	  VGA_R;   			//	VGA Red[9:0]
	output	[9:0]	  VGA_G;	 			//	VGA Green[9:0]
	output	[9:0]	  VGA_B;   			//	VGA Blue[9:0]

	wire   resetn;
	assign resetn = KEY[0];

	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire writeEn;
	wire controlA, controlB, controlC, controlD, controlE, controlF, controlG, controlH, controlI;
	wire [2:0] colour;
	wire [6:0] x;
	wire [6:0] y;
	wire [3:0] winout;
	wire [3:0] loseout;
	wire [3:0] numBlocks;
	wire [6:0] ledout;
	wire [3:0] numBlocksUsed;
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
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK)
			);

		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "background.mif";

  // Instansiate datapath
	datapath d0(
		// input switches
		.clk(CLOCK_50),// writeText - highlight start
		.reset_n(resetn),
		.pos(SW[6:0]),
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),
		// input registers from FSM
		.ld_begin(controlA),
		.ld_block(controlB),
		.ld_set(controlC),
		.ld_startgame(controlD),
		.ld_endgame(controlE),
		.ld_begin_wait(controlF),
		.ld_block_wait(controlG),
		.ld_set_wait(controlH),
		.ld_startgame_wait(controlI),
		// output registers to VGA
		.xout(x),
		.yout(y),
		.colourout(colour),
		.plot(writeEn),
		// output to HEX displays
		.wins(winout),
		.losses(loseout),
		.blocksout(numBlocks)
		);

  // Instansiate FSM control
	// KEY[0] - reset_n
	// KEY[1] - Start after chosen # of starting blocks
	// KEY[2] - Choose Block
	// KEY[3] - Where to move
	// KEY[1] - Start Game
	// KEY[1] - End Game
	control c0(
		// input keys
		.clk(CLOCK_50),
		.beginkey(KEY[1]),
		.blockkey(KEY[2]),
		.setkey(KEY[3]),
		.startgamekey(KEY[1]),
		.endgamekey(KEY[1]),
		.reset_n(resetn),
		// state registers
		.ld_begin(controlA),
		.ld_block(controlB),
		.ld_set(controlC),
		.ld_startgame(controlD),
		.ld_endgame(controlE),
		.ld_begin_wait(controlF),
		.ld_block_wait(controlG),
		.ld_set_wait(controlH),
		.ld_startgame_wait(controlI),
		// out to led and hex
		.stateled(ledout[6:0]),
		.numBlocksUsed(numBlocksUsed[3:0])
		);

	// output wins to HEX0
	hex_decoder hex0(
		.hex_digit(winout[3:0]),
		.segments(HEX0[6:0])
		);

	// output losses to HEX2
	hex_decoder hex2(
		.hex_digit(loseout[3:0]),
		.segments(HEX2[6:0])
		);

	// output # of starting blocks counter
	// using default 4 for now
	hex_decoder hex4(
		.hex_digit(numBlocksUsed[3:0]),
		.segments(HEX4[6:0])
		);

  // output # of starting blocks counter
	// using default 4 for now
	hex_decoder hex5(
		.hex_digit(numBlocks[3:0]),
		.segments(HEX5[6:0])
		);

	// make assign leds to the current state
	assign LEDG[6:0] = ledout[6:0];

endmodule

// -------------------------------------------------------------------------
// Datapath module
//Runs depending on state and stores input and output registers
module datapath (
	input clk,
	input reset_n,
	input [2:0] pos,
	// input states
	input ld_begin,
	input ld_block,
	input ld_set,
	input ld_startgame,
	input ld_endgame,
	input ld_begin_wait,
	input ld_block_wait,
	input ld_set_wait,
	input ld_startgame_wait,

	// #####################################
	// Bidirectionals From eecg.utoronto.edu
	inout				PS2_CLK,
	inout				PS2_DAT,
	// #####################################

	// registers to output to VGA
	output [11:0] xout,
	output [10:0] yout,
	output [2:0] colourout,
	output plot,
	// Registers for the end of the game
	output reg [3:0] wins,
	output reg [3:0] losses,
	// number of blocks at start
	output [3:0] blocksout,
	// collisiontest for states
	output [6:0] stateleds
	);

	// input registers
	reg [3:0] counter;
	// block regs
	reg [15:0] block1;
	reg [15:0] block2;
	reg [15:0] block3;
	reg [15:0] block4;
	// rgb(0,0,0)

	reg [3:0] selected;
	reg blockenable;
	wire [3:0] numBlocks;
	reg [3:0] startingBlocks;
	reg [3:0] statereg;
	wire hit;
	wire obb;

	// #####################################
	// wires for PS2 module From eecg.utoronto.edu
  // Internal Wires
  wire		[7:0]	ps2_key_data;
  wire				  ps2_key_pressed;
	// #####################################

	// Registers start, block, set,startgame with respective input logic
	always@(posedge clk) begin
		 if(!reset_n) begin
				 wins <= 3'b0;
				 losses <= 3'b0;
				 blockenable = 1'b0;
		 end
		 else begin

				// From control FSM, Press Key[0]
				if(ld_begin) begin
						 statereg = 4'b0000;
						 blockenable = 1'b1; // begin looping through number of blocks

				end
				if(ld_begin_wait) begin
						 statereg = 4'b0001;
						 blockenable = 1'b0;
 						 startingBlocks[3:0] <= numBlocks[3:0];

				end

				// From control FSM, Press Key[1]
				if(ld_block) begin
						// stop looping through number of blocks
						// once the counter stops, it'll set the startingBlocks
						statereg = 4'b0010;

						// block module - set to red
				end

				if(ld_block_wait) begin
						// stop looping through number of blocks
						// once the counter stops, it'll set the startingBlocks
						statereg = 4'b0011;
						// block module - set to red
				end

				 // From control FSM, Press Key[2]
				if(ld_set) begin
						 statereg = 4'b0100;
						 // Draw block in grey
						 //colourout[2:0] <= 3'b101;
						 // block module, draw vertical or horizontal block depending on what was chosen
						 // set to register
				 end

				 if(ld_set_wait) begin
 						 statereg = 4'b0101;
 						 // Draw block in grey
 						 //colourout[2:0] <= 3'b101;
 						 // block module, draw vertical or horizontal block depending on what was chosen
 						 // set to register
 				 end

					// From control FSM, Press Key[1]
				 if (ld_startgame) begin
						statereg = 4'b0110;
						if (obb)
	 					 wins <= wins + 1;
	 				 if (hit)
	 					 losses <= losses + 1;
						//if up (SW[0]) then move startblock up
						//elif (SW[1]) then move startblock down
						// run game -> gameresult (0 or 1)

					end

					if (ld_startgame_wait) begin
 						statereg = 4'b0111;

 					end

					// From control FSM, Press KEY[1]
					if (ld_endgame) begin
							statereg = 4'b1000;

				 end
		   end
		end

		// Assign the number of blocks to HEX5
		assign blocksout[3:0] = numBlocks[3:0];
		// Determines who wins or loses
		/*
		endgamemux endofgame(
			.reg_win(wins),
			.reg_lose(losses),
		  .select(gameresult),
			.out(selected)
			);
		*/
	// counter for the number of blocks
	counterhz numblockscounter(
		.enable(blockenable),
		.clk(clk),
		.reset_n(!reset_n),
		.speed(3'b001),
		.counterlimit(4'b100), // only count up to 4
		.counterOut(numBlocks[3:0]) // set the number of blocks
		);


	graphics display(
		.clk(clk),
		.reset_n(reset_n),
		.state(statereg),
		.select(2'b01),
		.hit(hit),
		.oob(obb),
		.xout(xout),
		.yout(yout),
		.colourout(colourout),
		.plot(plot)
		);
 /*
	ball whiteball(
	.clk(clk),
	.select(2'b11),
	.reset_n(reset_n),
	.hit(hit),
	.outofbounds(obb),
	.xout(xout),
	.yout(yout),
	.colourout(colourout),
	.plot(plot)
	);
*/
	// Up - 8'h75, Down - 8'h72, Left - 8'h6b, Right - 74, space - 29
  // Source ###################################################################
	// http://www.eecg.toronto.edu/~jayar/ece241_08F/AudioVideoCores/ps2/ps2.html
	PS2_Controller PS2 (
	// Inputs
	.CLOCK_50(clk),
	.reset(~reset_n),

	// Bidirectionals
	.PS2_CLK (PS2_CLK),
 	.PS2_DAT (PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);
//#############################################################################


endmodule

// -------------------------------------------------------------------------
// FSM Control module
// Controls the states using KEY
module control(
	input clk,
	input reset_n,
	// State control keys
	input beginkey,
	input blockkey,
	input setkey,
	input startgamekey,
	input endgamekey,
	input [3:0] startingBlocks,

	// output states to datapath
	output reg ld_begin,
	output reg ld_block,
	output reg ld_set,
	output reg ld_startgame,
	output reg ld_endgame,

	output reg ld_begin_wait,
	output reg ld_block_wait,
	output reg ld_set_wait,
	output reg ld_startgame_wait,

	// output led of the current state and counter to hez
	output [6:0] stateled,
	output [3:0] numBlocksUsed
	);

	reg [6:0] current_state, next_state;
	wire [3:0] numBlocks;
	reg [26:0] count = 1'b0;

	localparam     S_BEGIN              = 4'd0,
						S_BEGIN_WAIT         = 4'd1,
						S_LOAD_BLOCK         = 4'd2,
	  					S_LOAD_BLOCK_WAIT    = 4'd3,
						S_LOAD_SET           = 4'd4,
						S_LOAD_SET_WAIT      = 4'd5,
						S_OUT_STARTGAME      = 4'd6,
						S_OUT_STARTGAME_WAIT = 4'd7,
					   S_OUT_ENDGAME        = 4'd8,
					   S_OUT_ENDGAME_WAIT   = 4'd9;


	// Next state logic aka our state table
	always@(*)
	begin: state_table
			case (current_state)
					S_BEGIN: begin
								next_state = beginkey ? S_BEGIN : S_BEGIN_WAIT;
								end // Loop in current state until value is input
					S_BEGIN_WAIT: begin
					next_state = S_LOAD_BLOCK; // Loop in current state until go signal goes low
					end
					S_LOAD_BLOCK: begin
												next_state = blockkey ? S_LOAD_BLOCK : S_LOAD_BLOCK_WAIT; // Loop in current state until value is input
					end
					S_LOAD_BLOCK_WAIT: next_state = S_LOAD_SET; // Loop in current state until go signal goes low
					S_LOAD_SET: begin
														if (numBlocksUsed == 3'b100) begin
																next_state = setkey ? S_LOAD_SET : S_LOAD_SET_WAIT;
														end
														else begin
																next_state = setkey ? S_LOAD_SET : S_LOAD_BLOCK;
																//numBlocksUsed <= setkey ? numBlocksUsed: (numBlocksUsed + 2'b10) ;
														end
											end
					S_LOAD_SET_WAIT: next_state = S_OUT_STARTGAME;
					S_OUT_STARTGAME: next_state =  startgamekey ? S_OUT_STARTGAME : S_OUT_STARTGAME_WAIT; // Loop in current state until value is input
					S_OUT_STARTGAME_WAIT: next_state = S_OUT_ENDGAME;// we will be done our two operations, start over after
					S_OUT_ENDGAME: next_state =  endgamekey ? S_OUT_ENDGAME: S_OUT_ENDGAME_WAIT; // Loop in current state until value is input
					S_OUT_ENDGAME_WAIT: next_state = endgamekey ? S_OUT_ENDGAME_WAIT : S_BEGIN;  // we will be done our two operations, start over after
					default: next_state = S_BEGIN;
			endcase
	end // state_table

	// Output logic aka all of our datapath control signals
	always @(*) begin
			// By default make all our signals 0
			ld_begin = 1'b0;
			ld_block = 1'b0;
			ld_set = 1'b0;
			ld_startgame = 1'b0;
			ld_endgame = 1'b0;

			ld_begin_wait = 1'b0;
			ld_block_wait = 1'b0;
			ld_set_wait = 1'b0;
			ld_startgame_wait = 1'b0;

			case (current_state)
					S_BEGIN: begin
							ld_begin = 1'b1;
					end
					S_BEGIN_WAIT: begin
							ld_begin_wait = 1'b1;
					end
					S_LOAD_BLOCK: begin
							ld_block = 1'b1;
					end
					S_LOAD_BLOCK_WAIT: begin
							ld_block_wait = 1'b1;
					end
					S_LOAD_SET: begin
							ld_set = 1'b1;
					end
					S_LOAD_SET_WAIT: begin
							ld_set_wait = 1'b1;
					end
					S_OUT_STARTGAME: begin
							ld_startgame = 1'b1;
					end
					S_OUT_STARTGAME_WAIT: begin
							ld_startgame_wait = 1'b1;
					end
					S_OUT_ENDGAME: begin
							ld_endgame = 1'b1;
					end
					// default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
			endcase
	end // enable_signals

	// current_state registers
	always@(posedge clk) begin
			if(!reset_n)
					current_state <= S_BEGIN;
			else
					current_state <= next_state;
	end // state_FFS

	// output to green leds
	assign stateled[6:0] = current_state[6:0];
	// output to hex display
	// counter for the number of blocks
	counterhz numblocksUsedcounter(
		.enable(!setkey),
		.clk(clk),
		.reset_n(!reset_n),
		.speed(3'b101),
		.counterlimit(4'b0100), // only count up to 4
		.counterOut(numBlocksUsed) // set the number of blocks
		);

endmodule

// -------------------------------------------------------------------------
// HEX Decoder module
// outputs binary to the HEX display
// This code is from Lab 5 Prelab
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
