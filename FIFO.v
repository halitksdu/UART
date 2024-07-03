module FIFO(
    input clk, reset, wr_en, rd_en, //0 aktif
    input [7:0] d_in,
    output reg [7:0] d_out,
    output reg full, empty);
    parameter depth = 8;
    integer i;
    reg [7:0] FIFO[depth-1:0];
    
    // Debouncer:
    reg activate;
    reg [29:0] sayac;
    always @(posedge clk) begin
		if(rd_en == 0) begin
		      sayac <= sayac + 1;
		      if (sayac == 3000000) // *3000000 yap
		      	activate <= 1;
		      else activate <= 0;
		end else begin
			  sayac <= 0;
			  activate <= 0;
	    end
    end
    
    // Module:
    reg [$clog2(depth):0] point_wr; // depth'in binary hali
    reg [$clog2(depth):0] point_rd;
    always @(posedge clk) begin
        if(reset == 0) begin
            point_wr <= 0;
            point_rd <= 0;
            d_out <= 8'd0;
            for(i=0;i<depth;i=i+1) begin
                FIFO[i]<= 8'd0;
            end 
        end else if(wr_en == 1 && full == 0) begin
            FIFO[point_wr] <= d_in;
            point_wr <= point_wr +1;
        end else if(activate==1 && rd_en == 0) begin
            
            d_out <= FIFO[point_rd];
            point_rd <= point_rd +1;
            if (point_rd>point_wr) point_rd <= 0;
            else if (point_rd == depth) point_rd <= 0;
        end 
    end 
    
    // Full ve empty 
    always @(*) begin
        if (point_wr == (depth))
            full= 1'b1;
        else if (point_wr == 0 || (point_rd>point_wr)) begin
            empty= 1'b1;
			full= 1'b0;
        end else begin
            full= 1'b0;
            empty= 1'b0; end
    end
endmodule