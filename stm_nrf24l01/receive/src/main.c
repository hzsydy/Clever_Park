#include "stm32f10x.h"
#include "usart.h"
#include "sys.h"
#include "delay.h"
#include "NRF24L01.h"

int main(void)
{
	u8 tmp_buf[33];
	u8 mode = 1;
	u8 waitingforNRF24L01 = 0;
	delay_init();
	NVIC_Configuration();
	usart_init(9600);
	NRF24L01_Init();
	
	while(NRF24L01_Check())//��ⲻ��24L01
	{
		waitingforNRF24L01++;
		if(waitingforNRF24L01 > 5)printf("Cannot find NRF24L01,please @110\n");
		delay_ms(500);
	}
	
	printf("110 arrived in %d time\n", waitingforNRF24L01);
	
	if(mode==0)//RXģʽ
	{
		RX_Mode();		  
		while(1)
		{	  		    		    				 
			if(NRF24L01_RxPacket(tmp_buf)==0)//һ�����յ���Ϣ,����ʾ����.
			{
				tmp_buf[32]=0;//�����ַ���������
				printf("%s/n", tmp_buf);
				
			}
			else
			{
				delay_us(100);
			}
		}
	}
	else//TXģʽ
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
