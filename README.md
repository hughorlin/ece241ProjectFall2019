# ece241ProjectFall2019

Projct “Color Infection”

Author: Hugh && Haley

Time: Nov. 2019

Sponser TA: Jaina P.

Project Description

1.0 Project Introduction

This project is to design a user interface game implemented on an FPGA board. During the design process, a VGA adapter and a keyboard of PS2 output have been utilized to reach the success of the project. The game design incorporates the understanding of logic circuits and is implemented through basic features of verilog introduced from the course. The motivation behind the project is to undertake the challenges of using hardware language to build up the game logic system and initialize game data source and embedding in some software algorithms for the purpose of enhancing game experience.

1.1 Game Description

1.1.1 The game has three modes: single-player mode (key S), multiplayer mode (key M), and AI competition mode (key A).
Player should follow the instruction to input their selections of game modes and game actions by pressing corresponding keys of the keyboard.

1.1.2 For single-player mode, the player should complete dying all the blocks into one single colour within 30 steps. 

1.1.3 For multiplayer mode, two players start dying blocks from opposite corners of the game region. The one who occupies a greater number of blocks will win the game. 

1.1.4 For AI competition mode, there will be a computer opponent conducting simple algorithm playing against the player 


2.0 Design Strategy Outline and Basic Logic Behaviours 

ActiveArrayA & ActiveArrayB: Two [255:0] 1-bit width arrays storing the state of each block of player A and player B respectively, while 1 represents active and 0 represents inactive.

ColourArray: A [255:0] 3-bit width array storing the colour of each block.

LFSR: Linear Shift Feedback Register to randomly initialize the colour array.
Translator: The make keycodes and break keycodes detected from PS2 keyboard will be translated into useful signals, and further processed into datapath.

PixelScore: To overcome the lack of division in verilog, the module is written to convert decimal numbers less than 3 digits into different combinations of arrays. There are 11 local parameters of 45-bit number representing sprite images of numbers “0” to “9” and “empty”. 

Counters for xloc and yloc: 
xloc: the xloc counter counts x from 0 to 15 with an increment of 1 for each positive clock edge.
yloc: the yloc counter counts y from 0 to 15 with an increment of 1 for each time when xloc reaches 0.
loc: the wire “loc” indicates the index of array corresponding to the location of the block. It is expressed as 16*yloc + xloc. Loc changes with different x locations and y locations. When “loc” reaches 255, both counters stop counting, waiting for the next signal to be activated again.

Update: Given the array index corresponding to block of location “loc” and the input “colourin”, the current colour and state information of the block and those of its neighbours will be checked. If conditions are matched, both “loc”th element of activeArray and colourArray will be updated. The “loc” will change from 0 to 255 ensuring all block information is updated timely.

Outputs to VGA (Plot):

i) Game zone: The square with upper left corner at location (12,12) and lower right corner (107,107).  The updated colourArray for each location will be checked and bounded up with the output reg “colourout”. The x and y output locations will be calculated based on the designed layout of game and sent to the VGA module. Two new counters of x and y will perform so each block of size 5*5 will be drawn.

ii) Score zone: The steps used in single-player mode and the number of blocks occupied in multiplayer mode are tracked and output onto the screen at a fixed position after the gamezone is successfully updated. 

iii) Win or Lose: The activearray will be inspected after it is updated to check the game progress. Pictures will be displayed for different results in each game mode.

3.0 Game Restriction 

3.0.1 It is assumed that the user inputs through keyboard are all correct. For instance, when a new round of game starts, only “W” (white), “C” (cyan), “P” (pink), and “B” (blue) are supposed to be pressed rather than those keys for game mode selections. If the player mispress other potential keys during the game, the game mode will switch unexpectedly, thus resulting in game board malfunction.

3.0.2 Game board output is different each time thus hard to manipulate difficulty levels.

3.0.3 Player in AI mode can only compete as Player A and the AI algorithm has a lot of room for reinforcement.

3.0.4 Only four distinct colors have been selected for the game which decreases complexity in terms of color diversity; more colors can be added to increase the game complexity.

3.1 Possible Improvement 

3.1.1 Adding more colors to increase the game complexity. 

3.1.2 Introduce new multiplayer mode such that players could choose which color blocks to start infect with.

3.1.3 AI algorithm is not complex enough and further improvements could be C-aided CPU programming and neuron network or deep learning network.


