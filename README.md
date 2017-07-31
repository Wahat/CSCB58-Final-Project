# Bounce
The final project for CSCB58 Summer 2017 using the DE2-115 FGPA Board along with VGA and a PS2 keyboard. \
Place and set a number of blocks for a ball to bounce off and fire the ball. If you hit the target, your score increments.
* PS2 and VGA modules and supporting files are their respective folders.
* main file, project.v is located in final_project
* other supporting modules (graphics.v, counter.v, collision.v) are in 'final_project/Verilog Files'

## Members
<h4>Kevin Shen</h4>
<h4>Joon Hong</h4>

## Controls and Instructions
There are 5 main states of the game and the objective is to place the blocks in a way such that the ball can bounce off them inorder to hit the yellow target on the screen:
* Select: Where you choose the number of blocks
* Choose: Where you choose if you want a vertical or Horizontal blocks
* Set: Where you choose the location and set the blocks
* Start: Where you choose the direction the ball goes to
* Endgame: Where you review the score then reset the game back to the original state

Depending on the state of the game, there are different controls. The state is highlighted on the VGA screen for the user.

| State   | Purpose                                                                                     | Controls                        | Next State |
|---------|---------------------------------------------------------------------------------------------|---------------------------------|------------|
| SELECT   | Choose the number of blocks you want (displayed on HEX[5])                                  | none                            | KEY[1]     |
| CHOOSE  | Choose the type of block you want (High for Vertical, Low for Horizontal)                   | SW[0]                           | KEY[2] then hold KEY[3]     |  
| SET     | Move the block to the desired location using the Arrow Keys                                 | PS2 (Arrow Keys + Space to set) | KEY[1]     |  
| START   | Select the direction in which you want the ball to be fired to. (High for Up, Low for down) | SW[0]                           | KEY[1] then KEY[2]    |
| ENDGAME |  Review your moves and score                                                                | none                            | KEY[1]  then KEY[2]   |

##### Displays
- The Wins and Losses are store in HEX0 and HEX2 respectively.
- HEX4 is used to display how many blocks the user has left.
- HEX5 is used to display the number of blocks the user has total.
- The green LEDS show what state the user is in binary

## Sources
##### PS2 module
* Based on <a>http://www.eecg.toronto.edu/~jayar/ece241_08F/AudioVideoCores/ps2/ps2.html</a>
* Modified for DE2-115 pin assignments

##### Ballcollisions and Ballpos modules

* Based on <a> https://github.com/felixmo/Pong/blob/master/pong.v </a>
* Modified to support blocks and the 120 x 120 playing field of the game


##### Background.mif file
* Created generated using <a> http://www.eecg.utoronto.ca/~jayar/ece241_08F/vga/bmp2mif.zip </a>

##### VGA Adapter from Lab 6 Part 2 starter code

##### Hex Decoder from Lab 5 Prelab
