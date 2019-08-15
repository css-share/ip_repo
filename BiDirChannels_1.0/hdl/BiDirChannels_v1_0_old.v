
`timescale 1 ns / 1 ps

// ----------------------------------------------------------------
module dff(
   input clk,
   input rst_n,
   input D,
   output reg Q
  );
 
  always @ (posedge(clk) or negedge(rst_n))
    begin
      if (rst_n == 1'b0)
        Q <= 1'b0;
      else
        Q <= D;
    end
 
endmodule

// ----------------------------------------------------------------
module clock_divider_by_2(
    input clk_in,
    input rst_n,
    output clk_out
  );

  wire Q_int;

  dff ff0(.clk(clk_in),  .rst_n(rst_n),.D(~Q_int),.Q(Q_int));

  assign clk_out = Q_int;

endmodule

// ----------------------------------------------------------------
module counter48Cycles (
  input  wire clock,
  input  wire reset_n,
  input  wire en,
  output wire [5:0] count
);
 
  reg  [5:0] r_reg;
  wire [5:0] r_next;
 
  always @(posedge (clock) or negedge(reset_n))
    begin
      if (reset_n == 1'b0)
        r_reg <= 6'b000000;
      else
	if(en == 1'b0)
          r_reg <= r_reg;
        else
          if(r_reg == 6'b000000)
            r_reg <= 6'b101111;
          else
            r_reg <= r_next;
    end 

  assign count  = r_reg;
  assign r_next = r_reg-1;

endmodule


// ----------------------------------------------------------------
module clock_divider_by_10 (
  input  wire clock,
  input  wire reset_n,
  input  wire en,
  output wire out_clock
);
 
  reg  [3:0] r_reg;
  wire [3:0] r_next;
  reg        out_clock_int;
 
  always @(posedge (clock) or negedge(reset_n))
    begin
      if (reset_n == 1'b0)
      begin
        r_reg <= 4'b0000;
        out_clock_int <= 1'b0;
        end
      else
	if(en == 1'b0)
	begin
          r_reg <= r_reg;
          out_clock_int <= out_clock_int;
          end
        else
          if(r_reg == 4'b0100)
          begin
            out_clock_int <= ~out_clock_int;
            r_reg <= 4'b0000;
            end
          else
          begin
            r_reg <= r_next;
            out_clock_int <= out_clock_int;
            end
    end 

  assign out_clock  = out_clock_int;
  assign r_next = r_reg+1;

endmodule

// ----------------------------------------------------------------
// Date: Feb. 28, 2019
// ----------------------------------------------------------------
module maskHSCK(
  input  clock,
  input  reset_n,
  input  in_start_stop,
  input  out_start_stop,
  input   [5:0] count,
  output        last,
  output        masked_hsck,
  output 	    out_next,
  output 	    in_next,
  output 	    out_shift,
  output 	    in_shift
);

  wire masked_hsck_int;
  wire in_start_stop_int;
  wire out_start_stop_int;


  dff ff0(.clk(last),  .rst_n(reset_n),.D(in_start_stop), .Q(in_start_stop_int));
  dff ff1(.clk(last),  .rst_n(reset_n),.D(out_start_stop),.Q(out_start_stop_int));


  assign mask 	         = ((count[5] & ~count[4]) | ( ~count[5] & (count[4] ^ count[3])));
  assign last            = (~count[5] & ~count[4] & ~count[3] & ~count[2] & ~count[1] & ~count[0]);
  assign masked_hsck_int = (clock & mask);
  assign masked_hsck     = (masked_hsck_int);
  assign out_shift	 = (out_start_stop_int & masked_hsck_int);
  assign in_shift	 = ( in_start_stop_int & masked_hsck_int);
  assign in_next	 = (last & in_start_stop_int);
  assign out_next	 = (last & out_start_stop_int);

endmodule

// ----------------------------------------------------------------
module register_2bits (
  input clock, 
  input reset_n, 
  input [1:0] data_in,
  output reg [1:0] data_out
);

  always @(posedge(clock) or negedge(reset_n)) 
    begin 
      if (reset_n == 1'b0) 
        data_out <= 2'b00; 
      else 
        data_out <= data_in; 
    end 
endmodule

// ----------------------------------------------------------------
module register_4bits (
  input clock, 
  input reset_n, 
  input [3:0] data_in,
  output reg [3:0] data_out
);

  always @(posedge(clock) or negedge(reset_n)) 
    begin 
      if (reset_n == 1'b0) 
        data_out <= 4'b0000; 
      else 
        data_out <= data_in; 
    end 
endmodule

// ----------------------------------------------------------------
module register_16bits (
    input clock, 
    input reset_n, 
    input [15:0] data_in,
    output reg [15:0] data_out
  ); 
 
  always @(posedge(clock) or negedge(reset_n)) 
    begin 
      if (reset_n == 1'b0) 
        data_out <= 16'h0000; 
      else 
        data_out <= data_in; 
    end 
endmodule 


// ----------------------------------------------------------------
module outputShiftRegister32Bits(
  input  shift,
  input  reset_n,
  input  load,
  input  [31:0] d_in,
  output d_out
);

  reg  [32:0] r_reg;
  wire [32:0] r_next;

  always @(posedge(shift) or posedge(load) or negedge(reset_n))
    begin
      if (reset_n == 1'b0)
        r_reg <= 33'b000000000000000000000000000000000;
      else
	if(load == 1'b1)
          r_reg <= {1'b0, d_in};
	else
          r_reg <= r_next;
    end 
 
    assign r_next = {r_reg[31:0], 1'b0};
    assign d_out  = r_reg[32];
 
endmodule

// ----------------------------------------------------------------
// 
// ----------------------------------------------------------------
//  Note: Negative transition.
// ----------------------------------------------------------------
module inputShiftRegister32Bits(
  input  shift,
  input  reset_n,
  input  d_in,
  output [31:0] d_out
);

  reg  [31:0] r_reg;
  wire [31:0] r_next;

  always @(negedge (shift) or negedge (reset_n))
    begin
      if (reset_n == 1'b0)
        r_reg <= 32'h00000000;
      else
        r_reg <= r_next;
    end 
 
  assign r_next = {r_reg[30:0], d_in};
  assign d_out  = r_reg;
 
endmodule

// ----------------------------------------------------------------
module  mux_2x1_1bit(
   input  in0,  // Mux first input
   input  in1,  // Mux Second input
   input  sel,    // Select input
   output wire mux_out // Mux output
);

  assign mux_out = (sel) ? in1 : in0;
endmodule 

// ----------------------------------------------------------------
module  mux_4x1_1bit(
   input  in0,  // Mux first input
   input  in1,  // Mux Second input
   input in2,
   input in3,
   input [1:0] sel,    // Select input
   output wire mux_out // Mux output
);

  assign mux_out = sel[1] ? (sel[0] ? in3 : in2) : (sel[0] ? in1 : in0);
endmodule 

module  mux_8x1_1bit(
   input  in0,  // Mux first input
   input  in1,  // Mux Second input
   input in2,
   input in3,
   input  in4,  // 
   input  in5,  // 
   input in6,
   input in7,
   input [2:0] sel,   // Select input
   output reg mux_out // Mux output
);

always @ (in0 or in1 or in2 or in3 or in4 or in5 or in6 or in7 or sel)
  begin
     case(sel)
       3'b000: mux_out <= in0;
       3'b001: mux_out <= in1;
       3'b010: mux_out <= in2;
       3'b011: mux_out <= in3;
       3'b100: mux_out <= in4;
       3'b101: mux_out <= in5;
       3'b110: mux_out <= in6;
       3'b111: mux_out <= in7;
     endcase  
  end
endmodule

// ----------------------------------------------------------------
module demux_1_to_4(
  input demux_in,
  input [1:0] demux_sel,
  output demux_out_0,
  output demux_out_1,
  output demux_out_2,
  output demux_out_3
);

assign demux_out_0 = (demux_in & ~demux_sel[1] & ~demux_sel[0]);
assign demux_out_1 = (demux_in & ~demux_sel[1] &  demux_sel[0]);
assign demux_out_2 = (demux_in &  demux_sel[1] & ~demux_sel[0]);
assign demux_out_3 = (demux_in &  demux_sel[1] &  demux_sel[0]);

endmodule
 

// ----------------------------------------------------------------
module demux_1_to_8(
  input demux_in,
  input [2:0] demux_sel,
  output demux_out_0,
  output demux_out_1,
  output demux_out_2,
  output demux_out_3,
  output demux_out_4,
  output demux_out_5,
  output demux_out_6,
  output demux_out_7
);

assign demux_out_0 = (demux_in & ~demux_sel[2] & ~demux_sel[1] & ~demux_sel[0]);
assign demux_out_1 = (demux_in & ~demux_sel[2] & ~demux_sel[1] &  demux_sel[0]);
assign demux_out_2 = (demux_in & ~demux_sel[2] &  demux_sel[1] & ~demux_sel[0]);
assign demux_out_3 = (demux_in & ~demux_sel[2] &  demux_sel[1] &  demux_sel[0]);
assign demux_out_4 = (demux_in &  demux_sel[2] & ~demux_sel[1] & ~demux_sel[0]);
assign demux_out_5 = (demux_in &  demux_sel[2] & ~demux_sel[1] &  demux_sel[0]);
assign demux_out_6 = (demux_in &  demux_sel[2] &  demux_sel[1] & ~demux_sel[0]);
assign demux_out_7 = (demux_in &  demux_sel[2] &  demux_sel[1] &  demux_sel[0]);

endmodule
 
// ----------------------------------------------------------------
module register_32bits (
    input clock, 
    input reset_n, 
    input [31:0] data_in,
    output reg [31:0] data_out
  ); 
 
  always @(posedge(clock) or negedge(reset_n)) 
    begin 
      if (reset_n == 1'b0) 
        data_out <= 32'h00000000; 
      else 
        data_out <= data_in; 
    end 
endmodule 

// ----------------------------------------------------------------
//
// -----------------------------------------------------------------------

module syncReady (
  input  clk,
  input  rst_n,
  input  next,
  output ready
);

  wire a;
  wire b;

  dff X0( .clk(clk), .rst_n(rst_n), .D(next), .Q(a));
  dff X1( .clk(clk), .rst_n(rst_n), .D(a),    .Q(b));

  assign ready = (next & (a ^ b));

endmodule

module upCounter3Bits (
    input  wire clock,
    input  wire reset_n,
    input  wire enable,
    output wire [2:0] count
  );
 
  reg  [2:0] r_reg;
  wire [2:0] r_next;
  
  always @(posedge (clock) or negedge(reset_n))
    begin
      if (reset_n == 1'b0)
        r_reg <= 3'b000;
      else
        if(enable == 1'b0)
          r_reg <= r_reg;
        else
          r_reg <= r_next;
    end
  
    assign count  = r_reg;
    assign r_next = r_reg + 1;
  
endmodule

module upCounter8Bits (
    input  wire clock,
    input  wire reset_n,
    input  wire enable,
    output wire [7:0] count
  );
 
  reg  [7:0] r_reg;
  wire [7:0] r_next;
  
  always @(posedge (clock) or negedge(reset_n))
    begin
      if (reset_n == 1'b0)
        r_reg <= 8'h00;
      else
        if(enable == 1'b0)
          r_reg <= r_reg;
        else
          r_reg <= r_next;
    end
  
    assign count  = r_reg;
    assign r_next = r_reg + 1;
  
endmodule

module upCounter12Bits (
    input  wire clock,
    input  wire reset_n,
    input  wire enable,
    output wire [11:0] count
  );
 
  reg  [11:0] r_reg;
  wire [11:0] r_next;
  
  always @(posedge (clock) or negedge(reset_n))
    begin
      if (reset_n == 1'b0)
        r_reg <= 12'h000;
      else
        if(enable == 1'b0)
          r_reg <= r_reg;
        else
          r_reg <= r_next;
    end
  
    assign count  = r_reg;
    assign r_next = r_reg + 1;
  
endmodule

module GyroChannelDebugger(
    input reset_n,
    input debug_clear,
    input next,
    input valid,
    input tx_ready,
    input rx_valid,
    output [31:0] debug_word_0,
    output [31:0] debug_word_1
  );

  // -----------------------------------------------------

  wire [7:0] data0_int;
  wire [7:0] data1_int;
  wire [7:0] data2_int;
  wire [7:0] data3_int;

  // -----------------------------------------------------

  upCounter8Bits CNTR0(.clock(next),    .reset_n(reset_n & ~debug_clear),  .enable(1'b1),.count(data0_int));
  upCounter8Bits CNTR1(.clock(tx_ready),.reset_n(reset_n & ~debug_clear),  .enable(1'b1),.count(data1_int));
  upCounter8Bits CNTR2(.clock(valid),   .reset_n(reset_n & ~debug_clear),  .enable(1'b1),.count(data2_int));
  upCounter8Bits CNTR3(.clock(rx_valid),.reset_n(reset_n & ~debug_clear),  .enable(1'b1),.count(data3_int));

  assign debug_word_0 = { data0_int, data1_int, data2_int, data3_int };
  assign debug_word_1 = { 32'h00000000 };
  
endmodule

module packet_size_logic(
  input [11:0] count,
  input [2:0] size_sel,
  output last_count
);
  
  
wire size0;
wire size1;
wire size2;
wire size3;
wire size4;
wire size5;
wire size6;
wire size7;

 assign size0 = (count[0] & count[1] & count[2] & count[3] & count[4]);
 assign size1 = (count[0] & count[1] & count[2] & count[3] & count[4] & count[5]);
 assign size2 = (count[0] & count[1] & count[2] & count[3] & count[4] & count[5] & count[6]);
 assign size3 = (count[0] & count[1] & count[2] & count[3] & count[4] & count[5] & count[6] & count[7]);
 assign size4 = (count[0] & count[1] & count[2] & count[3] & count[4] & count[5] & count[6] & count[7] & count[8]);
 assign size5 = (count[0] & count[1] & count[2] & count[3] & count[4] & count[5] & count[6] & count[7] & count[8] & count[9]);
 assign size6 = (count[0] & count[1] & count[2] & count[3] & count[4] & count[5] & count[6] & count[7] & count[8] & count[9] & count[10]);
 //assign size7 = (count[0] & count[1] & count[2] & count[3] & count[4] & count[5] & count[6] & count[7] & count[8] & count[9] & count[10] & count[11]);
 assign size7 = ( count[2] & count[3] & count[4] & count[5] & count[6] & count[7] & count[8] & count[9] & count[10] & count[11]);
  
 mux_8x1_1bit packet_size_mux(
    .in0(size0),
    .in1(size1),
    .in2(size2),
    .in3(size3),
    .in4(size4), 
    .in5(size5),
    .in6(size6),
    .in7(size7),
    .sel(size_sel),  
    .mux_out(last_count)
 );
 

endmodule
// ----------------------------------------------------------------

module GyroInputOutputSerializer (
  input  clock, 
  input  reset_n,
  input  enable,
  input  hsi_enable,
  input  debug_clear,
  input  in_start_stop,		// control the in-bound channel
  input  out_start_stop,	// controls the out-bound channel
  input  [1:0] mode,		// 00: normal operation; 01: loopback
  input  [3:0] clock_div,   // 000: no division, 001: div by 2; 010: div by 4; 011: div by 8; 100: div by 16 ...
  input  [2:0] packet_sel,  // 000: 64 samples, 001: 128 samples ... 111: 8192 samples
  input  [2:0] in_channel,
  input  [2:0] out_channel,
  input  HSCK_POL,		// 0: HSCK rest at 0, 1: HSCK rest at 1.
  output  HSI_DBM,
  output  HSI_DBP,
  output  HSI_DAM,
  output  HSI_DAP,
  output  HSI_DC,

  input  [31:0] tx_fifo_data,
  input         tx_fifo_valid,
  output        tx_fifo_ready,
  input         tx_fifo_last,

  output [31:0] rx_fifo_data,
  output        rx_fifo_valid,
  input         rx_fifo_ready,
  output        rx_fifo_last,

  input  HSI_A0,
  input  HSI_A1,
  
  output HSCK,      // High Speed Interface Clock
  output MCK,       // 50 MHz clock - Master Clock
  output SYNCK,     // 10 MHz clock for waveform synchronization
  
  output [31:0] data_word_0,
  output [31:0] data_word_1
);

  // --- 
  wire HS_DATA_IN_delayed;
  
  wire clock_div_2;
  wire clock_div_4;
  wire [1:0] mode_int;

  wire in_next_int;
  wire out_next_int;

  wire tx_fifo_ready_int;
  wire rx_fifo_valid_int;
  wire rx_fifo_last_int;
  wire rx_fifo_last_delayed;

  wire last_int;
  wire masked_hsck_int;
  
  wire clock_base;
  wire clock_base_2;
  wire clock_base_4;
  wire clock_base_8;
  wire clock_base_16;
  wire clock_base_32;
  wire clock_base_64;
  wire clock_base_128;
  wire clock_base_256;

  wire hs_data_out_int;
  wire inSR_shift;
  wire inSR_shift_delayed;
  wire outSR_shift;
  wire hs_data_in_int;
  //wire masked_in_hsck_int;
  wire [5:0] count_pulses;
  wire [11:0] last_count_int;
  
  wire [31:0] rx_fifo_data_int;
  wire [31:0] tx_fifo_data_delayed;
  
  wire HS_DATA_IN_int;
  wire hs_data_out_0_int;
  wire hs_data_out_1_int;
  wire hs_data_out_2_int;
  wire hs_data_out_3_int;
  wire hs_data_out_4_int;
  wire hs_data_out_5_int;
  wire hs_data_out_6_int;
  wire hs_data_out_7_int;
  
  wire last_count_mux;

clock_divider_by_10 SYNC_CLK_DIV (
  .clock(clock),
  .reset_n(reset_n),
  .en(1'b1),
  .out_clock(SYNCK)
);

 upCounter8Bits CLK_DIV_CNTR(
      .clock(clock),
      .reset_n(reset_n),
      .enable(1'b1),
     .count({clock_base_256, clock_base_128, clock_base_64, clock_base_32, clock_base_16,clock_base_8, clock_base_4, clock_base_2})
  );
  
   mux_8x1_1bit          baseClockMux(
     .in0(clock),
     .in1(clock_base_2),
     .in2(clock_base_4),
     .in3(clock_base_8),
     .in4(clock_base_16),
     .in5(clock_base_32),
     .in6(clock_base_64),
     .in7(clock_base_128),
     .sel(clock_div),
     .mux_out(clock_base)
   );
  
  clock_divider_by_2 CLK_DIV2(
    .clk_in(clock_base),
    .rst_n(reset_n),
    .clk_out(clock_div_2)
  );

  clock_divider_by_2 CLK_DIV4(
    .clk_in(clock_div_2),
    .rst_n(reset_n),
    .clk_out(clock_div_4)
  );

  register_2bits STATE_REG(
    .clock(~clock_div_4),
    .reset_n(reset_n),
    .data_in(mode),
    .data_out(mode_int)
  );

  counter48Cycles PULSE_CNTR(
    .clock(~clock_div_4),
    .reset_n(reset_n),
    .en(1'b1),
    .count(count_pulses)
  );

 upCounter12Bits LAST_CNTR(
    .clock(rx_fifo_valid_int),
    .reset_n(reset_n),
    .enable(1'b1),
    .count(last_count_int)
  );
 
  maskHSCK MASK_HSCK(
    .clock(clock_div_4),
    .reset_n(reset_n),
    .in_start_stop(in_start_stop),
    .out_start_stop(out_start_stop),
    .count(count_pulses),
    .last(last_int),
    .masked_hsck(masked_hsck_int),
    .out_shift(outSR_shift),
    .in_shift(inSR_shift),
    .out_next(out_next_int),
    .in_next(in_next_int)
  );

 dff X10( .clk(clock), .rst_n(reset_n), .D(rx_fifo_last_int), .Q(rx_fifo_last_delayed));
 dff X20( .clk(clock_div_2), .rst_n(reset_n), .D(inSR_shift), .Q(inSR_shift_delayed));
  
  mux_4x1_1bit IN_MUX(
    .in0(HSI_A0),  // Mux first input
    .in1(HSI_A1),  // Mux Second input
    .in2(1'b0),
    .in3(1'b0),
    .sel(in_channel[1:0]),    // Select input
    .mux_out(HS_DATA_IN_int) // Mux output
 );

 // ----------------------------------------------------------------
 demux_1_to_8 OUT_DEMUX(
   .demux_in(hs_data_out_int),
   .demux_sel(out_channel[2:0]),
   .demux_out_0(hs_data_out_0_int),
   .demux_out_1(hs_data_out_1_int),
   .demux_out_2(hs_data_out_2_int),
   .demux_out_3(hs_data_out_3_int),
   .demux_out_4(hs_data_out_4_int),
   .demux_out_5(hs_data_out_5_int),
   .demux_out_6(hs_data_out_6_int),
   .demux_out_7(hs_data_out_7_int)
 );
 
 //register_32bits TX_DELAY_REG(
 //   .clock(clock), 
//    .reset_n(reset_n), 
//    .data_in(tx_fifo_data),
//    .data_out(tx_fifo_data_delayed)
//  ); 
 
  inputShiftRegister32Bits IN_SHIFT_REG(
    .shift(inSR_shift_delayed),
    .reset_n(reset_n),
    .d_in(hs_data_in_int),
    .d_out(rx_fifo_data_int)
  );

 outputShiftRegister32Bits OUT_SHIFT_REG(
    .shift(outSR_shift),
    .reset_n(reset_n),
    .load(tx_fifo_ready_int & tx_fifo_valid),
    .d_in(tx_fifo_data),
    //.d_in(tx_fifo_data_delayed),
    .d_out(hs_data_out_int)
  );
    
  mux_2x1_1bit          loopbackMux(
    .in0(HS_DATA_IN_int),
    .in1(hs_data_out_int),
    .sel(mode[0]),
    .mux_out(hs_data_in_int)
  );

  syncReady X0(
    .clk(~clock),  
    .rst_n(reset_n), 
    .next(out_next_int), 
    .ready(tx_fifo_ready_int)
  );
  
    syncReady X1(
    .clk(~clock), 
    .rst_n(reset_n), 
    .next(in_next_int), 
    .ready(rx_fifo_valid_int)
  );
  
  GyroChannelDebugger DBG(
      .reset_n(reset_n),
      .debug_clear(debug_clear),
      .next(out_next_int),
      .valid(in_next_int),
      .tx_ready(tx_fifo_ready_int),
      .rx_valid(rx_fifo_valid_int),
      .debug_word_0(data_word_0),
      .debug_word_1(data_word_1)
    );

 packet_size_logic PACKET_LOGIC(
   .count(last_count_int),
   .size_sel(packet_sel),
   .last_count(last_count_mux)
 );
   
  assign HSCK              = ((masked_hsck_int ^ HSCK_POL)& enable & hsi_enable);
  assign HSI_DAP    = (hs_data_out_0_int & enable & hsi_enable);
  assign HSI_DAM    = (hs_data_out_1_int & enable & hsi_enable);
  assign HSI_DBP    = (hs_data_out_2_int & enable & hsi_enable);
  assign HSI_DBM    = (hs_data_out_3_int & enable & hsi_enable);
  assign HSI_DC     = (hs_data_out_4_int & enable & hsi_enable);
  assign MCK               = (clock_div_2 & enable);

  //assign rx_fifo_last_int = (last_count_int[0] & last_count_int[1] & last_count_int[2] & last_count_int[3] & last_count_int[4] & last_count_int[5] & last_count_int[6] & last_count_int[7]);
  assign rx_fifo_last_int = last_count_mux;
  assign tx_fifo_ready  = tx_fifo_ready_int;
  assign rx_fifo_valid  = rx_fifo_valid_int;
  assign rx_fifo_last   = rx_fifo_last_delayed;
  assign rx_fifo_data   = rx_fifo_data_int;

endmodule

// #####################################################################

	module BiDirChannels_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4,

		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M00_AXIS_START_COUNT	= 32
	)
	(
		// Users to add ports here
        input  wire HSI_A0,
        input  wire HSI_A1,

        output wire HSI_DBM,
        output wire HSI_DBP,
        output wire HSI_DAM,
        output wire HSI_DAP,
        
        output wire HSI_DC,
        
        output wire HS_Clock,
        output wire MCK_P,
        output wire MCK_N,
        output wire SYNCK,
		// User ports ends

		// Ports of Axi Slave Bus Interface S00_AXI
		
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,

		// Ports of Axi Slave Bus Interface S00_AXIS
		// from TxFIFO
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid,

		// Ports of Axi Master Bus Interface M00_AXIS
		// to RxFIFO
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready
	);
	
	// --- Local wires for connection between AXI-LITE and other modules
	
	wire [31:0] data_word_0;
	wire [31:0] data_word_1;
	wire [31:0] data_word_2;
    wire [31:0] debug_word_0;
    wire [31:0] debug_word_1;
    
    wire MCK;
	
    // Instantiation of Axi Bus Interface S00_AXI
	BiDirChannels_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) BiDirChannels_v1_0_S00_AXI_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),
		.DATA_WORD_0(data_word_0),
		.DATA_WORD_1(data_word_1),
		.DATA_WORD_2(data_word_2),
		.DATA_WORD_3(debug_word_1)
	);

// Instantiation of Axi Bus Interface S00_AXIS
//	BiDirChannels_v1_0_S00_AXIS # ( 
//		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH)
//	) BiDirChannels_v1_0_S00_AXIS_inst (
//		.S_AXIS_ACLK(s00_axis_aclk),
//		.S_AXIS_ARESETN(s00_axis_aresetn),
//		.S_AXIS_TREADY(s00_axis_tready),
//		.S_AXIS_TDATA(s00_axis_tdata),
//		.S_AXIS_TSTRB(s00_axis_tstrb),
//		.S_AXIS_TLAST(s00_axis_tlast),
//		.S_AXIS_TVALID(s00_axis_tvalid)
//	);

// Instantiation of Axi Bus Interface M00_AXIS
//	BiDirChannels_v1_0_M00_AXIS # ( 
//		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
//		.C_M_START_COUNT(C_M00_AXIS_START_COUNT)
//	) BiDirChannels_v1_0_M00_AXIS_inst (
//		.M_AXIS_ACLK(m00_axis_aclk),
//		.M_AXIS_ARESETN(m00_axis_aresetn),
//		.M_AXIS_TVALID(m00_axis_tvalid),
//		.M_AXIS_TDATA(m00_axis_tdata),
//		.M_AXIS_TSTRB(m00_axis_tstrb),
//		.M_AXIS_TLAST(m00_axis_tlast),
//		.M_AXIS_TREADY(m00_axis_tready)
//	);

	// Add user logic here
  // ------------------------------------------
  
    GyroInputOutputSerializer X1(
      .clock(s00_axi_aclk),
      .reset_n(s00_axi_aresetn & ~data_word_0[31]),
      .enable(data_word_2[0]),
      .hsi_enable(data_word_2[4]),
      .debug_clear(data_word_0[31]),
      .HSCK_POL(data_word_0[28]),
      .mode(data_word_0[25:24]),
      .clock_div(data_word_0[19:16]),
      .packet_sel(data_word_0[14:12]),
      .in_channel(data_word_0[6:4]),
      .out_channel(data_word_0[2:0]),
      .in_start_stop(data_word_1[4]),
      .out_start_stop(data_word_1[0]),
      .tx_fifo_data(s00_axis_tdata),
      .tx_fifo_ready(s00_axis_tready),
      .tx_fifo_valid(s00_axis_tvalid),
      .tx_fifo_last(s00_axis_tlast),
      .rx_fifo_data(m00_axis_tdata),
      .rx_fifo_ready(m00_axis_tready),
      .rx_fifo_valid(m00_axis_tvalid),
      .rx_fifo_last(m00_axis_tlast),
      .HSI_DBM(HSI_DBM),
      .HSI_A0(HSI_A0),
      .HSI_DBP(HSI_DBP),
      .HSI_A1(HSI_A1),
      .HSI_DAM(HSI_DAM),
      .HSI_DAP(HSI_DAP),
      .HSI_DC(HSI_DC),
      .HSCK(HS_Clock),
      .MCK(MCK),
      .SYNCK(SYNCK),
      .data_word_0(debug_word_0),
      .data_word_1(debug_word_1)
    );
    
    OBUFDS #(
      .IOSTANDARD("DEFAULT")
    ) OBUFDS_inst (
      .O(MCK_P),
      .OB(MCK_N),
      .I(MCK)
    );

    assign m00_axis_tstrb = 4'b1111;
	// User logic ends

	endmodule
