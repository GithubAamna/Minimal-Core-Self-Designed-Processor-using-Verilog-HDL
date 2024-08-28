`timescale 1ns/1ns
// Test
module part1_tb;
// Testbench begin
	
	// Declaring inputs as type reg
	reg Clock, Resetn, Run;
	reg [8:0] DIN;
	
	// Declaring outputs of type wire
	wire [8:0] Bus, reg_IR, reg_0, reg_1, reg_A, reg_G;
	wire Done;

	// Instantiating module under test
	part1 part1_under_test
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
	
	// Providing clock
	initial
	begin
		Clock = 0;
		forever
		begin
			#10; Clock = ~Clock;
		end
	end
	
	// Providing stimulus according to Figure 2
	initial
	begin
		// 0-20ns Reset
		Resetn = 0;
		Run = 0;
		DIN = 0;
		#20;
		
		// mvi instruction
		Resetn = 1;
		Run = 1;
		DIN = 9'o100;
		#20;
		Run = 0;
		DIN = 9'o005;
		#20;
		
		// mv instruction
		Run = 1;
		DIN = 9'o010;
		#20;
		Run = 0;
		#20;
		
		// add instruction
		Run = 1;
		DIN = 9'o201;
		#20;
		Run = 0;
		#60;
		
		// sub instruction
		Run = 1;
		DIN = 9'o300;
		#20;
		Run = 0;
		#60;
		
	end

// Testbench end
endmodule

