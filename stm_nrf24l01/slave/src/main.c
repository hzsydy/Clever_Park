#include "stm32f10x.h"
#include "usart.h"
#include "sys.h"
#include "delay.h"
#include "NRF24L01.h"

int main(void)
{
	u8 tmp_buf[33];
	u8 mode = 0;
	u8 waitingforNRF24L01 = 0;
	delay_init();
	NVIC_Configuration();
	usart_init(9600);
	NRF24L01_Init();
	
	while(NRF24L01_Check())//检测不到24L01
	{
		waitingforNRF24L01++;
		if(waitingforNRF24L01 > 5)printf("Cannot find NRF24L01,please @110\n");
		delay_ms(500);
	}
	
	printf("110 arrived in %d time\n", waitingforNRF24L01);
	
	tmp_buf[0] = 'n';
	tmp_buf[1] = 'i';
	tmp_buf[2] = 'a';
	tmp_buf[3] = 'x';
	tmp_buf[4] = 'i';
	tmp_buf[5] = 'p';
	tmp_buf[6] = 'i';
	tmp_buf[7] = 'e';
	tmp_buf[8] = 0x0d;
	tmp_buf[9] = 0x0a;
	
	if(mode)//RX模式
	{
		RX_Mode();		  
		while(1)
		{	  		    		    				 
			if(NRF24L01_RxPacket(tmp_buf)==0)//一旦接收到信息,则显示出来.
			{
				tmp_buf[32]=0;//加入字符串结束符
				printf("%s\n", tmp_buf);				
			}
			else
			{
				delay_us(100);
			}
		}
	}
	else//TX模式
	{
		TX_Mode();
		while(1)
		{	  		   				 
			if(NRF24L01_TxPacket(tmp_buf)==TX_OK)
			{
				;
			}
			else
			{										   	
 				printf("Send failed,please @110\n");			   
			}
			delay_ms(1500);				    
		}
	}    
	
}
