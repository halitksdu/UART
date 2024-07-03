module uart_top(
    input FPGA_in, clk, reset, Read_en,
    output FPGA_out, Busy,
    output [7:0] FIFO_o);
    
    // PC ==> FPGA (UART_RX):
    uart_rx rx(FPGA_in,reset,clk,rx_out,done);
    
    // FIFO:
    wire [7:0] rx_out; wire done;
    wire full,empty;
    FIFO fifo(clk,reset,done,Read_en,rx_out,FIFO_o,full,empty);
    
    // FPGA ==> PC (UART_TX):
    reg [7:0] TX_in; reg send;
    reg full_history,empty_history; reg ful,emp;
    uart_tx tx(TX_in, send, clk, reset, FPGA_out, Busy); 
    
    always @(posedge clk)begin
        if(!reset)begin
            full_history=0;
            empty_history=0;
        end else begin
            full_history <= full;
            empty_history <= empty;
            if(full==1 && full_history==0)begin
                ful<=1;
            end else begin
                ful<=0;
            end
            if(empty==1 && empty_history==0)begin
                emp<=1;
            end else begin
                emp<=0;
            end
        end
    end
    
    // ASCII "empty" ve "full" gönderme:    
    always @(full,empty) begin
        if (full == 1)       TX_in = 8'b0100_0110;      // ASCII F harfi 
        else if (empty == 1) TX_in = 8'b0100_0101;      // ASCII E harfi 
    end
    
    always @* begin
        if (ful == 1)        send = 1;
        else if (emp == 1)   send = 1;
        else                 send = 0;
    end
    
endmodule