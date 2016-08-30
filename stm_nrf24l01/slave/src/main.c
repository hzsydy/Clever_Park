#include "stm32f10x.h"
#include "usart.h"
#include "sys.h"
#include "delay.h"
#include "NRF24L01.h"

int main(void)
{
	u8 tmp_buf[33];
	u8 mode = 1;
	u8 mode_inited = 0;
	u8 waitingforNRF24L01 = 0;
	u8 i;
	delay_init();
	NVIC_Configuration();
	usart_init(9600);
	NRF24L01_Init();
	
	while(NRF24L01_Check())//检测不到24L01
	{
		waitingforNRF24L01++;
		delay_ms(500);
	}
	
	//slave
	
	mode = 1;

	while(1)
	{
		if(mode)//RX模式
		{
			if(!mode_inited)
			{
				RX_Mode();
				mode_inited = 1;
			}
			if(NRF24L01_RxPacket(tmp_buf)==0)//一旦接收到信息,则显示出来.
			{
				tmp_buf[32]=0;//加入字符串结束符
				//for(i=0; tmp_buf[i]; i++)
				//	printf("%c", tmp_buf[i]);
				printf("%s", tmp_buf);
			}
			else
			{
				delay_us(1000);
				if(USART_RX_STA & 0x80)
				{
					for(i=0; i<(USART_RX_STA & 0x3F); i++)
					{
						tmp_buf[i] = USART_RX_BUF[i];
					}	
					for(i=(USART_RX_STA & 0x3F); i<32; i++)
					{
						tmp_buf[i] = 0x00;
					}	
					USART_RX_STA = 0;
					mode = 0;
					mode_inited = 0;
				}
			}
		}
		else//TX模式
		{	   			
			if(!mode_inited)
			{
				TX_Mode();
				mode_inited = 1;
			}			
			if(NRF24L01_TxPacket(tmp_buf)==TX_OK)
			{
				mode = 1;
				mode_inited = 0;
			}
			else
			{
				waitingforNRF24L01++;			
				if(waitingforNRF24L01 > 5)
				{
					mode = 1;
					mode_inited = 0;
				}
			}
			delay_ms(5);			
		}  
	}
}
