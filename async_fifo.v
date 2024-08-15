//**********Asynchronous FIFO block**********//
module async_fifo(
input wr_clk, rd_clk,
input reset,
output reg wr_en = 0,
output reg rd_en = 0,
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
reg [data_width-1:0] data_out_reg;

//Write process
always @(posedge wr_clk or posedge reset) begin
	if (reset)
		wr_ptr <= 0;
	else if (wr_en && !full_reg && (wr_ptr < fifo_depth))
		wr_ptr <= wr_ptr + 1;
	else if (wr_en && !full_reg && (wr_ptr == fifo_depth))
		wr_ptr <= 0;
	else if (full_reg)
		wr_ptr <= wr_ptr;
end

always @(*) begin
	if (reset)
		empty_reg <= 1;
	else if (wr_en && !full_reg && (wr_ptr != rd_ptr)) begin
		empty_reg <= 0;
		rd_en <= 1;
	end
	else if (rd_en && !full_reg && (wr_ptr == rd_ptr) && (data_out_reg == data_in)) begin
		empty_reg <= 1;
	end
end

always @(posedge wr_clk or posedge reset) begin
	if (reset)
		wr_en <= 0;
	else begin
		if(full_reg)
			wr_en <= 0;
		else
			wr_en <= 1;
	end
end 

always @(*) begin
	if (reset)
		full_reg <= 0;
	else if (wr_en && ((wr_ptr+1) % fifo_depth == rd_ptr)) begin
		full_reg <= 1;
		//rd_en <= 1;
	end
	else if (rd_en && !empty_reg)
		full_reg <= 0;
end
 
//Read process
always @(posedge rd_clk or posedge reset) begin
	if (reset)
		rd_ptr <= 0;
	else if (rd_en && !empty_reg && (rd_ptr < fifo_depth))
		rd_ptr <= rd_ptr + 1;
	else if (rd_en && !empty_reg && (rd_ptr == fifo_depth))
		rd_ptr <= 0;
end
 
//Data storage
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


//Data retrieval
always @(posedge rd_clk) begin
	if (empty_reg)
		data_out_reg <= 'hx;
	else if (!empty_reg)
		if (rd_en)
			data_out_reg <= memory[rd_ptr];
		else
			data_out_reg <= 'hx;
end

//Status outputs
assign empty = empty_reg;
assign full = full_reg;
assign data_out = data_out_reg;
endmodule

//**********Data memory**********//
module data_mem(
input wr_clk,
input wr_en,
//input full,
//output reg [4:0] wr_ptr_fifo = 0,
output reg [15:0] data_out
); 

parameter ptr_size = 5;
reg [15:0] rom [0:31]; 
reg [ptr_size-1:0] wr_ptr_fifo = 0;

always @(posedge wr_clk) begin
	if (wr_ptr_fifo < 32 && wr_en) begin
		wr_ptr_fifo = wr_ptr_fifo + 1;
		data_out = rom[wr_ptr_fifo];
	end
end

//Memory block
initial begin
rom[0] = 16'b0000000001101111; // 111
rom[1] = 16'b0000000011011110; // 222
rom[2] = 16'b0000000101001101; // 333
rom[3] = 16'b0000000110111100; // 444
rom[4] = 16'b0000001000101101; // 555
rom[5] = 16'b0000001010011010; // 666
rom[6] = 16'b0000001100001001; // 777
rom[7] = 16'b0000001101111000; // 888
rom[8] = 16'b0000001111100111; // 999
rom[9] = 16'b0000010001011110; // 1110
rom[10] = 16'b0000010011001101; // 1221
rom[11] = 16'b0000010100111100; // 1332
rom[12] = 16'b0000010110101011; // 1443
rom[13] = 16'b0000011000011010; // 1554
rom[14] = 16'b0000011010001011; // 1665
rom[15] = 16'b0000011011110000; // 1776
rom[16] = 16'b0000011101100111; // 1887
rom[17] = 16'b0000011111000110; // 1998
rom[18] = 16'b0000100000101110; // 2110
rom[19] = 16'b0000100010011101; // 2221
rom[20] = 16'b0000100100001100; // 2332
rom[21] = 16'b0000100101111011; // 2443
rom[22] = 16'b0000100111101010; // 2554
rom[23] = 16'b0000101001011011; // 2665
rom[24] = 16'b0000101011000000; // 2776
rom[25] = 16'b0000101100110111; // 2887
rom[26] = 16'b0000101110010110; // 2998
rom[27] = 16'b0000110000001110; // 3110
rom[28] = 16'b0000110001111101; // 3221
rom[29] = 16'b0000110011101100; // 3332
rom[30] = 16'b0000110101011011; // 3443
rom[31] = 16'b0000110111001010; // 3554
end
endmodule