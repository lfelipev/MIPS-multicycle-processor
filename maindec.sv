module maindec(input logic clk, reset,
                input logic [5:0] op,
                output logic memtoreg, memwrite,
                output logic branch, alusrca,
                output logic[1:0] alusrcb,
                output logic regdst, regwrite,
                output logic IorD,
                output logic irwrite, pcwrite,
                output logic [1:0] pcsrc, aluop);

  logic [14:0] controls;
  logic [3:0] state, nextstate;
  initial state = 4'b0000;
  
  parameter S0 = 4'b0000;
  parameter S1 = 4'b0001;
  parameter S2 = 4'b0010;
  parameter S3 = 4'b0011;
  parameter S4 = 4'b0100;
  parameter S5 = 4'b0101;
  
  parameter S6 = 4'b0110;
  parameter S7 = 4'b0111;
  parameter S8 = 4'b1000;
  parameter S9 = 4'b1001;
  parameter S10 = 4'b1010;
  parameter S11 = 4'b1011;
  
  assign {memtoreg, memwrite, branch, alusrca, alusrcb, regdst, regwrite, IorD, irwrite, pcwrite, pcsrc, aluop} = controls;
  always_ff @(posedge clk, reset)
    if(reset)
      state <= S0;
    else
      state <= nextstate;
  
  always_comb
    case(state)
      S0: nextstate <= S1;
      S1:
        case(op)
          6'b000000: nextstate <= S6;// s6 R-Type 
          6'b100011: nextstate <= S2; // s2 lw
          6'b101011: nextstate <= S2; // s2 sw
          6'b000100: nextstate <= S8; // s8 beq
          6'b001000: nextstate <= S9;// s9 addi
          6'b000010: nextstate <= S11; // s11 j
          default:  nextstate <= S0; // opcode invalido  * inserir exceção *    
        endcase 
      S2:
      begin
        case(op)
          6'b100011: nextstate <= S3; // lw - s3
          6'b101011: nextstate <= S5; // sw - s5
        endcase
      end
      
      S3: nextstate <= S4; // s3 -> s4
      S4: nextstate <= S0; // s4 -> s0
      S5: nextstate <= S0; // s5 -> s0
      S6: nextstate <= S7; // s6 -> s7
      S7: nextstate <= S0; // s7 -> s0
      S8: nextstate <= S0; // s8 -> s0
      S9: nextstate <= S10; // s9 -> s10
      S10: nextstate <= S0; // s10 -> s0
      S11: nextstate <= S0; // s11 - > s0
      
      default: nextstate <= S0;
    endcase 
    
  always_comb
    begin
      case(state) 
	      // memtoreg, memwrite, branch, alusrca, alusrcb, regdst, regwrite, IorD, irwrite, pcwrite, pcsrc, aluop
	      S0: controls <= 15'b000_001_000_110_000;   
	      S1: controls <= 15'b000_011_000_000_000; 
	      S2: controls <= 15'b000_110_000_000_000;
	      S3: controls <= 15'b000_000_001_000_000;
	      S4: controls <= 15'b100_000_010_000_000;
	      S5: controls <= 15'b010_000_001_000_000;
	      S6: controls <= 15'b000_100_000_000_010;
	      S7: controls <= 15'b000_000_110_000_000;
	      S8: controls <= 15'b001_100_000_000_101;
	      S9: controls <= 15'b000_110_000_000_000;
	      S10: controls <= 15'b000_000_010_000_000;
	      S11: controls <= 15'b000_110_000_011_000;
	      default: controls <= 15'b000_001_000_110_000;
      endcase 
    end
endmodule

