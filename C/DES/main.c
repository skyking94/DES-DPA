


#include "DES.c"
//#include "DES.h"
#include "omsp_system.h"
#include "hardware.h"
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

#define TXLED BIT0
#define RXLED BIT6

#define TXD BIT2 //P1.2
#define RXD BIT1 //P1.1

uint64_t plaintext = 0x8000000000000000;
uint64_t plaintext_xor = 0x8000000000000057; //01010111

/*void ConfigWDT(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // Stop watchdog timer
}*/


//--------------------------------------------------//
//                 tty_putc function                 //
//            (Send a byte to the UART)             //
//--------------------------------------------------//
int tty_putc (uint8_t txdata) {

  // Wait until the TX buffer is not full
  while (UART_STAT & UART_TX_FULL);

  // Write the output character
  UART_TXD = txdata;

  return 0;
}


uint64_t lfsr(uint64_t plaintext, uint64_t plaintext_xor, uint64_t start_val, unsigned long cnt)
{
    if (cnt == 0) {
		return start_val;
	}
	else {
		unsigned lsb = plaintext & 1;
		plaintext >>= 1;
		if (lsb) {
			plaintext ^= plaintext_xor;
		}
		return plaintext;
	}
}

void delay(unsigned int c, unsigned int d) {
  	unsigned int i;
	unsigned int j;
	for(i=0;i<c;i++){
		for(j=0; j<d;j++){
         __asm__ __volatile__("nop");
         __asm__ __volatile__("nop");
		}
	}
}

int main(void) {
    
	WDTCTL = WDTPW | WDTHOLD;   // Stop watchdog timer
    UART_BAUD = BAUD;                   // Init UART
    UART_CTL  = UART_EN | UART_IEN_RX;
	
	P3OUT  |= 0x00;                     // Port data output
    P3DIR  |= 0xFF;                     // Port direction register


    int i = 0;
	unsigned long j = 0;
	//int k = 0;
    unsigned long lfsr_cnt = 0;
    const uint64_t first_plaintext = 0x8000000000000000;
	const uint64_t mask = 0x00000000000000FF;
	unsigned int res;
	uint8_t pt;
	uint64_t b;
	uint8_t data[8];
	
	uint8_t key[8] = {0x00, 0x1D, 0x9F, 0x7D, 0xA0, 0xD1, 0xC6, 0xB1};
		
	//SHOULD NOT PROCEED BEFORE THE DATA AND KEY HAVE BEEN RECEIVED VIA UART
	des_ctx     dc1;   //Key schedule structure

	//Setup key for encryption
	Des_Key(&dc1, key, EN0);
	
    while(j < 400000)
    {
		//P3OUT = 0x80;
        plaintext = lfsr(plaintext, plaintext_xor, first_plaintext, lfsr_cnt);
        lfsr_cnt = lfsr_cnt + 1;
		//P3OUT = 0x00;
		//P3OUT = 0x80;
		b = plaintext;
		for(int i = 8; i > 0; i--) {
            res = b & mask;
			pt = (uint8_t)res;
			data[i-1] = res;//pt;
			b = b >> 8;
        }
        //P3OUT = 0x00;
		//BC4BFCEDF1DC5593
        //uint8_t key[8] = {0xBC, 0x4B, 0xFC, 0xED, 0xF1, 0xDC, 0x55, 0x93};
		
		//uint8_t data[8] = {0xBC, 0x4B, 0xFC, 0xED, 0xF1, 0xDC, 0x55, 0x93};
        //uint8_t data[8] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
       
		
		P3OUT = 0x80; //trigger scope
        Des_Enc(&dc1, data, 1); //Encrypt Data
		//delay(7, 500);
		P3OUT = 0x00; //reset port 3
		
		if ((j % 10000) == 0) {
		P3OUT = 0x01; // switch to hardware UART module
		
		tty_putc(data[0]);//k*4);
		tty_putc(data[1]);//(k*4)+1);
		tty_putc(data[2]);//(k*4)+2);
		tty_putc(data[3]);//(k*4)+3);
		tty_putc(data[4]);//k*4);
		tty_putc(data[5]);//(k*4)+1);
		tty_putc(data[6]);//(k*4)+2);
		tty_putc(data[7]);//(k*4)+3);
		
		P3OUT = 0x00; //reset port 3
		}
		
		j++;
    }

}
















    //ConfigWDT();
    /*ConfigClocks();
    ConfigPorts();
    LED_init();*/
    //USCI_init();

    //int j = 0;
    //int k = 0;
    // Need to send Start of Encryption byte ?? 
    // Do this forever till Hardware reset


//P1OUT &= ~RXLED; // Turn ON RXD LED
        //uint8_t data[8] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07};

        //SHOULD NOT PROCEED BEFORE THE CIPHERTEXT HAS BEEN GENERATED
        //tx_data = cp;
        //UC0IE |= UCA0TXIE; // Enable USCI_A0 TX interrupt

/*
#pragma vector=USCIAB0TX_VECTOR
__interrupt void USCI0TX_ISR(void)
{
   int j = 0;
   P1OUT |= TXLED; // Turn ON TXD LED
   for (j = 8; j > 0; j--)
   {
       UCA0TXBUF = *var1; // TX next character
       var1++;
       // Transmitted all the data?
       if (j == 1) UC0IE &= ~UCA0TXIE; // Disable USCI_A0 TX interrupt
   }
   P1OUT &= ~TXLED; // Turn OFF TXD LED
} */

/*#pragma vector=USCIAB0RX_VECTOR
__interrupt void USCI0RX_ISR(void)
{
  int k = 0;
  P1OUT |= RXLED; // Turn ON RXD LED
  // receive 16 bytes, 8 each for data and key
  for (k = 16; k > 0; k--)
  {
      //data should be received in little endian way - LSB Byte first
      if (k > 8) data[k-9] = UCA0RXBUF;
      //key should be received in little endian way - LSB Byte first
      else key[k-1] = UCA0RXBUF;
  }
   P1OUT &= ~RXLED; // Turn OFF RXD LED
}*/



//if (UCA0RXBUF == 'a') // 'a' received?
    //{ 
    //  i = 0; 
     
    //  UCA0TXBUF = string[i++]; 
    //} 
    


/*void ConfigClocks(void)
{
    // Calibrate and set the internal clock to 16MHz
    DCOCTL = 0;
    BCSCTL1 = CALBC1_16MHZ;
    DCOCTL = CALDCO_16MHZ;
}*/

/*void ConfigPorts(void)
{
    // reset port 2
    P2DIR = 0xFF; // All P2.x outputs<
    P2OUT &= 0x00; // All P2.x reset
}*/

/*void LED_init(void)
{
    // set port 1 pin 1 and pin 2 for special function - UART
    P1SEL |= RXD + TXD ; // P1.1 = RXD, P1.2=TXD
    P1SEL2 |= RXD + TXD ; // P1.1 = RXD, P1.2=TXD
    P1DIR |= RXLED + TXLED; // Setting the two LEDs on board to indicate
    P1OUT &= 0x00;          // RXD and TXD signals
}*/

/*void USCI_init(void)
{
    UCA0CTL1 |= UCSSEL_2; // SMCLK
    UCA0BR0 = 0x8A; // 16MHz 115200
    UCA0BR1 = 0x00; // 16MHz 115200
    UCA0MCTL = UCBRS2 + UCBRS1; // Modulation UCBRSx = 6
    UCA0CTL1 &= ~UCSWRST; // **Initialize USCI state machine**
}*/



        //P1OUT |= RXLED; // Turn OFF RXD LED
        //unsigned char tx_data[8]= {};
        /*Receive the Plaintext and Keys*/
        //UC0IE |= UCA0RXIE; // Enable USCI_A0 RX interrupt
		
		
		

/*void serial_putc(uint8_t c)
{
    while (!( IFG2 & UCA0TXIFG ));                // USCI_A0 TX buffer ready?
    UCA0TXBUF = c;                            // TX
}*/
//void serial_putc(uint8_T c)


        //unsigned char *cp;//, *ky;
        /*unsigned long ek[32] = {923930174, 555293218, 371589388, 371402557, 741747751, 439955748, 890908718, 302450739,
                                473568568, 957624861, 386080263, 187052312, 739311620, 742268719, 990648626, 69608228,
                                488441345, 992096019, 974338324, 755187232, 504179261, 471728650, 151404296, 219876630,
                                220534043, 808916010, 723658529, 907086601, 119416857, 842805044, 137835042, 1007498507};*/
		//cp = data; 