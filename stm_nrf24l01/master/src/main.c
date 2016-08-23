#include "stm32f10x.h"
#include "usart.h"
#include "sys.h"
#include "delay.h"
#include "NRF24L01.h"

void newline()
{
	printf("%c%c", (char)0x0d, (char)0x0a);	
}

int main(void)
{
	u8 i;
	u8 tmp_buf[33];
	u8 mode = 1;
	u8 mode_inited = 0;
	u8 waitingforNRF24L01 = 0;
	delay_init();
	NVIC_Configuration();
	usart_init(9600);
	NRF24L01_Init();

	while(NRF24L01_Check())//检测不到24L01
	{
		waitingforNRF24L01++;
		if(waitingforNRF24L01 > 5)
		{
			printf("Cannot find NRF24L01,please @110\n");
			newline();
		}
		delay_ms(500);
	}

	printf("find NRF24L01 successfully");
	newline();
	waitingforNRF24L01 = 0;

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
	
	// master: at tx only if get pc input
	
	mode = 1;

	while(1)
	{
		if(mode)//RX模式
		{
			if(!mode_inited)
			{
				RX_Mode();
				printf("Rx mode");
				newline();
				mode_inited = 1;
			}
			if(NRF24L01_RxPacket(tmp_buf)==0)//一旦接收到信息,则显示出来.
			{
				tmp_buf[32]=0;//加入字符串结束符
				printf("(24L01)%s", tmp_buf);			
				newline();				
			}
			else
			{
				delay_us(1000);
				if(USART_RX_STA & 0x80)
				{
					printf("(PC)");
					for(i=0; i<USART_RX_STA; i++)
					{
						printf("%c", USART_RX_BUF[i]);
					}
					newline();
					for(i=0; i<29; i++)
					{
						tmp_buf[i] = USART_RX_BUF[i];
					}
					tmp_buf[29] = 0x0d;
					tmp_buf[30] = 0x0a;				
					tmp_buf[31] = 0x00;
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
				printf("Tx mode");newline();
				mode_inited = 1;
			}			
			if(NRF24L01_TxPacket(tmp_buf)==TX_OK)
			{
				printf("Send succeed");newline();
				mode = 1;
				mode_inited = 0;
			}
			else
			{										   	
				printf("Send failed a %d time", waitingforNRF24L01);
				newline();
				waitingforNRF24L01++;			
				if(waitingforNRF24L01 > 5)
				{
					printf("give up.");newline();
					mode = 1;
					mode_inited = 0;
				}
			}
			delay_ms(200);			
		}  
	}

}
