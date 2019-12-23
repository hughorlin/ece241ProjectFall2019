module colorInfection
	( CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		SW,
		KEY,LEDR,PS2_CLK,	PS2_DAT,					// On Board Keys
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,
	);
	input			CLOCK_50;//	50 MHz
	inout 		PS2_CLK,	PS2_DAT;				
	input	[3:0]	KEY;					
	// Declare your inputs and outputs here
	input [9:0] SW;
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	output [9:0]LEDR;
	wire resetn;
	
	wire [7:0]command;
	wire pressing;
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	
	wire writeEn;
	
	wire start,blue,rose,cyan,white,multi,AI; // output from keyboard translator 
	
	wire initupdate,initplot,update,plot,check,gameplot,plotNBKR,gameOver,plotSteps,sig_reset,black,gameend; // output from control
	
	wire doneSteps,doneblacked,donereset,doneinitiupdate,doneInitialize,doneupdate,doneDraw,doneCheck,doneNBKR; // output from datapath
	
	wire [2:0]colours;
	wire doAI,AIdone,turnAI;
	wire [2:0] AIcolor;
	assign resetn = ~SW[9];
	wire resetc;
	
		
	

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
		defparam VGA.BACKGROUND_IMAGE = "bkg_final.mif";
		
		
		control c1(CLOCK_50,resetc,start,initupdate,initplot,update,plot,check,gameplot,doneinitiupdate,doneInitialize,doneupdate,doneDraw,doneCheck,gameOver,colours,blue,rose,cyan,white,LEDR[9:6],plotSteps,doneSteps,sig_reset,doneblacked,black,donereset,gameend,AI,doAI,AIdone,AIcolor,turnAI,doneNBKR,plotNBKR);
		datapath d1(sig_reset,CLOCK_50,initupdate,initplot,update,plot,check,gameplot,doneinitiupdate,doneInitialize,doneupdate,doneDraw,doneCheck,gameOver,colours,x,y,colour,writeEn,LEDR[3:0],plotSteps,doneSteps,doneblacked,black,donereset,multi,gameend,doAI,AIdone,AIcolor,turnAI,AI,doneNBKR,plotNBKR);	
		translator t1(CLOCK_50, command,pressing,start,blue,rose,cyan,white,multi,resetc,AI);
		PS2_Controller p1(.CLOCK_50(CLOCK_50),.reset(0),.PS2_CLK(PS2_CLK),					// PS2 Clock
 	.PS2_DAT(PS2_DAT), .received_data(command),.received_data_en(pressing));

endmodule
