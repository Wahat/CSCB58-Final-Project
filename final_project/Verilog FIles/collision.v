module collision(
   clock,
   reset,
	 // inputs
   startvelocityx,
   startvelocityy,
	 startposx,
	 startposy,

   bar1,
   bar2,
   bar3,
   bar4,

	 // outputs
    draw,
    xpos,
    ypos,
    win,
    lose
);
    input clock;
	  input reset;

	  input [15:0] bar1;
    input [15:0] bar2;
    input [15:0] bar3;
    input [15:0] bar4;
    input [15:0] bar5;

	  input startvelocityx;
    input startvelocityy;
	  input [7:0] startposx;
	  input [7:0] startposy;



    // for control
    output win;
    output lose;
	  reg win;
	  reg lose;
	  reg draw;

    // for the VGA
    output draw;
    output [7:0] xpos;
    output [7:0] ypos;
	  reg [7:0] xpos; // current position of the ball
    reg [7:0] ypos;

    reg [0:0] velocityx;
    reg [0:0] velocityy;


    // currently only implemented for the first bar, need to use some loop
    // [0] is 1 means a vertical bar, 0 means horz
    // [1:8] is the x position of the top of the bar
    // [9:15] is the y position of the top of the bar

    always@(clock) begin
		 if (reset) begin // if game is reset reset the ball
			 xpos[7:0] <= startposx[7:0]; // calculate these values later
			 ypos <= startposy;

			 velocityx = startvelocityx;
			 velocityy = startvelocityy;
			 win <= 1'b0;
			 lose <= 1'b0;
		 end

		 // check if ball hits outer walls
		 if ((ypos == 1'b1) || (ypos == 1110111)) begin
			  velocityy <= ~velocityy;
			  end

		 // check each bar
		 if (bar1[0] == 1'b1) begin // check if vertical bar
			  if (((ypos == (bar1[9:15] + 1'b1)) && (xpos == bar1[1:8])) || ((ypos == (bar1[9:15] + 4'b1010)) && (xpos == bar1[1:8]))) begin // check if it hit the top or bottom block

					velocityy <= ~velocityy;
			  end

			  if (((ypos >= bar1[9:15]) && (ypos <= (bar1[9:15] + 4'b1010)) && (xpos == (bar1[1:8] - 1'b1))) ||
				  ((ypos >= bar1[9:15]) && (ypos <= (bar1[9:15] + 4'b1010)) && (xpos == (bar1[1:8] + 1'b1)))) begin // check if hit left or right side

					velocityx <= ~velocityx;
			  end
		  end

		 // check if horz bar
		 else begin
				if (bar1[0] == 1'b0) begin // check if horz bar
					  if (((ypos == bar1[9:15]) && (xpos == bar1[1:8] - 1'b1)) || ((ypos == (bar1[9:15])) && (xpos == (bar1[1:8] + 2'b11)))) begin // check if it hit the left or right block

													//elif SW[1] then make block horizontalvelocityx <= ~velocityx;
					  end

					  if (((xpos >= bar1[1:8]) && (xpos <= (bar1[1:8] + 4'b1010)) && (ypos == (bar1[9:15] - 1'b1))) ||
							((xpos >= bar1[1:8]) && (xpos <= (bar1[9:15] + 4'b1010)) && (ypos == (bar1[9:15] + 1'b1)))) begin // check if hit top or bottom side

						  velocityy <= ~velocityy;
					  end
				end
		  end


      if (bar2[0] == 1'b1) begin // check bar2
         if (((ypos == (bar2[9:15] + 1'b1)) && (xpos == bar2[1:8])) || ((ypos == (bar2[9:15] + 4'b1010)) && (xpos == bar2[1:8]))) begin // check if it hit the top or bottom block

           velocityy <= ~velocityy;
         end

         if (((ypos >= bar2[9:15]) && (ypos <= (bar2[9:15] + 4'b1010)) && (xpos == (bar2[1:8] - 1'b1))) ||
           ((ypos >= bar2[9:15]) && (ypos <= (bar2[9:15] + 4'b1010)) && (xpos == (bar2[1:8] + 1'b1)))) begin // check if hit left or right side

           velocityx <= ~velocityx;
         end
       end

      else begin
         if (bar2[0] == 1'b0) begin // check if horz bar
             if (((ypos == bar2[9:15]) && (xpos == bar2[1:8] - 1'b1)) || ((ypos == (bar2[9:15])) && (xpos == (bar2[1:8] + 2'b11)))) begin // check if it hit the left or right block

                           //elif SW[1] then make block horizontalvelocityx <= ~velocityx;
             end

             if (((xpos >= bar2[1:8]) && (xpos <= (bar2[1:8] + 4'b1010)) && (ypos == (bar2[9:15] - 1'b1))) ||
               ((xpos >= bar2[1:8]) && (xpos <= (bar2[9:15] + 4'b1010)) && (ypos == (bar2[9:15] + 1'b1)))) begin // check if hit top or bottom side

               velocityy <= ~velocityy;
             end
         end
       end


       if (bar3[0] == 1'b1) begin // check bar3
          if (((ypos == (bar3[9:15] + 1'b1)) && (xpos == bar3[1:8])) || ((ypos == (bar3[9:15] + 4'b1010)) && (xpos == bar3[1:8]))) begin // check if it hit the top or bottom block

            velocityy <= ~velocityy;
          end

          if (((ypos >= bar3[9:15]) && (ypos <= (bar3[9:15] + 4'b1010)) && (xpos == (bar3[1:8] - 1'b1))) ||
            ((ypos >= bar3[9:15]) && (ypos <= (bar3[9:15] + 4'b1010)) && (xpos == (bar3[1:8] + 1'b1)))) begin // check if hit left or right side

            velocityx <= ~velocityx;
          end
        end


       // check if horz bar
       else begin
          if (bar3[0] == 1'b0) begin // check if horz bar
              if (((ypos == bar3[9:15]) && (xpos == bar3[1:8] - 1'b1)) || ((ypos == (bar3[9:15])) && (xpos == (bar3[1:8] + 2'b11)))) begin // check if it hit the left or right block

                            //elif SW[1] then make block horizontalvelocityx <= ~velocityx;
              end

              if (((xpos >= bar3[1:8]) && (xpos <= (bar3[1:8] + 4'b1010)) && (ypos == (bar3[9:15] - 1'b1))) ||
                ((xpos >= bar3[1:8]) && (xpos <= (bar3[9:15] + 4'b1010)) && (ypos == (bar3[9:15] + 1'b1)))) begin // check if hit top or bottom side

                velocityy <= ~velocityy;
              end
          end
        end


        if (bar4[0] == 1'b1) begin // check bar4
           if (((ypos == (bar4[9:15] + 1'b1)) && (xpos == bar4[1:8])) || ((ypos == (bar4[9:15] + 4'b1010)) && (xpos == bar4[1:8]))) begin // check if it hit the top or bottom block

             velocityy <= ~velocityy;
           end

           if (((ypos >= bar4[9:15]) && (ypos <= (bar4[9:15] + 4'b1010)) && (xpos == (bar4[1:8] - 1'b1))) ||
             ((ypos >= bar4[9:15]) && (ypos <= (bar4[9:15] + 4'b1010)) && (xpos == (bar4[1:8] + 1'b1)))) begin // check if hit left or right side

             velocityx <= ~velocityx;
           end
         end

        // check if horz bar
        else begin
           if (bar4[0] == 1'b0) begin // check if horz bar
               if (((ypos == bar4[9:15]) && (xpos == bar4[1:8] - 1'b1)) || ((ypos == (bar4[9:15])) && (xpos == (bar4[1:8] + 2'b11)))) begin // check if it hit the left or right block

                             //elif SW[1] then make block horizontalvelocityx <= ~velocityx;
               end

               if (((xpos >= bar4[1:8]) && (xpos <= (bar4[1:8] + 4'b1010)) && (ypos == (bar4[9:15] - 1'b1))) ||
                 ((xpos >= bar4[1:8]) && (xpos <= (bar4[9:15] + 4'b1010)) && (ypos == (bar4[9:15] + 1'b1)))) begin // check if hit top or bottom side

                 velocityy <= ~velocityy;
               end
           end
         end
		 // check if ball hits the target
		 if (((xpos >= 6'b111100) && (ypos >= 6'b111010)) && (ypos <= 6'b111110)) begin // check if ball has hit target
			  win = 1'b1;

		 end



		 // check if the ball goes out of bounds or will go out of bounds because there isn't enough space on the screen
		 if ((xpos == 1'b0) && (velocityx == 1'b0)) begin // check if at the left side and moving left
			  lose = 1'b1;
		 end
		 // move ball at the end
		 // check if 0
     if (velocityx == 1'b0)
            xpos -= 1'b1;
     else
		   xpos = xpos + velocityx;

     if (velocityx == 1'b0)
        ypos -= 1'b1;
      else
       	ypos = ypos + velocityy;

		 // draw to VGA if game is still going
		 if (win == lose) begin
			  draw <= 1'b1;
		 end
		 else begin
			  draw <= 1'b0;
		 end
end
endmodule
