module uart_rx(
    input rx, reset, clk,
    output reg [7:0] d_out,
    output reg rx_done);
    
    parameter IDLE = 2'b00;
    parameter START= 2'b01;
    parameter DATA = 2'b10;
    parameter STOP = 2'b11;
    reg [1:0] s_tick; reg [3:0] bit_counter; reg [7:0] d_ara; reg [9:0] deb_counter;
    
    always @(posedge clk, negedge reset) begin
        if(reset == 0) begin
            s_tick <= IDLE;
            bit_counter <= 4'd0; // 8 bit eleman alýcaz
            d_ara <= 8'd0;
            deb_counter <= 10'd0;
            
        end else  
            case (s_tick) 
                IDLE: begin 
                    rx_done <= 1'b0;
                    if(rx == 0)  begin
                        s_tick <= START;
                        bit_counter <= 4'd0;
                        deb_counter <= 10'd0;
                    end
                end     
                START: begin
                    deb_counter <= deb_counter +1;
                    if(deb_counter == 434) begin
                        deb_counter <= 0;
                        s_tick <= DATA;
                    end
                end
                DATA: begin
                    deb_counter <= deb_counter +1;
                     if (bit_counter == 0) begin
                        if(deb_counter == 217) begin
                            deb_counter <= 0;
                            bit_counter <= bit_counter + 1;
                            d_ara <= {rx , d_ara[7:1]}; 
                        end
                     end else begin   
                        if(deb_counter == 434) begin
                            deb_counter <= 0;
                            bit_counter <= bit_counter + 1;
                            d_ara <= {rx , d_ara[7:1]}; 
                            if(bit_counter == 4'd7) begin
                                s_tick <= STOP; 
                            end
                        end
                    end    
                end
                STOP: begin
                    if(rx == 1) deb_counter <= deb_counter +1;
                    if(deb_counter == 434) begin
                        d_out <= d_ara;
                        rx_done <= 1'b1;
                        s_tick <= IDLE;
                    end    
                end
        endcase
    end
    
endmodule
