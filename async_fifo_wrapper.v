module async_fifo_wrapper(
input wr_clk,
input rd_clk,
output [4:0] wr_ptr,
output [4:0] rd_ptr,
output rd_en,
output empty, full,
output [15:0] data_out_fifo
);

wire reset;
wire wr_en;
//wire rd_en;
wire [15:0] data_in_fifo;

//Signals for mem_block
reg [17:0] rom [0:31]; 
reg [17:0] rom_out;
reg [4:0] rom_addr = 0;

async_fifo i0(wr_clk, rd_clk, reset, wr_en, rd_en, data_in_fifo, data_out_fifo, empty, full, wr_ptr, rd_ptr);

always @(*) begin
	rom_out = rom[rom_addr];
end

always @(posedge wr_clk) begin
	if (rom_addr < 32) begin
		rom_addr = rom_addr + 1;
	end
end

assign data_in_fifo = rom_out[17:2];
assign wr_en = rom_out[1];
assign reset = rom_out[0];

initial begin
rom[0] = 18'b000000010011100111;	
rom[1] = 18'b000000110101010011; 
rom[2] = 18'b000001110001010111; 
rom[3] = 18'b000110010011100010; 
rom[4] = 18'b000001010011100110; 
rom[5] = 18'b000101011010000010; 	
rom[6] = 18'b000001100100110110; 
rom[7] = 18'b000011110001110010;
rom[8] = 18'b000000010011000110; 
rom[9] = 18'b000000110011000010; 
rom[10] = 18'b000001110011101110; 
rom[11] = 18'b000110010101010010; 
rom[12] = 18'b000001010101010110; 
rom[13] = 18'b000101010001100010; 
rom[14] = 18'b000001100100010110; 
rom[15] = 18'b000011110010100010;
rom[16] = 18'b000000010011000110; 
rom[17] = 18'b000000110011100010; 
rom[18] = 18'b000001110000000110; 
rom[19] = 18'b000110010101010010; 
rom[20] = 18'b000001010010110110; 
rom[21] = 18'b000101010000100010; 
rom[22] = 18'b000001100001100110;
rom[23] = 18'b000011110010010010;
rom[24] = 18'b000000010001100110; 
rom[25] = 18'b000000110010100010; 
rom[26] = 18'b000001110000000110; 
rom[27] = 18'b000110010001100010; 
rom[28] = 18'b000001010010010110; 
rom[29] = 18'b000101010101000010; 
rom[30] = 18'b000001100001000110; 
rom[31] = 18'b000011110100010010; 
end
endmodule