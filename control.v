module control(clk,reset,start,initupdate,initplot,update,plot,check,gameplot,doneinitiupdate,doneInitialize,doneupdate,doneDraw,doneCheck,gameOver,colorout,blue,rose,cyan,white,ledr,plotSteps,doneSteps,sig_reset,doneblacked,black,donereset,gameend,AI,doAI,AIdone,AIcolor,turnAI,doneNBKR,plotNBKR);




	
	input clk,reset,start,blue,rose,cyan,white,AI;
	input doneinitiupdate,doneInitialize,doneupdate,doneDraw,doneCheck,gameOver,doneSteps,doneblacked,donereset,AIdone,doneNBKR;
	input [2:0] AIcolor;
	reg firstTime = 1; // offset to game initialization
	
	output reg initupdate,initplot,update,plot,check,gameplot,plotSteps,sig_reset,black,gameend,doAI,plotNBKR;
	output reg [2:0]colorout;
	output [3:0]ledr;
	input turnAI;
	
	wire press;
	
	reg doReset = 0;
	
	assign press = blue || rose || cyan || white;
	
	localparam			s_game_beforeInit = 4'b1111,
							s_game_start = 4'b1110,
							s_game_start_plot= 4'b1101,
							s_wait_color = 4'b1100,
							s_update = 4'b1011,
							s_plot = 4'b1010,
							s_checkOver = 4'b1001,
							s_game_end = 4'b1000,
							s_wait_color_wait = 4'b0000,
							s_plot_steps = 4'b0001,
							s_blaked = 4'b0011,
							s_AI_alg = 4'b0100,
							s_plot_number_bgr = 4'b0101,
							s_before_restart = 4'b0010;
	reg [3:0] current_state = s_before_restart;
	
	
	assign ledr = current_state;
	reg [3:0] next_state;
	always@(*)
	begin 
		case (current_state)
			s_before_restart:  next_state = donereset?s_game_beforeInit:s_before_restart; 
		

			s_game_beforeInit: next_state = start?s_blaked: s_game_beforeInit;
			
			
			s_blaked: next_state = doneblacked?s_game_start:s_blaked;
			
			
			s_game_start: next_state = doneinitiupdate?s_game_start_plot:s_game_start;
			s_game_start_plot : next_state = doneInitialize?s_plot_number_bgr:s_game_start_plot;
			s_wait_color:
			begin
						if(AI && turnAI)begin next_state = s_update; colorout = AIcolor;end
						else
						begin
							if (blue) begin next_state = s_wait_color_wait; colorout = 3'b001; end
							else if (rose) begin next_state = s_wait_color_wait; colorout = 3'b101; end
							else if (cyan) begin next_state = s_wait_color_wait; colorout = 3'b011; end
							else if (white) begin next_state = s_wait_color_wait;  colorout = 3'b111; end
							else begin next_state = s_wait_color; end
						end
			end
			s_wait_color_wait: next_state = press? s_wait_color_wait : s_update;
			s_update :next_state = doneupdate?s_plot:s_update;
			s_plot: next_state = doneDraw?s_plot_number_bgr:s_plot;
			s_plot_number_bgr: begin next_state = doneNBKR?(doReset?s_before_restart:(gameOver?s_game_end:s_plot_steps)):s_plot_number_bgr;  end
			s_plot_steps: next_state = doneSteps?s_checkOver:s_plot_steps;
			s_checkOver: next_state = doneCheck?(gameOver? s_plot_number_bgr:s_AI_alg):s_checkOver;
			s_AI_alg: next_state = AIdone?s_wait_color:s_AI_alg;
			s_game_end: next_state = s_game_end;
			default next_state = s_game_start;
		endcase 
	end
	
	
	always@(*)
			begin
				initupdate = 0;
				initplot = 0;
				update = 0;
				plot = 0;
				check = 0;
				gameplot = 0;
				plotSteps = 0;
				sig_reset = 0;
				black = 0;
				gameend =0;
				plotNBKR = 0;
				
				
				case(current_state)
					s_blaked: begin black = 1; plot = 1; end
					s_before_restart: sig_reset = 1;
					s_game_start: begin initupdate = 1; end
					s_game_start_plot: begin initplot = 1;plot = 1; end
					s_update: update = 1;
					s_plot_number_bgr: begin gameend = doReset?1:0; plotNBKR = 1; plot = 1; end
					s_plot_steps: plotSteps = 1;
					s_plot:plot = 1;
					s_AI_alg: doAI = 1;
					s_wait_color: plot = 0;
					s_checkOver: check = 1;
					s_game_end: gameend = 1;
				endcase
			end 
			
			
	always@(posedge clk) 
	begin
				if(reset || firstTime)
				begin current_state <= s_plot_number_bgr; firstTime<= 0;
				end
				else current_state <= next_state;
				
				if(reset || firstTime) doReset <= 1;
				else if(current_state == s_plot_number_bgr && doReset == 1) doReset <= 1;
				else doReset <= 0;
	end
					
endmodule	
			