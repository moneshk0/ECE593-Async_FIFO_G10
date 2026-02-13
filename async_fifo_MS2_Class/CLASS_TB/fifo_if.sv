//  input logic wclk, wrst_n,
//  input logic rclk, rrst_n,
//  input logic w_en, r_en,
//  input logic [DATA_WIDTH-1:0] data_in,
//  output logic [DATA_WIDTH-1:0] data_out,
//  output logic full, empty

interface fifo_if #(parameter DEPTH=512, DATA_WIDTH=8)(
    input logic wclk, rclk
);
    
endinterface