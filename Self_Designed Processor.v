// Top module for part1
module part1
(
	input Clock,
	input Resetn,
	input Run,
	input [8:0] DIN,
	output [8:0] Bus,
	output Done,
	// For debugging
	output [8:0] reg_IR,
	output [8:0] reg_0,
	output [8:0] reg_1,
	output [8:0] reg_A,
	output [8:0] reg_G
);
// Module starts

	// Instantiating processor module.
	processor proc_under_test
	(
		Clock,
		Resetn,
		Run,
		DIN,
		Bus,
		Done,
		reg_IR,
		reg_0,
		reg_1,
		reg_A,
		reg_G
	);


// Module ends
endmodule
/*********************************************************/

// Processor module
module processor
(
	input clk,
	input reset_n,
	input run,
	input [8:0] d_in,
	output reg [8:0] bus,
	output reg done,
	// For debugging
	output [8:0] reg_IR,
	output [8:0] reg_0,
	output [8:0] reg_1,
	output [8:0] reg_A,
	output [8:0] reg_G
);
// Module starts
	
	//--------------------------------------------------
	/***PROCESSOR DATA REGISTERS***/
	reg [8:0] data_reg[7:0];
	// For debugging:
	assign reg_0 = data_reg[0];
	assign reg_1 = data_reg[1];
	
	//--------------------------------------------------
	/***INSTR. AND ALU REGISTERS***/
	reg [8:0] instr_reg, alu_reg_A, alu_reg_G;
	// For debugging
	assign reg_IR = instr_reg;
	assign reg_A = alu_reg_A;
	assign reg_G = alu_reg_G;
	
	//--------------------------------------------------
	/***CONTROL SIGNALS***/
	reg [7:0] data_reg_sel,
				  data_reg_in;
	reg instr_reg_in,
		 alu_reg_A_in,
		 alu_reg_G_in,
		 alu_reg_G_sel,
		 d_in_sel,
		 add_sub;
	
	//--------------------------------------------------
	/***CONVENIENCE SIGNALS***/
	wire mvi_instr,
		  mv_instr,
		  add_instr,
		  sub_instr;
		  
	wire [2:0] instr,
				  reg_x,
				  reg_y;
				  
	wire [7:0] one_hot_x,
				  one_hot_y;
	  
	assign instr = instr_reg[8:6];
	assign reg_x = instr_reg[5:3];
	assign reg_y = instr_reg[2:0];
	
	assign mv_instr = (instr == 3'b000);
	assign mvi_instr = (instr == 3'b001);
	assign add_instr = (instr == 3'b010);
	assign sub_instr = (instr == 3'b011);
	
	bin_to_one_hot one_hot_1(reg_x, one_hot_x);
	bin_to_one_hot one_hot_2(reg_y, one_hot_y);
	
	
	//--------------------------------------------------
	/***LOOP COUNTERS***/
	integer l1;
	
	//--------------------------------------------------
	/***CONTROL FSM***/
	// State encoding:
	parameter [1:0] LOAD = 2'b00,
						 EXE1 = 2'b01,
						 EXE2 = 2'b10,
						 EXE3 = 2'b11;
	
	// Present and next state variables
	reg [1:0] p_state, n_state;
	
	// State transitions
	always @(posedge clk, negedge reset_n)
	begin
		if (!reset_n)
			p_state <= LOAD;
		else
			p_state <= n_state;
	end
	
	// Next state + output logic
	always @(*)
	begin
		case (p_state)
		LOAD:
			begin
				// Next state logic
				if (run)
					n_state = EXE1;
				else
					n_state = LOAD;
				
				// Output logic
				done = 1'b0;
				data_reg_sel = 8'b0;
				data_reg_in = 8'b0;
				instr_reg_in = 1'b1;// IRin
				alu_reg_A_in = 1'b0;
				alu_reg_G_in = 1'b0;
				alu_reg_G_sel = 1'b0;
				d_in_sel = 1'b0;
				add_sub = 1'b0;
			end
			
		EXE1:
			begin
				// Next state logic
				if (mv_instr | mvi_instr)
					n_state = LOAD;
				else
					n_state = EXE2;
					
				// Output logic
				if (mv_instr)
				begin
					done = 1'b1;// Done
					data_reg_sel = one_hot_y;// RY_out
					data_reg_in = one_hot_x;// RX_in
					instr_reg_in = 1'b0;
					alu_reg_A_in = 1'b0;
					alu_reg_G_in = 1'b0;
					alu_reg_G_sel = 1'b0;
					d_in_sel = 1'b0;
					add_sub = 1'b0;
				end
				else if (mvi_instr)
				begin
					done = 1'b1;// Done
					data_reg_sel = 8'b0;
					data_reg_in = one_hot_x;// RX_in
					instr_reg_in = 1'b0;
					alu_reg_A_in = 1'b0;
					alu_reg_G_in = 1'b0;
					alu_reg_G_sel = 1'b0;
					d_in_sel = 1'b1;// DIN_out 
					add_sub = 1'b0;
				end
				else //if (add_instr | sub_instr)
				begin
					done = 1'b0;
					data_reg_sel = one_hot_x;// RX_out
					data_reg_in = 8'b0;
					instr_reg_in = 1'b0;
					alu_reg_A_in = 1'b1;// A_in
					alu_reg_G_in = 1'b0;
					alu_reg_G_sel = 1'b0;
					d_in_sel = 1'b0;
					add_sub = 1'b0;
				end
			end
			
		EXE2:
			begin
				// Next state logic
				n_state = EXE3;
				
				// Output logic
				done = 1'b0;
				data_reg_sel = one_hot_y;// RY_out
				data_reg_in = 8'b0;
				instr_reg_in = 1'b0;
				alu_reg_A_in = 1'b0;
				alu_reg_G_in = 1'b1;// G_in
				alu_reg_G_sel = 1'b0;
				d_in_sel = 1'b0;
				
				if (add_instr)
					add_sub = 1'b0;
				else // if (sub_instr)
					add_sub = 1'b1;// AddSub
					
			end
			
		EXE3:
			begin
				// Next state logic
				n_state = LOAD;
				
				// Output logic
				done = 1'b1;// Done
				data_reg_sel = 1'b0;
				data_reg_in = one_hot_x;// RX_in
				instr_reg_in = 1'b0;
				alu_reg_A_in = 1'b0;
				alu_reg_G_in = 1'b0;
				alu_reg_G_sel = 1'b1;// G_out
				d_in_sel = 1'b0;
				add_sub = 1'b0;
			end
		
		endcase
	end
	
	//--------------------------------------------------
	/***INSTRUCTION REGISTER***/
	always @(posedge clk, negedge reset_n)
	begin
		if(!reset_n)
			instr_reg <= 0;
		else if(instr_reg_in)
			instr_reg <= d_in;
	end
	
	//--------------------------------------------------
	/***ALU AND ALU REGISTERS***/
	always @(posedge clk, negedge reset_n)
	begin
		if(!reset_n)
		begin
			alu_reg_A <= 0;
			alu_reg_G <= 0;
		end
		else
		begin
			if(alu_reg_A_in)
				alu_reg_A <= bus;
				
			if(alu_reg_G_in & add_sub)
				alu_reg_G <= alu_reg_A - bus;
			else if (alu_reg_G_in & ~add_sub)
				alu_reg_G <= alu_reg_A + bus;
		end
	end
	
	//--------------------------------------------------
	/***DATA REGISTERS***/
	always @(posedge clk, negedge reset_n)
	begin
		for (l1=0; l1<8; l1=l1 + 1)
		begin
			if(!reset_n)
				data_reg[l1] <= 0;
			else if(data_reg_in[l1])
				data_reg[l1] <= bus;
		end
	end
	
	//--------------------------------------------------
	/***MULTIPLEXERS***/
	always @(*)
	begin
		case ({data_reg_sel, alu_reg_G_sel, d_in_sel})
			10'b10000_00000: bus = data_reg[7];
			10'b01000_00000: bus = data_reg[6];
			10'b00100_00000: bus = data_reg[5];
			10'b00010_00000: bus = data_reg[4];
			10'b00001_00000: bus = data_reg[3];
			10'b00000_10000: bus = data_reg[2];
			10'b00000_01000: bus = data_reg[1];
			10'b00000_00100: bus = data_reg[0];
			10'b00000_00010: bus = alu_reg_G;
			10'b00000_00001: bus = d_in;
			default: bus = 0;
		endcase
	end
	
// Module ends
endmodule
/*********************************************************/

// Binary to one_hot converter
module bin_to_one_hot
#(
	parameter N = 3,
	parameter N2 = 1 << N
)
(
	input [N-1:0] bin,
	output reg [N2-1:0] one_hot
);
// Module begin
	
	integer i;
	always @(*)
	begin
		for (i=0; i<N2; i=i+1)
		begin
			if(i==bin)
				one_hot[i]=1'b1;
			else
				one_hot[i]=1'b0;
		end
	end

// Module ends
endmodule 
/*********************************************************/












