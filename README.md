# Minimal-Core-Self-Designed-Processor-using-Verilog-HDL
This repository contains the verilog code, testbench and Simulation waveform of a customized processor with limited functionality and fixed set of instructions. This project was designed in Altera's Quartus Prime using Verilog HDL.

# Basic Understanding and Design Methodology
The digital circuit for the customized processor is shown below:
![image](https://github.com/user-attachments/assets/fb7df806-968b-4e45-8959-3d03c00e8c0e)

- The digital system comprises of nine-bit registers, a multiplexer, an adder/subtractor unit, and a control unit (finite state machine). Data is input to this system via the nine-bit DIN input. This data
can be loaded through the nine-bit wide multiplexer into the various registers, such as R0-R7 and A. The multiplexer also allows data to be transferred from one register to another. The multiplexer’s output wires are called a bus. 
- Addition or subtraction of signed numbers is performed using the multiplexer to first place one nine-bit number onto the bus wires and loading this number into register A. Once this is done, a second nine-bit number is placed onto the bus, the adder/subtractor unit performs the required operation, and the result is loaded into register G.The data in G can then be transferred to one of the other registers as required. 
- The system can perform different operations in each clock cycle, as governed by the control unit. This unit determines when particular data is placed onto the bus wires and it controls which of the registers is to be loaded with this data.
- The instructions supported by the processor are following:
  
  ![image](https://github.com/user-attachments/assets/e27860b0-85e5-4c48-ad7b-d1367d8d1e6a)
  
- Each instruction can be encoded using the nine-bit format IIIXXXYYY, where III specifies the instruction, XXX gives the Rx register, and YYY gives the Ry register.
- For the instructions which require more than one clock cycle, a FSM in the control unit be designed.The processor starts executing the instruction on the DIN input when the Run signal is asserted and the processor
asserts the Done output when the instruction is finished.

# Files:
- [Self-designed Processor.v](https://github.com/GithubAamna/Minimal-Core-Self-Designed-Processor-using-Verilog-HDL/blob/main/Self_Designed%20Processor.v) 
- [TestBench.v](https://github.com/GithubAamna/Minimal-Core-Self-Designed-Processor-using-Verilog-HDL/blob/main/TestBench.v)
- [Simulation Waveform.png](https://github.com/GithubAamna/Minimal-Core-Self-Designed-Processor-using-Verilog-HDL/blob/main/Simulation%20Waveform.png)

