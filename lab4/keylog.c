
 */
// most of these could probably be char
volatile int PD_DATA_R __attribute__((at(0x400073FC)));       
volatile int PD_DIR_R __attribute__((at(0x40007400)));
volatile int PD_AF_R __attribute__((at(0x40007420)));      
volatile int PD_DEN_R __attribute__((at(0x4000751C)));
volatile int RCGC2_R __attribute__((at(0x400FE108)));
#define RCGC2_PD      0x00000008  //value for RCGC2 to enable clock for port D

int main(void)
{
	unsigned char z;
	
	// initialise port: RMW-cycle so much better in C...
	RCGC2_R |= RCGC2_PD; //activate port D: RCGC2 = RCGC2 | RCGC2_PD
  PD_DIR_R |= 0x0F;    //make PD3-0 output
  PD_AF_R &= 0x00;    //disable alt. func. 
  PD_DEN_R |= 0x0F; //enable digital I/O on PD3-0
	
	while(1)
	{
		for(z=0;z<16;z++)
			PD_DATA_R = z;
	}
	
	return 1;
}
