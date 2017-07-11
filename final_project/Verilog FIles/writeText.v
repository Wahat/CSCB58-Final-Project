module highlightstate(statenum, xout, yout, colourout);
	input [3:0] statenum;
	output reg xout;
	output reg yout;
	output reg colourout;
	
	always @ (*)
	begin
		case (statenum[3:0])
			3'b000: begin // begin state
					  //drawsquare
			end
			3'b001: begin // load block
					  //drawsquare
			end
			3'b010: begin // load set
					  //drawsquare
			end
			3'b011: begin // load start game
					  //drawsquare
			end
			3'b100: begin // load end game
				     //drawsquare
			end
			
	    endcase
	
	end

endmodule