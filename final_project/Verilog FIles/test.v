// Part 2 skeleton

module part2
	( CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
    KEY,
    SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);
	input		CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]

	wire resetn;
	assign resetn = KEY[0];

	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire controlA, controlB, controlC;
	wire plot;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(plot),
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

	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.

    // Instansiate datapath
	// datapath d0(...);
	datapath d0(
		.clk(CLOCK_50),
		.reset_n(resetn),
		.pos(SW[6:0]),
		.colourin(SW[9:7]),
		.ld_x(controlA),
		.ld_y(controlB),
		.ld_colour(controlC),
		.ld_out(writeEn),
		.xout(x),
		.yout(y),
		.colourout(colour),
		.plot(plot)
		);

    // Instansiate FSM control
    // control c0(...);
	control c0(
		.clk(CLOCK_50),
		.go(KEY[1]),
		.xkey(KEY[3]),
		.reset_n(resetn),
		.ld_x(controlA),
		.ld_y(controlB),
		.ld_colour(controlC),
		.ld_out(writeEn)
		);

endmodule

module datapath (
	 input clk,
	 input reset_n,
	 input [6:0] pos,
	 input [2:0] colourin,
	 input ld_x,
	 input ld_y,
   input ld_out,
	 input ld_colour,

	 output [7:0] xout,
	 output [6:0] yout,
	 output reg [2:0] colourout,
	 output [0:0] plot
	 );

	 // input registers
	 reg [7:0] x_in;
	 reg [6:0] y_in;
	 reg [2:0] colour_in;
	 reg [3:0] counter;
	 reg vga_out;


	 // output of the alu


	 // Registers a, b, c, x with respective input logic
	 always@(posedge clk) begin
			 if(!reset_n) begin
					 x_in <= 7'b0;
					 y_in <= 6'b0;
					 colour_in <= 3'b0;
					 vga_out <= 1'b0;
					 counter <= 4'b0000;
			 end
			 else begin
					 if(ld_x) begin
							 x_in[7:0] <= {1'b0, pos}; // load alu_out if load_alu_out signal is high, otherwise load from data_in
							 xout[7:0] <= x_in[7:0];
						end
					 if(ld_y) begin
							 y_in[6:0] <= pos; // load alu_out if load_alu_out signal is high, otherwise load from data_in
							 yout[6:0] <= y_in[6:0];
					 end
					 if(ld_colour) begin
							 counter <= counter + 1;
							 if (counter == 4'b0000) begin
							 		vga_out = 1'b0;
								end
					  end
						if (ld_out) begin
							vga_out = 1'b1;
						end
			 end
	 end
	 assign draw = vga_out;
	 assign xout = x_in + counter[1:0];
	 assign yout = y_in + counter[3:2];




endmodule


module control(
	input clk,
	input reset_n,
	input go,
	input xkey,

	output reg ld_out,
	output reg ld_x,
	output reg ld_y,
	output reg ld_colour
	);
	reg [5:0] current_state, next_state;

	localparam  S_LOAD_X      = 3'd0,
						S_LOAD_X_WAIT   = 3'd1,
						S_LOAD_Y        = 3'd2,
						S_LOAD_Y_WAIT   = 3'd3,
						S_LOAD_COLOUR        = 3'd4,
						S_LOAD_COLOUR_WAIT   = 3'd5,
						S_OUT_DATA        = 3'd6,
						S_OUT_DATA_WAIT = 3'd7;


// Next state logic aka our state table
always@(*)
begin: state_table
				case (current_state)
						S_LOAD_X: next_state = xkey ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input
						S_LOAD_X_WAIT: next_state = xkey ? S_LOAD_X_WAIT : S_LOAD_Y; // Loop in current state until go signal goes low
						S_LOAD_Y: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_Y; // Loop in current state until value is input
						S_LOAD_Y_WAIT: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_COLOUR; // Loop in current state until go signal goes low
						S_LOAD_COLOUR: next_state = go ? S_LOAD_COLOUR_WAIT : S_LOAD_COLOUR; // Loop in current state until value is input
						S_LOAD_COLOUR_WAIT: next_state = go ? S_LOAD_COLOUR_WAIT : S_OUT_DATA; // Loop in current state until go signal goes low
						S_OUT_DATA: next_state = go ? S_OUT_DATA_WAIT : S_OUT_DATA; // Loop in current state until value is input
						S_OUT_DATA_WAIT: next_state = go ? S_OUT_DATA_WAIT : S_LOAD_X;  // we will be done our two operations, start over after
				default: next_state = S_LOAD_X;
		endcase
end // state_table

// Output logic aka all of our datapath control signals
always @(*) begin
		// By default make all our signals 0
		ld_x = 1'b0;
		ld_y = 1'b0;
		ld_colour = 1'b0;
		ld_out = 1'b0;

		case (current_state)
				S_LOAD_X: begin
						ld_x = 1'b1;
						end
				S_LOAD_Y: begin
						ld_y = 1'b1;
						end
				S_LOAD_COLOUR: begin
						ld_colour = 1'b1;
						end
				S_OUT_DATA: begin
						ld_out = 1'b1;
						end

		// default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
		endcase
end // enable_signals

// current_state registers
always@(posedge clk) begin
		if(!reset_n)
				current_state <= S_LOAD_X;
		else
				current_state <= next_state;
end // state_FFS
endmodule
