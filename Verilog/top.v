`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Maryland, Baltimore County - ECLIPSE Cluster
// Engineer: Michael Skaggs
// Adapted to Spartan 3E by Deepak
// Create Date:    17:13:19 09/16/2014 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: Spartan-3E
// Tool versions: Xilinx ISE Design Suite 13.2
// Description: Full openMSP430 implimentation for the DPA Board
//////////////////////////////////////////////////////////////////////////////////
module top(
	 input dco_clk,
    output GPIO_LED0,
//    output GPIO_LED1,
//    output GPIO_LED2,
//    output GPIO_LED3,
//    output GPIO_LED4,
//    output GPIO_LED5,
//    output GPIO_LED6,
//    output GPIO_LED7,
//    
//    input GPIO_DIP0,
//    input GPIO_DIP1,
//    input GPIO_DIP2,
//    input GPIO_DIP3,
//    input GPIO_DIP4,
//    input GPIO_DIP5,
//    input GPIO_DIP6,
//    input GPIO_DIP7,
    input IN_GPIO,
    input USB_RS232_RXD_DB,
    output USB_RS232_TXD_DB,
	     
//    input RS232_Uart_1_sin_Bluetooth,
//    output RS232_Uart_1_sout_Bluetooth,

    input reset
);

// CLOCK AND RESET
wire mclk_wire;
//wire dco_clk;
wire reset_n;
wire puc_rst;

// LEDS
wire [7:0] led;

// SWITCHES
wire [7:0] switch;

// DATA MEMORY
wire dmem_cen_wire;
wire [9:0] dmem_addr_wire;
wire [15:0] dmem_dout_wire;
wire [15:0] dmem_din_wire;
wire [1:0] dmem_wen_wire;
//reg s_dmem_wen_wire;
//reg setf;

// PROGRAM MEMORY
wire pmem_cen_wire;
wire [13:0] pmem_addr_wire;
wire [15:0] pmem_dout_wire;
wire [15:0] pmem_din_wire;
wire [1:0] pmem_wen_wire;

// IRQ
wire [13:0] irq_bus;
wire nmi;

// GPIO
wire [7:0] p1_din;
wire [7:0] p1_dout;
wire [7:0] p1_dout_en;
wire [7:0] p1_sel;
wire [7:0] p2_din;
wire [7:0] p2_dout;
wire [7:0] p2_dout_en;
wire [7:0] p2_sel;

// PERIPHERAL BUS
wire [15:0] din_test;

wire [13:0] per_addr;
wire [15:0] per_din;
wire [1:0] per_we;
wire per_en;
wire [15:0] per_dout_gpio;
wire [15:0]  per_dout;

wire [15:0] cntrl3_insync;

//// Clock buffers
////------------------------
//BUFG  buf_sys_clock  (.O(dco_clk), .I(CLK));

// Reset buffers
//------------------------
IBUF   ibuf_reset_n   (.O(reset_n), .I(reset));

//// UART buffers
////------------------------
IBUF  UART_RXD_PIN       (.O(uart_rxd),        .I(USB_RS232_RXD_DB));
OBUF  UART_TXD_PIN       (.I(uart_txd),        .O(USB_RS232_TXD_DB));
//
//// UART buffers Bluetooth
////------------------------
//IBUF  UART_RXD_PIN_BT       (.O(uart_rxd),        .I(RS232_Uart_1_sin_Bluetooth));
//OBUF  UART_TXD_PIN_BT       (.I(uart_txd),        .O(RS232_Uart_1_sout_Bluetooth));

// UART buffers
//------------------------
//IBUF  UART_RXD_PIN       (.O(x99),        .I(RS232_Uart_1_sin));
//OBUF  UART_TXD_PIN       (.I(x99),        .O(RS232_Uart_1_sout));

// UART buffers Bluetooth
//------------------------
//IBUF  UART_RXD_PIN_BT       (.O(uart_rxd),        .I(RS232_Uart_1_sin_Bluetooth));
//OBUF  UART_TXD_PIN_BT       (.I(uart_txd),        .O(RS232_Uart_1_sout_Bluetooth));


// Peripheral buffers
//------------------------
//OBUF  LED7_PIN           (.I(led[7]),          .O(GPIO_LED7));
//OBUF  LED6_PIN           (.I(led[6]),          .O(GPIO_LED6));
//OBUF  LED5_PIN           (.I(led[5]),          .O(GPIO_LED5));
//OBUF  LED4_PIN           (.I(led[4]),          .O(GPIO_LED4));
//OBUF  LED3_PIN           (.I(led[3]),          .O(GPIO_LED3));
//OBUF  LED2_PIN           (.I(led[2]),          .O(GPIO_LED2));
//OBUF  LED1_PIN           (.I(led[1]),          .O(GPIO_LED1));
OBUF  LED0_PIN           (.I(led[0]),          .O(GPIO_LED0));
IBUF 	GPIO_PIN				 (.O(cntrl3_insync[0]), .I(IN_GPIO));

//IBUF  SW7_PIN            (.O(switch[7]),        .I(GPIO_DIP7));
//IBUF  SW6_PIN            (.O(switch[6]),        .I(GPIO_DIP6));
//IBUF  SW5_PIN            (.O(switch[5]),        .I(GPIO_DIP5));
//IBUF  SW4_PIN            (.O(switch[4]),        .I(GPIO_DIP4));
//IBUF  SW3_PIN            (.O(switch[3]),        .I(GPIO_DIP3));
//IBUF  SW2_PIN            (.O(switch[2]),        .I(GPIO_DIP2));
//IBUF  SW1_PIN            (.O(switch[1]),        .I(GPIO_DIP1));
//IBUF  SW0_PIN            (.O(switch[0]),        .I(GPIO_DIP0));


//clockdivider clockdivider
//   (// Clock in ports
//    .clkin_100MHz(clk),      // IN ... this is scaled down to 50 MHz
//    // Clock out ports
//    .clkout_25MHz(dco_clk));    // OUT


openMSP430 openMSP430_instance(

// OUTPUTs
    .aclk(),                               // ASIC ONLY: ACLK
    .aclk_en(aclk_en),                     // FPGA ONLY: ACLK enable
    .dbg_freeze(dbg_freeze),               // Freeze peripherals
    .dbg_i2c_sda_out(),                    // Debug interface: I2C SDA OUT
    .dbg_uart_txd(uart_txd),               // Debug interface: UART TXD
    .dco_enable(),                         // ASIC ONLY: Fast oscillator enable
    .dco_wkup(),                           // ASIC ONLY: Fast oscillator wake-up (asynchronous)
    .dmem_addr(dmem_addr_wire),           // Data Memory address
    .dmem_cen(dmem_cen_wire),              // Data Memory chip enable (low active)
    .dmem_din(dmem_din_wire),              // Data Memory data input
    .dmem_wen(dmem_wen_wire),              // Data Memory write enable (low active)
    .irq_acc(),                            // Interrupt request accepted (one-hot signal)
    .lfxt_enable(),                        // ASIC ONLY: Low frequency oscillator enable
    .lfxt_wkup(),                          // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
    .mclk(mclk_wire),                      // Main system clock
    .per_addr(per_addr),                   // Peripheral address
    .per_din(per_din),                     // Peripheral data input
    .per_we(per_we),                       // Peripheral write enable (high active)
    .per_en(per_en),                       // Peripheral enable (high active)
    .pmem_addr(pmem_addr_wire),            // Program Memory address
    .pmem_cen(pmem_cen_wire),              // Program Memory chip enable (low active)
    .pmem_din(pmem_din_wire),              // Program Memory data input (optional)
    .pmem_wen(pmem_wen_wire),              // Program Memory write enable (low active) (optional)
    .puc_rst(puc_rst),                     // Main system reset
    .smclk(),                              // ASIC ONLY: SMCLK
    .smclk_en(smclk_en),                   // FPGA ONLY: SMCLK enable
    
// INPUTs
    .cpu_en(1'b1),                         // Enable CPU code execution (asynchronous and non-glitchy)
    .dbg_en(1'b1),                         // Debug interface enable (asynchronous and non-glitchy)
    .dbg_i2c_addr(),                       // Debug interface: I2C Address
    .dbg_i2c_broadcast(),                  // Debug interface: I2C Broadcast Address (for multicore systems)
    .dbg_i2c_scl(),                        // Debug interface: I2C SCL
    .dbg_i2c_sda_in(),                     // Debug interface: I2C SDA IN
    .dbg_uart_rxd(uart_rxd),               // Debug interface: UART RXD (asynchronous)
    .dco_clk(dco_clk),                     // Fast oscillator (fast clock)
    .dmem_dout(dmem_dout_wire),            // Data Memory data output
    .irq(irq_bus),                         // Maskable interrupts
    .lfxt_clk(1'b0),                       // Low frequency oscillator (typ 32kHz)
    .nmi(nmi),                             // Non-maskable interrupt (asynchronous)
    .per_dout(per_dout_gpio),              // Peripheral data output
    .pmem_dout(pmem_dout_wire),            // Program Memory data output
    .reset_n(reset_n),                     // Reset Pin (low active, asynchronous and non-glitchy)
    .scan_enable(1'b0),                    // ASIC ONLY: Scan enable (active during scan shifting)
    .scan_mode(1'b0),                      // ASIC ONLY: Scan mode
    .wkup(1'b0)                            // ASIC ONLY: System Wake-up (asynchronous and non-glitchy)
);

//Sustain write_enable
//always@(posedge dco_clk or negedge reset_n) begin
//   if(reset_n == 1'b0) 
//      setf <= 1'b0;
//   else begin
//      if(setf == 1'b0)
//         s_dmem_wen_wire <= dmem_wen_wire[1];
//      else 
//         setf <= 1'b0;
//   end
//end

// Memory
//-------------------------------

RAM_16x2k DMEM_0 (
  .clka(dco_clk), 			// input clka
  .ena(~dmem_cen_wire), 	// input ena
  .wea(~dmem_wen_wire), 	// input wea
  .addra(dmem_addr_wire), 	// input [10 : 0] addra
  .dina(dmem_din_wire), 	// input [15 : 0] dina
  .douta(dmem_dout_wire) 	// output [15 : 0] douta
);

//wire [15:0] temp_dout;
//
//RAM_16x2k DMEM_0 (
//  .clka(dco_clk), // input clka
//  .ena(~dmem_cen_wire), // input ena
//  .wea(~dmem_wen_wire[0]), // input [0 : 0] wea
//  .addra(dmem_addr_wire), // input [9 : 0] addra
//  .dina(dmem_din_wire), // input [7 : 0] dina
//  .douta({temp_dout[7:0],dmem_dout_wire[7:0]}), // output [7 : 0] douta
//  .clkb(dco_clk), // input clkb
//  .enb(~dmem_cen_wire), // input enb
//  .web(~dmem_wen_wire[1]), // input [0 : 0] web
//  .addrb(dmem_addr_wire), // input [9 : 0] addrb
//  .dinb(dmem_din_wire), // input [7 : 0] dinb
//  .doutb({dmem_dout_wire[15:8],temp_dout[15:8]}) // output [7 : 0] doutb
//);


ROM_16x12k PMEM_0 (
  .clka(dco_clk), 			// input clka
  .ena(~pmem_cen_wire), 	// input ena
  .wea(~pmem_wen_wire), 	// input wea
  .addra(pmem_addr_wire), 	// input [13 : 0] addra
  .dina(pmem_din_wire), 	// input [15 : 0] dina
  .douta(pmem_dout_wire) 	// output [15 : 0] douta
);

// Digital I/O
//-------------------------------

omsp_gpio #(.P1_EN(1),
            .P2_EN(1),
            .P3_EN(0),
            .P4_EN(0),
            .P5_EN(0),
            .P6_EN(0)) gpio_0 (

// OUTPUTs
    .irq_port1    (irq_port1),             // Port 1 interrupt
    .irq_port2    (irq_port2),             // Port 2 interrupt
    .p1_dout      (p1_dout),               // Port 1 data output
    .p1_dout_en   (p1_dout_en),            // Port 1 data output enable
    .p1_sel       (p1_sel),                // Port 1 function select
    .p2_dout      (p2_dout),               // Port 2 data output
    .p2_dout_en   (p2_dout_en),            // Port 2 data output enable
    .p2_sel       (p2_sel),                // Port 2 function select
    .p3_dout      (),                      // Port 3 data output
    .p3_dout_en   (),                      // Port 3 data output enable
    .p3_sel       (),                      // Port 3 function select
    .p4_dout      (),                      // Port 4 data output
    .p4_dout_en   (),                      // Port 4 data output enable
    .p4_sel       (),                      // Port 4 function select
    .p5_dout      (),                      // Port 5 data output
    .p5_dout_en   (),                      // Port 5 data output enable
    .p5_sel       (),                      // Port 5 function select
    .p6_dout      (),                      // Port 6 data output
    .p6_dout_en   (),                      // Port 6 data output enable
    .p6_sel       (),                      // Port 6 function select
    .per_dout     (per_dout),              // Peripheral data output
			     
// INPUTs
    .mclk         (mclk_wire),             // Main system clock
    .p1_din       (p1_din),                // Port 1 data input
    .p2_din       (p2_din),                // Port 2 data input
    .p3_din       (8'h00),                 // Port 3 data input
    .p4_din       (8'h00),                 // Port 4 data input
    .p5_din       (8'h00),                 // Port 5 data input
    .p6_din       (8'h00),                 // Port 6 data input
    .per_addr     (per_addr),              // Peripheral address
    .per_din      (per_din),               // Peripheral data input
    .per_en       (per_en),                // Peripheral enable (high active)
    .per_we       (per_we),                // Peripheral write enable (high active)
    .puc_rst      (puc_rst)                // Main system reset
);

// Assign LEDs
//assign  led[7:0]         = out1[7:0];//p1_dout[7:0];//p1_dout[7:0] & p1_dout_en[7:0];

assign  led[7:0]         = p1_dout[7:0];//p1_dout[7:0] & p1_dout_en[7:0];//p1_dout[7:0];

// Assign Switches
assign  p2_din[7:0]      = switch[7:0];

// Interupt assignments
//-------------------------------

assign nmi      =   1'b0;
assign irq_bus  =  {1'b0,         // Vector 13  (0xFFFA)
                    1'b0,         // Vector 12  (0xFFF8)
                    1'b0,         // Vector 11  (0xFFF6)
                    1'b0,         // Vector 10  (0xFFF4) - Watchdog -
                    1'b0,    	    // Vector  9  (0xFFF2)
                    1'b0,     	 // Vector  8  (0xFFF0)
                    1'b0,  		 // Vector  7  (0xFFEE)
                    1'b0,  		 // Vector  6  (0xFFEC)
                    1'b0,         // Vector  5  (0xFFEA)
                    1'b0,         // Vector  4  (0xFFE8)
                    irq_port2,    // Vector  3  (0xFFE6)
                    irq_port1,    // Vector  2  (0xFFE4)
                    1'b0,         // Vector  1  (0xFFE2)
                    1'b0};        // Vector  0  (0xFFE0)
						 



	// Outputs
	wire [15:0] my_dout;
	wire [15:0] out1;
	wire [15:0] out2;
	assign cntrl3_insync[15:1] = 0;
	wire [15:0] out4;
	assign out4=0;
	
   assign my_dout = 16'd0;
//template_periph_16b gpio16 (
//    .per_dout(my_dout), 
//	 .cntrl1(out1),
//	 .cntrl2(out2),
//	 .cntrl3_insync(cntrl3_insync),
//	 .cntrl4_in(out4),
//    .mclk(mclk_wire), 
//    .per_addr(per_addr), 
//    .per_din(per_din), 
//    .per_en(per_en), 
//    .per_we(per_we), 
//    .puc_rst(puc_rst)
//    );
	 
	 


assign  per_dout_gpio =  per_dout | my_dout;
//
//wire rx_empty;
//wire rx_avail = ~rx_empty;
//wire uld_rx_data = rx_avail;
//wire [7:0] rx_data;
//reg uld_rx_data_prev;
//wire tx_send;
//wire txtmp;
//
//assign tx_send = uld_rx_data_prev & ~ uld_rx_data;
//
//always @ (posedge dco_clk) begin
//    uld_rx_data_prev <= uld_rx_data;
//end 
//
//uart uart_instance(
//		.reset(reset_n)     ,
//		.clk(dco_clk)  ,
//		.ld_tx_data(tx_send)    ,
//		.tx_data(rx_data)        ,
//		.tx_enable(1'b1)      ,
//		.tx_out(txtmp)         ,
//		.tx_empty()       ,
//		.uld_rx_data(uld_rx_data)    , //move new internal data to show up on rx_data
//		.rx_data(rx_data)        , //internal data
//		.rx_enable(1'b1)      , //just set to 1
//		.rx_empty(rx_empty),
//		.rx_in(uart_rxd)
//);

//wire test = reset;
//
//wire [35:0] CONTROL0;
//my_icon icon (
//    .CONTROL0(CONTROL0) // INOUT BUS [35:0]
//); 
//
//my_ila ila (
//    .CONTROL(CONTROL0), // INOUT BUS [35:0]
//    .CLK(dco_clk), // IN
//    .DATA(test), // IN BUS [7:0]
//    .TRIG0(led[0]) // IN BUS [0:0]
//);

//wire [35:0] CONTROL0;
//my_icon1 icon (
//    .CONTROL0(CONTROL0) // INOUT BUS [35:0]
//); 
//
//my_ila ila (
//    .CONTROL(CONTROL0), // INOUT BUS [35:0]
//    .CLK(dco_clk), // IN
//    .DATA({dmem_din_wire}), // IN BUS [15:0]
//    .TRIG0(led[0]) // IN BUS [0:0]
//);

endmodule
