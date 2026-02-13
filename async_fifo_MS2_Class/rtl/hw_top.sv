`include "synchronizer.sv"
`include "wptr_handler.sv"
`include "rptr_handler.sv"
`include "fifo_mem.sv"

module asynchronous_fifo #(parameter DEPTH=512, DATA_WIDTH=8) (
  input logic wclk, wrst_n,
  input logic rclk, rrst_n,
  input logic w_en, r_en,
  input logic [DATA_WIDTH-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic full, empty, full_3_4, empty_1_4
);
  
  parameter PTR_WIDTH = $clog2(DEPTH);
 
  logic [PTR_WIDTH:0] g_wptr_sync, g_rptr_sync;
  logic [PTR_WIDTH:0] b_wptr_sync, b_rptr_sync;
  logic [PTR_WIDTH:0] b_wptr, b_rptr;
  logic [PTR_WIDTH:0] g_wptr, g_rptr;

  wire [PTR_WIDTH-1:0] waddr, raddr;

  // synchronizes the wptr in read domain clock
  // input logic clk, rst_n,
  // input logic [WIDTH:0] g_in, b_in,
  // output logic [WIDTH:0] g_out, b_out, 
  synchronizer #(PTR_WIDTH) sync_wptr (
    .clk(rclk), 
    .rst_n(rrst_n), 
    .g_in(g_wptr), 
    .b_in(b_wptr),
    .g_out(g_wptr_sync),
    .b_out(b_wptr_sync)
  ); 

  //synchronizes the rptr in write domain clock
  synchronizer #(PTR_WIDTH) sync_rptr (
    .clk(wclk), 
    .rst_n(wrst_n), 
    .g_in(g_rptr),
    .b_in(b_rptr), 
    .g_out(g_rptr_sync),
    .b_out(b_rptr_sync)
  );
  
  // input logic wclk, wrst_n, w_en,
  // input logic [PTR_WIDTH:0] g_rptr_sync, b_rptr_sync,
  // output logic [PTR_WIDTH:0] b_wptr, g_wptr,
  // output logic full, full_3_4

  wptr_handler #(PTR_WIDTH) wptr_h(
    .wclk, 
    .wrst_n, 
    .w_en,
    .g_rptr_sync,
    .b_rptr_sync,
    .b_wptr,
    .g_wptr,
    .full,
    .full_3_4
  );

  // input logic rclk, rrst_n, r_en,
  // input logic [PTR_WIDTH:0] g_wptr_sync, b_wptr_sync,
  // output logic [PTR_WIDTH:0] b_rptr, g_rptr,
  // output logic empty, empty_1_4
  rptr_handler #(PTR_WIDTH) rptr_h(
    .rclk, 
    .rrst_n, 
    .r_en,
    .g_wptr_sync,
    .b_wptr_sync,
    .b_rptr,
    .g_rptr,
    .empty,
    .empty_1_4
  );

  fifo_mem fifom(wclk, w_en, rclk, r_en,b_wptr, b_rptr, data_in,full,empty, data_out);

endmodule