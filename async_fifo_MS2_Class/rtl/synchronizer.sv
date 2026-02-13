/*
    g_in gray pointer in
    b_in binary pointer in
    g_out gray pointer out (synchronized)
    b_out binary pointer out (synchronized)
*/
module synchronizer #(parameter WIDTH = 3) (
    input logic clk, rst_n,
    input logic [WIDTH:0] g_in, b_in,
    output logic [WIDTH:0] g_out, b_out, 
);
    logic [WIDTH:0] g_q;
    logic [WIDTH:0] b_q;

    always_ff @(posedge clk) begin
        if(!rst_n) begin
            g_q <= 0;
            b_q <= 0;
            g_out <= 0;
            b_out <= 0;
        end
        else begin

            //gray ptr
            g_q <= g_in;
            g_out <= g_q;
            
            //binary ptr
            b_q <= b_in;
            b_out <= b_q; 
        end
    end
endmodule