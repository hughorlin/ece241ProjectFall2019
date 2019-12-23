module datapath(sig_reset,clk,initupdate,initplot,update,plot,check,gameplot,doneinitiupdate,doneInitialize,doneupdate,doneDraw,doneCheck,gameOver,colorin,xout,yout,colorout,writeEn,ledr,plotSteps,doneSteps,doneblacked,black,donereset,multi,gameend,doAI,AIdone,AIcolor,turnAI,AI,doneNBKR,plotNBKR);	
			
			input clk,initupdate,initplot,update,plot,check,gameplot,sig_reset,plotSteps,black,multi,gameend,doAI,AI,plotNBKR;
			
			
			output reg doneblacked = 1'b0;
			output reg doneinitiupdate = 1'b0;
			output reg doneInitialize = 1'b0;
			output reg doneupdate = 1'b0;
			output reg doneDraw = 1'b0;
			output reg doneCheck = 1'b0;
			output reg gameOver= 1'b0;
			output reg doneSteps = 1'b0;
			output reg donereset = 1'b0;
			output reg AIdone = 1'b0;
			output writeEn;
			output [3:0]ledr;
			output reg [2:0] AIcolor = 3'b000;
			output reg turnAI = 1;
			output reg doneNBKR = 0;
			
			reg awin = 1;
			
			reg [7:0]scoreA = 1;
			reg [7:0]scoreB = 1;
			
			reg [7:0] colorB = 0;
			reg [7:0] colorW = 0;
			reg [7:0] colorP = 0;
			reg [7:0] colorC = 0;
			
			
			
			
			localparam	
							blue = 3'b001,
							white = 3'b111,
							cyan = 3'b011,
							pink = 3'b101,
							pixelwhite = 3'b111,
							pixeldark = 3'b000;
			
			wire  [1:0]randout; // random color generated with lfsr
			
			lfsr l1(randout,clk);
			
			input [2:0] colorin;
			output [7:0] xout,yout;
			output [2:0]colorout;
			reg [4:0] xloc = 0;
			reg [3:0] yloc = 0 ;
			reg [3:0] xincre = 0;
			reg [3:0] yincre = 0;
			wire [8:0]loc;
			
			reg doneP1 = 0;
			reg gameNOtwin = 0;
			
			reg [7:0]steps = 0;
			reg doingleft = 1;
			reg doingMid = 0;

			wire [44:0]pixeloc;
			reg [4:0]pixelx = 0;
			reg [8:0]pixely = 0;
			assign pixeloc = pixelx + pixely * 5;
			wire [44:0]pixelright;
			wire [44:0]pixelleft;
			wire [44:0]pixelMid;
			reg [12:0] conter = 0;
			reg [5:0] Nbkgx = 0;
			reg [5:0] Nbkgy = 0;
			wire [2:0]endpixel;
			wire [2:0]frameA;
			wire [2:0]frameB;
			wire [2:0]framabkg;
			wire [2:0]frambbkg;
			wire [2:0]singlefram;
			wire [2:0]gameWinfram;
			wire [2:0]menupixel;
			reg [6:0]xpos = 0;
			reg [6:0]ypos = 0;
			
			reg AI1 =0;
			pixscore p1((multi?(!doneP1?scoreA:scoreB):steps),pixelleft,pixelMid,pixelright);
			reg turnp1 = 1;
			assign loc = update?(turnp1?(xloc + yloc * 16):(255-(xloc + yloc * 16))):(xloc + yloc * 16);
			assign xout = plotNBKR?(Nbkgx + 112):((gameend || sig_reset)?(xpos + 12):(plotSteps?(doingleft?(131 + pixelx):((doingMid)?(137 + pixelx):(143 + pixelx))): (plot?(12 + xloc * 6 + xincre):(12 + xloc * 6))));
			assign yout = plotNBKR?(Nbkgy + 32):((gameend || sig_reset)?(ypos + 11):(plotSteps?(!doneP1?(32 + pixely):(46 + pixely)) : (plot?(12 + yloc * 6 + yincre):(12 + yloc * 6))));
			
			assign writeEn = plot || plotSteps || gameend || sig_reset;
			
			reg [2:0] colorarray[256:0];
			
			assign colorout = plotNBKR?((gameOver || gameend)?pixeldark:(multi?(turnp1?framabkg:frambbkg):singlefram)):(gameend?(multi?(awin?frameA:frameB):(gameNOtwin?endpixel:gameWinfram)):(sig_reset?menupixel:(plotSteps?(doingleft?(pixelleft[pixeloc]?pixelwhite:pixeldark):(doingMid?(pixelMid[pixeloc]?pixelwhite:pixeldark):(pixelright[pixeloc]?pixelwhite:pixeldark))):(black?pixeldark:colorarray[loc]))));
			
			
			gameEnd g1 (.address((xpos+ypos*96)),.clock(clk),.q(endpixel));
			newmenu me1(.address((xpos+ypos*96)),.clock(clk),.q(menupixel));
			
			Awin a1(.address((xpos+ypos*96)),.clock(clk),.q(frameA));
			Bwin b1(.address((xpos+ypos*96)),.clock(clk),.q(frameB));
			singleBkg s1 (.address((Nbkgx+Nbkgy*36)),.clock(clk),.q(singlefram));
			abkg ab1 (.address((Nbkgx+Nbkgy*36)),.clock(clk),.q(framabkg));
			bbkg bb1 (.address((Nbkgx+Nbkgy*36)),.clock(clk),.q(frambbkg));
			winfram w1 (.address((Nbkgx+Nbkgy*36)),.clock(clk),.q(gameWinfram));
			
			
		
			
			reg endgame =0;
			
			
			reg  [255:0]P1activearray = 0;
			reg  [255:0]P2activearray = 0;
			
			assign ledr = {colorarray[0],turnp1};
			
			
			always@(posedge clk)
			begin
			
				if(sig_reset && !donereset) 
				begin
				xpos <= xpos + 1;
				if((xpos == 95) && (ypos == 95)) 
				begin 
					Nbkgx = 0;
					Nbkgy = 0;
					awin = 1;
					doneP1 <= 0;
					AI1 <= 0;
					doneNBKR = 0;
					scoreA = 1;
					doingMid = 0;
					scoreB = 1;
					xpos <= 0; ypos = 0; 
					doingleft = 1;conter = 0;
					P1activearray = 0;
					P2activearray = 0; 
					colorarray[256] = 3'b000; 
					steps=0; 
					xloc <= 0; 
					yloc <= 0; 
					xincre<=0; 
					yincre<= 0;
					pixelx<=0; 
					pixely<=0;
					turnp1 <= 1;
					donereset <= 1;
					doneblacked <= 1'b0;
					doneinitiupdate <= 1'b0;
					doneInitialize <= 1'b0;
					doneupdate <= 1'b0;
					doneDraw <= 1'b0;
					doneCheck <= 1'b0;
					gameOver <= 1'b0;
					doneSteps <= 1'b0;
					endgame <= 0;
					gameNOtwin  = 0;
					colorB = 0;
					colorW = 0;
					colorP = 0;
					colorC = 0;
					AIdone = 0;
					turnAI = 1;
				end
				else if(xpos == 95 ) begin xpos <= 0; ypos <= ypos + 1; end
				
				end
				
				else if(black && !doneblacked)
				begin 
					donereset = 0;
					doneinitiupdate = 0;
					xincre <= xincre + 1;
					
					if( loc == 256) begin doneblacked <= 1; xloc <= 0; yloc <= 0; xincre<=0; yincre<= 0; end
					else if((xloc == 15) && (yloc < 15) && (xincre == 4) && (yincre == 5)) begin xincre <= 0; yincre <= 0;yloc <= yloc + 1; xloc <= 0; end
					else if((xincre == 5) && (yincre == 5)) begin xincre <= 0; yincre <= 0; xloc <= xloc + 1; end
					else if (xincre == 5) begin xincre <= 0; yincre <= yincre + 1; end
				end
				
				
				
				else if (initupdate && !doneinitiupdate) 
				begin
				
					if(randout == 0) begin 	colorarray[loc] = 3'b001; end
					else if(randout == 1) begin 	colorarray[loc] = 3'b101; end 
					else if(randout == 2) begin 	colorarray[loc] = 3'b011; end 
					else if(randout == 3) begin 	colorarray[loc] = 3'b111; end 
					
					colorarray[256] = 3'b000;
					
					P1activearray[0] = 1'b1;
					P2activearray[255] = multi?(1'b1):(1'b0);
					conter <= conter + 1;
					
					if(loc == 255 ) begin  xloc <= 0; yloc <= 0; xincre<=0; yincre<= 0;doneinitiupdate <= 1; conter <= 0; end
					else if( xloc == 15) begin yloc <= yloc + 1; xloc <= 0; end
					else if(conter == (13'd5000 - loc + xloc - yloc)) begin xloc <= xloc + 1; conter <= 0; end
					
					
				end
				
				
				
				else if(initplot && !doneInitialize)
				begin	
					gameOver <= 0;
					doneblacked = 0;
					xincre <= xincre + 1;
					
					if( loc == 256) 
					begin 
						doneInitialize <= 1;
						xloc <= 0; yloc <= 0;
						xincre<=0; yincre<= 0; 
					end

					else if((xloc == 15) && (yloc < 15) && (xincre == 4) && (yincre == 4)) begin xincre <= 0; yincre <= 0;yloc <= yloc + 1; xloc <= 0; end
					else if((xincre == 4) && (yincre == 4)) begin xincre <= 0; yincre <= 0; xloc <= xloc + 1; end
					else if (xincre == 4) begin xincre <= 0; yincre <= yincre + 1; end
					
				end
				   
				else if(update && !doneupdate)
				begin
				   doneCheck = 0;
					doneInitialize = 0;
					xloc <= xloc + 1;
					AIdone = 0;
					colorB = 0;
					colorW = 0;
					colorP = 0;
					colorC = 0;
					if((xloc ==15) && (yloc == 15)) begin turnp1 <= (multi?(turnp1?0:1):1); yloc <= 0; xloc <= 0; doneupdate <= 1;steps = steps + 1; xincre <= 0; yincre <= 0;end
					else if(xloc == 15)begin yloc <= yloc + 1; xloc <= 0; end
					
					if(turnp1)
					begin

						if (P1activearray[loc]) begin colorarray[loc] = colorin; end
						
						else if (loc == 15) //upper right
						begin
							if((!P2activearray[loc]) && (colorarray[loc] == colorin) && (P1activearray[loc + 16] || P1activearray[loc - 1]))
							begin
								P1activearray[loc] = 1'b1; scoreA = scoreA + 1;
							end
						end
						
						else if (loc == 240) //lower left
						begin
							if((!P2activearray[loc]) && (colorarray[loc] == colorin) && (P1activearray[loc - 16] || P1activearray[loc + 1]))
							begin
								P1activearray[loc] = 1'b1;scoreA = scoreA + 1;
							end
						end
						
						else if (loc == 255) //lower right
						begin
							if((!P2activearray[loc]) && (colorarray[loc] == colorin) && (P1activearray[loc - 16] || P1activearray[loc - 1]))
							begin
								P1activearray[loc] = 1'b1;scoreA = scoreA + 1;
							end
						end
						
						else if(loc < 15) //upper row
						begin
							if((!P2activearray[loc]) && (colorarray[loc] == colorin) && (P1activearray[loc + 16] || P1activearray[loc - 1] || P1activearray[loc + 1]))
							begin
								P1activearray[loc] = 1'b1;scoreA = scoreA + 1;
							end
						end
						
						else if(loc > 240) //bottom row
						begin
							if((!P2activearray[loc]) && (colorarray[loc] == colorin)&& (P1activearray[loc - 16] || P1activearray[loc - 1] || P1activearray[loc + 1]))
							begin
								P1activearray[loc] = 1'b1;scoreA = scoreA + 1;
							end
						end
						
						
						else if(xloc == 0)
						begin
							if((!P2activearray[loc]) && (colorarray[loc] == colorin) && (P1activearray[loc + 16] || P1activearray[loc - 16] || P1activearray[loc + 1]))
							begin
								P1activearray[loc] = 1'b1;scoreA = scoreA + 1;
							end
						end
						
						else if(xloc == 15)
						begin
							if((!P2activearray[loc]) && (colorarray[loc] == colorin) && (P1activearray[loc + 16] || P1activearray[loc - 16] || P1activearray[loc - 1]))
							begin
								P1activearray[loc] = 1'b1;scoreA = scoreA + 1;
							end
						end
						
						else 
						begin
							if((!P2activearray[loc]) && (colorarray[loc] == colorin) && (P1activearray[loc - 16] || P1activearray[loc + 16] ||P1activearray[loc - 1] || P1activearray[loc + 1]) )
							begin
								P1activearray[loc] = 1'b1;scoreA = scoreA + 1;
							end
						end
					end
					
					else
					begin
					
						if (P2activearray[loc]) begin colorarray[loc] = colorin; end
						
						else if (loc == 15) //upper right
						begin
							if((!P1activearray[loc]) && (colorarray[loc] == colorin) && (P2activearray[loc + 16] || P2activearray[loc - 1]))
							begin
								P2activearray[loc] = 1'b1;scoreB = scoreB + 1;
							end
						end
						
						else if (loc == 240) //lower left
						begin
							if((!P1activearray[loc]) && (colorarray[loc] == colorin) && (P2activearray[loc - 16] || P2activearray[loc + 1]))
							begin
								P2activearray[loc] = 1'b1;scoreB = scoreB + 1;
							end
						end
						
						else if (loc == 255) //lower right
						begin
							if((!P1activearray[loc]) && (colorarray[loc] == colorin) && (P2activearray[loc - 16] || P2activearray[loc - 1]))
							begin
								P2activearray[loc] = 1'b1;scoreB = scoreB + 1;
							end
						end
						
						else if(loc < 15) //upper row
						begin
							if((!P1activearray[loc]) && (colorarray[loc] == colorin) && (P2activearray[loc + 16] || P2activearray[loc - 1] || P2activearray[loc + 1]))
							begin
								P2activearray[loc] = 1'b1;scoreB = scoreB + 1;
							end
						end
						
						else if(loc > 240) //bottom row
						begin
							if((!P1activearray[loc]) && (colorarray[loc] == colorin)&& (P2activearray[loc - 16] || P2activearray[loc - 1] || P2activearray[loc + 1]))
							begin
								P2activearray[loc] = 1'b1;scoreB = scoreB + 1;
							end
						end
						
						
						else if(xloc == 15)
						begin
							if((!P1activearray[loc]) && (colorarray[loc] == colorin) && (P2activearray[loc + 16] || P2activearray[loc - 16] || P2activearray[loc + 1]))
							begin
								P2activearray[loc] = 1'b1;scoreB = scoreB + 1;
							end
						end
						
						else if(xloc == 0)
						begin
							if((!P1activearray[loc]) && (colorarray[loc] == colorin) && (P2activearray[loc + 16] || P2activearray[loc - 16] || P2activearray[loc - 1]))
							begin
								P2activearray[loc] = 1'b1;scoreB = scoreB + 1;
							end
						end
						
						else 
						begin
							if((!P1activearray[loc]) && (colorarray[loc] == colorin) && (P2activearray[loc - 16] || P2activearray[loc + 16] ||P2activearray[loc - 1] || P2activearray[loc + 1]) )
							begin
								P2activearray[loc] = 1'b1;scoreB = scoreB + 1;
							end
						end
					end
				end
				
				else if( plot && !doneDraw)
				begin
					doneupdate = 0;
					xincre <= xincre + 1;
					if(AI1) begin xloc <= 0; yloc <= 0; xincre<=0; yincre<= 0; AI1<= 0;end
					else if( loc == 256) begin doneDraw <= 1; xloc <= 0; yloc <= 0; xincre<=0; yincre<= 0; end
					else if((xloc == 15) && (yloc < 15) && (xincre == 4) && (yincre == 4)) begin xincre <= 0; yincre <= 0;yloc <= yloc + 1; xloc <= 0; end
					else if((xincre == 4) && (yincre == 4)) begin xincre <= 0; yincre <= 0; xloc <= xloc + 1; end
					else if (xincre == 4) begin xincre <= 0; yincre <= yincre + 1; end
				end
				
				else if( plotNBKR && !doneNBKR)
				begin
					Nbkgx <= Nbkgx + 1;
					if(Nbkgx == 35 && Nbkgy == 22) begin doneNBKR <= 1'b1; Nbkgx <= 0; Nbkgy <= 0; end
					else if(Nbkgx == 35) begin Nbkgx <= 0;Nbkgy <= Nbkgy + 1; end
				end
			
				else if( plotSteps && !doneSteps) 
				begin
					doneNBKR = 0;
					doneDraw = 0;
					if(doingleft)
					begin
						pixelx <= pixelx + 1;
						if ( pixeloc == 44) begin doingleft <= 1'b0; doingMid <= 1'b1; pixelx <= 0; pixely <= 0; end
						else if( pixelx == 4) begin pixelx <= 0; pixely <= pixely + 1; end
					end
					else if(doingMid)
					begin
						pixelx <= pixelx + 1;
						if ( pixeloc == 44) begin doingMid <= 1'b0; pixelx <= 0; pixely <= 0; end
						else if( pixelx == 4) begin pixelx <= 0; pixely <= pixely + 1; end
					end
					else
					begin 
						pixelx <= pixelx + 1;
						if ( pixeloc == 44 ) 
						begin 
						if(!multi) begin doingleft <= 1'b0; pixelx <= 0; pixely <= 0; doneSteps <= 1'b1; end
						else if(!doneP1) begin doingleft <= 1'b1; pixelx <= 0; pixely <= 0; doneP1 <= 1'b1; end 
						else begin doingleft <= 1'b0; pixelx <= 0; pixely <= 0; doneSteps <= 1'b1; end
						end
						else if( pixelx == 4) begin pixelx <= 0; pixely <= pixely + 1; end
						end
				end
				
				
				
				
				else if(check && !doneCheck)
				begin
					doneSteps = 0;
					doingleft = 1;
					doneP1 <= 0;
					doingMid = 0;
					xloc <= xloc + 1;
					
					if(((xloc == 15) && (yloc == 15)) ||(multi?0:(steps == 5'd30)))
					begin 
						if((steps == 30) && !multi) begin gameNOtwin = 1; end
						awin = (scoreA>scoreB)?1:0;
						gameOver <= 1; doneCheck <= 1;
						xloc <= 0; yloc <= 0; 
						xincre<=0; 
						yincre<= 0; 
					end
					else if( xloc == 15) begin yloc <= yloc + 1; xloc <= 0; end
					
					if(multi?(P2activearray[loc] == P1activearray[loc]):(!P1activearray[loc])) begin gameOver <= 0; doneCheck <= 1; yloc <= 0; xloc <= 0; end
				end
				
				else if(doAI && !AIdone)
				begin
					xloc <= xloc + 1;
					if(((xloc ==15) && (yloc == 15) )|| !AI) 
					begin 
						AI1 <= 1;
						if(colorB>=colorW)
						begin
							if(colorB>=colorC)
							begin
								if(colorB>=colorP) AIcolor = blue;
								else AIcolor = pink;
							end
							else
							begin
								if(colorC>=colorP) AIcolor = cyan;
								else AIcolor = pink;
							end
						end
						else
						begin
							if(colorW>=colorC)
							begin
								if(colorW>=colorP) AIcolor = white;
								else AIcolor = pink;
							end
							else
							begin
								if(colorC>=colorP) AIcolor = cyan;
								else AIcolor = pink;
							end
						end
						yloc <= 0; xloc <= 0; AIdone <= 1; xincre <= 0; yincre <= 0;
						turnAI <= AI?(!turnAI):0;
					end
					else if(xloc == 15)begin yloc <= yloc + 1; xloc <= 0; end
					
					if (P2activearray[loc]) begin end
						
						else if (loc == 15) //upper right
						begin
							if((!P1activearray[loc])&& (P2activearray[loc + 16] || P2activearray[loc - 1]))
							begin
								if(colorarray[loc] == blue) colorB = colorB+1;
								if(colorarray[loc] == white) colorW = colorW+1;
								if(colorarray[loc] == cyan) colorC = colorC+1;
								if(colorarray[loc] == pink) colorP = colorP+1;
							end
						end
						
						else if (loc == 240) //lower left
						begin
							if((!P1activearray[loc])&& (P2activearray[loc - 16] || P2activearray[loc + 1]))
							begin
								if(colorarray[loc] == blue) colorB = colorB+1;
								if(colorarray[loc] == white) colorW = colorW+1;
								if(colorarray[loc] == cyan) colorC = colorC+1;
								if(colorarray[loc] == pink) colorP = colorP+1;
							end
						end
						
						else if (loc == 255) //lower right
						begin
							if((!P1activearray[loc])&& (P2activearray[loc - 16] || P2activearray[loc - 1]))
							begin
								if(colorarray[loc] == blue) colorB = colorB+1;
								if(colorarray[loc] == white) colorW = colorW+1;
								if(colorarray[loc] == cyan) colorC = colorC+1;
								if(colorarray[loc] == pink) colorP = colorP+1;
							end
						end
						
						else if(loc < 15) //upper row
						begin
							if((!P1activearray[loc])&& (P2activearray[loc + 16] || P2activearray[loc - 1] || P2activearray[loc + 1]))
							begin
								if(colorarray[loc] == blue) colorB = colorB+1;
								if(colorarray[loc] == white) colorW = colorW+1;
								if(colorarray[loc] == cyan) colorC = colorC+1;
								if(colorarray[loc] == pink) colorP = colorP+1;
							end
						end
						
						else if(loc > 240) //bottom row
						begin
							if((!P1activearray[loc])&& (P2activearray[loc - 16] || P2activearray[loc - 1] || P2activearray[loc + 1]))
							begin
								if(colorarray[loc] == blue) colorB = colorB+1;
								if(colorarray[loc] == white) colorW = colorW+1;
								if(colorarray[loc] == cyan) colorC = colorC+1;
								if(colorarray[loc] == pink) colorP = colorP+1;
							end
						end
						
						
						else if(xloc == 15)
						begin
							if((!P1activearray[loc])&& (P2activearray[loc + 16] || P2activearray[loc - 16] || P2activearray[loc + 1]))
							begin
								if(colorarray[loc] == blue) colorB = colorB+1;
								if(colorarray[loc] == white) colorW = colorW+1;
								if(colorarray[loc] == cyan) colorC = colorC+1;
								if(colorarray[loc] == pink) colorP = colorP+1;
							end
						end
						
						else if(xloc == 0)
						begin
							if((!P1activearray[loc])&& (P2activearray[loc + 16] || P2activearray[loc - 16] || P2activearray[loc - 1]))
							begin
								if(colorarray[loc] == blue) colorB = colorB+1;
								if(colorarray[loc] == white) colorW = colorW+1;
								if(colorarray[loc] == cyan) colorC = colorC+1;
								if(colorarray[loc] == pink) colorP = colorP+1;
							end
						end
						
						else 
						begin
							if((!P1activearray[loc]) && (P2activearray[loc - 16] || P2activearray[loc + 16] ||P2activearray[loc - 1] || P2activearray[loc + 1]) )
							begin
								if(colorarray[loc] == blue) colorB = colorB+1;
								if(colorarray[loc] == white) colorW = colorW+1;
								if(colorarray[loc] == cyan) colorC = colorC+1;
								if(colorarray[loc] == pink) colorP = colorP+1;
							end
						end
					end
				
				
				
				else if(gameend && !endgame)
				begin 
					xpos <= xpos + 1;
					if((xpos == 95) && (ypos == 95)) begin endgame <= 1; xpos <= 0; ypos = 0; end
					else if(xpos == 95 ) begin xpos <= 0; ypos <= ypos + 1; end
				end
				
			end
		
					
endmodule





















			