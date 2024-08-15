module async_fifo(
input wr_clk, rd_clk,
input reset,
input wr_en,
output reg rd_en,
input [15:0] data_in,
output [15:0] data_out,
output empty,
output full,
output reg [4:0] wr_ptr,
output reg [4:0] rd_ptr
);

parameter data_width = 16;
parameter fifo_depth = 8;
parameter ptr_size = 5;
reg [data_width-1:0] memory [0:fifo_depth-1];
reg empty_reg;
reg full_reg;
wire [data_width-1:0] data_in_reg;

//Write Process
always @(posedge wr_clk or posedge reset) begin
	if (reset)
		wr_ptr <= 0;
	else if (wr_en && !full_reg && (wr_ptr < fifo_depth))
		wr_ptr <= wr_ptr + 1;
end

always @(posedge rd_clk or posedge reset) begin
	if (reset)
		empty_reg <= 1;
	else if (wr_en && !full_reg && (wr_ptr != rd_ptr))
		empty_reg <= 0;
	else if (rd_en && (wr_ptr == rd_ptr))
		empty_reg <= 1;
end

always @(posedge wr_clk or posedge reset) begin
	if (reset)
		full_reg <= 0;
	else if (wr_en && ((wr_ptr+1) % fifo_depth == rd_ptr)) begin
		full_reg <= 1;
		rd_en <= 1;
	end
	else if (rd_en && !empty_reg)
		full_reg <= 0;
end
 
//Read Process
always @(posedge rd_clk or posedge reset) begin
	if (reset)
		rd_ptr <= 0;
	else if (rd_en && !empty_reg)
		rd_ptr <= rd_ptr + 1;
end
 
integer i;
always @(posedge wr_clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < fifo_depth; i = i + 1) begin
            memory[i] <= {data_width{1'b0}};
        end
    end 
	 else if (wr_en && !full_reg) begin
        memory[wr_ptr] <= data_in;
    end
end

//Data Retrieval
assign data_out = (empty_reg) ? 'hx : memory[rd_ptr];

//Status Outputs
assign empty = empty_reg;
assign full = full_reg;
endmodule

