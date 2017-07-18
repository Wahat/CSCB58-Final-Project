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
	 reg [3:0] counter = 3'b000;
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
							 if (counter == 3'b000) begin
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
