`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:35:50 06/19/2015 
// Design Name: 
// Module Name:    uart 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module uart (
		reset          ,
		ld_tx_data     ,
		tx_data        ,
		tx_enable      ,
		tx_out         ,
		tx_empty       ,
		clk          ,
		uld_rx_data    , //move new internal data to show up on rx_data
		rx_data        , //internal data
		rx_enable      , //just set to 1
		rx_in          , //external rx
		rx_empty
);

                         // CLK/baud - 1
parameter CLK_DIVISION = 85; //for 115200 baud with 100Mhz clk: 10000000/115200-1
//parameter CLK_DIVISION = 346; //for 115200 baud with 40Mhz clk: 40000000/115200-1
//parameter CLK_DIVISION = 216; //for 115200 baud with 25Mhz clk: 25000000/115200-1
//parameter CLK_DIVISION = 217; //for 115200 baud with 100Mhz clk: 100000000/115200-1
reg [9:0] rx_sample_cnt  ;     //make this big enough to hold CLK_DIVISION
reg [9:0] tx_div_cnt  ;     //make this big enough to hold CLK_DIVISION



// Port declarations
input        reset          ;
input        clk          ;
input        ld_tx_data     ;
input  [7:0] tx_data        ;
input        tx_enable      ;
output       tx_out         ;
output       tx_empty       ;
input        uld_rx_data    ;
output [7:0] rx_data        ;
input        rx_enable      ;
input        rx_in          ;
output       rx_empty       ;

// Internal Variables 
reg [7:0]    tx_reg         ;
reg          tx_empty       ;
reg          tx_over_run    ;
reg [3:0]    tx_cnt         ;
reg          tx_out         ;
reg [7:0]    rx_reg         ;
reg [7:0]    rx_data        ;

//reg [9:0]    rx_sample_cnt  ;     //make this big enough to hold CLK_DIVISION


reg [3:0]    rx_cnt         ;  
reg          rx_frame_err   ;
reg          rx_over_run    ;
reg          rx_empty       ;
reg          rx_d1          ;
reg          rx_d2          ;
reg          rx_busy        ;


// UART RX Logic
always @ (posedge clk or posedge reset)
if (reset) begin
  rx_reg        <= 0; 
  rx_data       <= 0;
  rx_sample_cnt <= 0;
  rx_cnt        <= 0;
  rx_frame_err  <= 0;
  rx_over_run   <= 0;
  rx_empty      <= 1;
  rx_d1         <= 1;
  rx_d2         <= 1;
  rx_busy       <= 0;
end else begin
  // Synchronize the asynch signal
  rx_d1 <= rx_in;
  rx_d2 <= rx_d1;
  // Uload the rx data
  if (uld_rx_data) begin
    rx_data  <= rx_reg;
    rx_empty <= 1;
  end
  // Receive data only when rx is enabled
  if (rx_enable) begin
    // Check if just received start of frame
    if (!rx_busy && !rx_d2) begin
      rx_busy       <= 1;
      rx_sample_cnt <= 1;
      rx_cnt        <= 0;
    end
    // Start of frame detected, Proceed with rest of data
    if (rx_busy) begin
       if (rx_sample_cnt == CLK_DIVISION) begin 
		   rx_sample_cnt <= 0;
	    end else begin
		   rx_sample_cnt <= rx_sample_cnt + 1;
		 end
       // Logic to sample at middle of data
       if (rx_sample_cnt == CLK_DIVISION/2) begin
          if ((rx_d2 == 1) && (rx_cnt == 0)) begin
            rx_busy <= 0;
          end else begin
            rx_cnt <= rx_cnt + 1; 
            // Start storing the rx data
            if (rx_cnt > 0 && rx_cnt < 9) begin
              rx_reg[rx_cnt - 1] <= rx_d2;
            end
            if (rx_cnt == 9) begin
               rx_busy <= 0;
               // Check if End of frame received correctly
               if (rx_d2 == 0) begin
                 rx_frame_err <= 1;
               end else begin
                 rx_empty     <= 0;
                 rx_frame_err <= 0;
                 // Check if last rx data was not unloaded,
                 rx_over_run  <= (rx_empty) ? 0 : 1;
               end
            end
          end
       end 
    end 
  end
  if (!rx_enable) begin
    rx_busy <= 0;
  end
end

// UART TX Logic
always @ (posedge clk or posedge reset)
if (reset) begin
  tx_reg        <= 0;
  tx_empty      <= 1;
  tx_over_run   <= 0;
  tx_out        <= 1;
  tx_cnt        <= 0;
  tx_div_cnt    <= 0;
end else begin

   if (ld_tx_data) begin
      if (!tx_empty) begin
        tx_over_run <= 0;
      end else begin
        tx_reg   <= tx_data;
        tx_empty <= 0;
		  tx_div_cnt <= 0;
      end
   end
	
	tx_div_cnt <= tx_div_cnt + 1;

   if (tx_enable && !tx_empty &&  tx_div_cnt == CLK_DIVISION) begin
	  tx_div_cnt<=0;
     tx_cnt <= tx_cnt + 1;
     if (tx_cnt == 0) begin
       tx_out <= 0;
		 tx_div_cnt <= 0;
     end
     if (tx_cnt > 0 && tx_cnt < 9) begin
        tx_out <= tx_reg[tx_cnt -1];
     end
     if (tx_cnt == 9) begin
       tx_out <= 1;
       tx_cnt <= 0;
       tx_empty <= 1;
     end
   end
   if (!tx_enable) begin
     tx_cnt <= 0;
   end
end



endmodule


