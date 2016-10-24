`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tecnológico de Costa Rica
// Engineer: Mauricio Carvajal Delgado
// 
// Create Date: 03.17.2013 10:36:22
// Design Name: 
// Module Name: Receptor 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//					
///////////////////////////////////////////////////////////////////////////////////

module Receptor#(parameter DBIT=8, SB_TICK=16)(
	
	// DBIT #databits
    // SB_TICK#ticks for stop bits

    //INPUTS
    input wire clk, reset,
    input wire rx, s_tick,
    //OUTPUTS
    output reg rx_done_tick,
    output wire [7:0] dout
	);
	
	//symbolic state declaration
	localparam [1:0]
		idle = 2'b00,
		start = 2'b01,
		data = 2'b10,
		stop = 2'b11;
   // signal declaration
	reg [1:0] state_reg=0, state_next=0;
	reg [3:0] s_reg=0, s_next=0;
	reg [2:0] n_reg=0, n_next=0;
	reg [7:0] b_reg=0, b_next=0;
	
	// body
	// FSMD state&data registers
	
	always @( posedge clk, posedge reset)
		if (reset)
			begin
				state_reg <= idle;
				s_reg <= 0;
				n_reg <= 0;
				b_reg <= 0;
			end
		else
			begin
				state_reg <=state_next;
				s_reg <= s_next;
				n_reg <= n_next;
				b_reg <= b_next;
			end
		// FSMD next_state logic
   always @*
	
	begin
		state_next = state_reg;
		rx_done_tick = 1'b0;
		s_next = s_reg;
		
		n_next = n_reg;
		b_next = b_reg;
		
		case (state_reg)
			idle:
				if (~rx)
					begin
						state_next = start;
						s_next =0;
					end
					
			start:
				if (s_tick)
					if (s_reg==7)
						begin
							state_next = data;
							s_next = 0;
							n_next = 0;
						end
					else
						s_next = s_reg+1;
						
			data:
				if (s_tick)
					if (s_reg == 15)
							begin
							s_next = 0;
							b_next = {rx,b_reg [7:1]};
							if (n_reg==(DBIT-1))
								state_next = stop;
								else
									n_next = n_reg + 1;
							end
						else
							s_next = s_reg + 1;
							
			stop:
				if (s_tick)
					if (s_reg==(SB_TICK-1))
						begin
							state_next = idle;
							rx_done_tick = 1'b1;
						end
					else
						s_next = s_reg + 1;
			endcase
		end
		//output
		assign dout = b_reg;

endmodule

