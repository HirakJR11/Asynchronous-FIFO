module clk_div_LL(
input CLOCK_50,
output [11:0] LEDR,
output [7:0] LEDG
);
	
localparam counter_rd = 27;
localparam counter_wr = 26;
wire dut_clk_wr;
wire dut_clk_rd;
wire wr_en, rd_en;
wire [4:0] rd_ptr;
wire [4:0] wr_ptr;
wire empty, full;
wire [15:0] data_out_fifo;

async_fifo_wrapper i0(dut_clk_wr, dut_clk_rd, wr_ptr, rd_ptr, rd_en, empty, full, data_out_fifo);

assign LEDR [11:2] = data_out_fifo;
assign LEDR [1] = full;
assign LEDR [0] = empty;
assign LEDG [0] = dut_clk_wr;
assign LEDG [1] = dut_clk_rd;
assign LEDG [6:2] = rd_ptr;
assign LEDG [7] = rd_en;

//assign LEDR = {data_out_fifo[9:0], full, empty} ;
//assign LEDG = {rd_ptr, dut_clk};

reg [counter_rd-1:0] k_bit_counter_rd = 0;
reg [counter_wr-1:0] k_bit_counter_wr = 0;

always @(posedge CLOCK_50) begin
	k_bit_counter_rd <= k_bit_counter_rd + 1;
end

always @(posedge CLOCK_50) begin
	k_bit_counter_wr <= k_bit_counter_wr + 1;
end

assign dut_clk_rd = k_bit_counter_rd[counter_rd-1];
assign dut_clk_wr = k_bit_counter_wr[counter_wr-1];
endmodule