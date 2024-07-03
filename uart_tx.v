module uart_tx(
    input [7:0] d_in,
    input send, clk, reset,
    output reg tx, 
	output reg busy);
    
    parameter IDLE = 2'b00;
    parameter START =2'b01;
    parameter DATA = 2'b10;
    parameter STOP = 2'b11;
    reg [1:0] s_tick; reg [2:0] bit_counter; reg [7:0] d_ara; reg [9:0] deb_counter;
    
    always @(posedge clk, negedge reset) begin
        if(reset == 0) begin
            s_tick <= IDLE;
            busy <= 1'b0;
            deb_counter <= 0;    
                    
        end else  
            case (s_tick) 
                IDLE: begin 
                    if(send == 1) begin
                        d_ara <= d_in;
                        s_tick <= START;
                        bit_counter <= 4'd0;
                    end
                end 
                START: begin
                    busy <= 1'b1;
                    deb_counter <= deb_counter +1;
                    if(deb_counter == 434) begin
                        tx <= 1'b0;
                        deb_counter <= 0;
                        s_tick <= DATA;
                    end
                end
                DATA: begin
                    deb_counter <= deb_counter +1;
                    if(deb_counter == 434) begin
                        deb_counter <= 0;
                        bit_counter <= bit_counter + 1;
                        d_ara <= {1'b0,d_ara[7:1]};   
                         
                        if(bit_counter < 4'd7) tx <= d_ara[0];
                        else if (bit_counter == 4'd7) begin
                            tx <= d_ara[0];
                            s_tick <= STOP;
                        end
                    end
                end
                STOP: begin
                    deb_counter <= deb_counter +1;
                    if(deb_counter == 434) begin
                        deb_counter <= 0;
                        s_tick <= IDLE;
                        tx <= 1'b1; 
                        busy <= 1'b0; 
                    end
                end
        endcase
    end
    
endmodule