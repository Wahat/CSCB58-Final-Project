// -------------------------------------------------------------------------
// counterhz module
// outputs counter signals depending on the speed
// 2'b00 - 50mhz
// 2'b01 - 1hz
// 2'b10 - 0.5hz
// 2'b11 - 0.25MHz
module counterhz(enable, clk, reset_n, speed, counterlimit, counterOut);
  input enable;
  input reset_n;
  input clk; // CLOCK_50
  input [1:0] speed; // input speed
  // sets the limit of the counter
  // e.g 4'b0100 for counting up to 4
  input [3:0] counterlimit;
  output [3:0] counterOut; // signals from the modified counter

  // wires from the outputs of the rate dividers
  wire [27:0] c50hzOut;
  wire [27:0] c1hzOut;
  wire [27:0] c0_5hzOut;
  wire [27:0] c0_25hzOut;

  // register to hold the value of the enable
  reg outEnable;

  // input speed
  // 2'b00 - 50mhz
  // 2'b01 - 1hz
  // 2'b10 - 0.5hz
  // 2'b11 - 0.25MHz

  always @ (posedge clk)
  begin
    case (speed)
      2'b00: begin // 50hz out
        if (c50hzOut == 28'b0)
          outEnable <= 1'b1;
        else
          outEnable <= 1'b0;
        end

      2'b01: begin // 1hz out
        if (c1hzOut == 28'b0)
          outEnable <= 1'b1;
        else
          outEnable <= 1'b0;
        end

      2'b10: begin // 0.5hz out
        if (c0_5hzOut == 28'b0)
          outEnable <= 1'b1;
        else
          outEnable <= 1'b0;
        end

      2'b11: begin // 0.25 hz
        if (c0_25hzOut == 28'b0)
          outEnable <= 1'b1;
        else
          outEnable <= 1'b0;
        end
      default: outEnable = 1'b0;

    endcase
  end

// modules
  // rate divider for 50hz
  // countdown from 1
  ratedivider clock50hz(
    .enable(enable),
    .reset_n(~reset_n),
    .clk(clk),
    .countdownvalue(28'b0000000000000000000000000001),
    .q(c50hzOut)
    );

  // rate divider for 1hz
  // countdown from 49999999
  ratedivider clock1hz(
    .enable(enable),
    .reset_n(~reset_n),
    .clk(clk),
    .countdownvalue(28'b0010111110101111000001111111),
    .q(c1hzOut)
    );

  // rate divider for 0.5hz
  // countdown from 99999999
  ratedivider clock0_5hz(
    .enable(enable),
    .reset_n(~reset_n),
    .clk(clk),
    .countdownvalue(28'b0101111101011110000011111111),
    .q(c0_5hzOut)
    );

  // rate divider for 0.25hz
  // countdown from 199999999
  ratedivider clock0_25hz(
    .enable(enable),
    .reset_n(~reset_n),
    .clk(clk),
    .countdownvalue(28'b1011111010111100000111111111),
    .q(c0_25hzOut)
    );

  // outEnable is wired to the enable of the counter
  // to change the speed of each clock pulse
  counter modifiedcounter(
    .enable(outEnable),
    .reset_n(~reset_n),
    .clk(clk),
	 .limit(counterlimit[3:0]),
    .q(counterOut)
    );


endmodule

// -------------------------------------------------------------------------
// counter module
// increments only when enable is 1
// once it overflows (from 4'b1111 + 4'b0001 = 4'b0000) then it goes back to 0
module counter(enable, reset_n, clk, limit, q);
  input enable;
  input reset_n;
  input clk;
  input [3:0] limit;
  output [3:0] q;
  reg [3:0] q;

  always @ (posedge clk)
  begin
    if(reset_n == 1'b0)
      q <= 4'b000;
    else if(enable == 1'b1) begin
		if (q == limit) // if the counter reaches the limit, reset
			q <= 4'b000;
		else
			q <= q + 1'b1;
	 end
  end

endmodule

// -------------------------------------------------------------------------
// rate divider module
module ratedivider(enable, reset_n, clk, countdownvalue, q);
  input enable;
  input reset_n;
  input clk;
  input [27:0] countdownvalue;
  output [27:0] q;
	reg [27:0] q;

  always @ (posedge clk)
  begin
    if(reset_n == 1'b0)
      q <= countdownvalue; // Set back to initial count down value
    else if(enable == 1'b1) begin
				 if (q == 1'b0)
				 // if q returns to 0 (overflow from 4'b1111 + 4'b0001 = 4'b0000)
				 // then set reset the q value
				 		q <= countdownvalue;
				 else
				 // else decrement value from count down
				 		q <= q - 1'b1;
		end
  end

endmodule
