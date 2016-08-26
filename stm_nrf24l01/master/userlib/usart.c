#include "sys.h"
#include "usart.h"

//printf support

#if 1
#pragma import(__use_no_semihosting)                           
struct __FILE 
{ 
	int handle; 
}; 
FILE __stdout;       
void _sys_exit(int x) 
{ 
	x = x; 
}
int fputc(int ch, FILE *f)
{      
	while((USART1->SR&0X40)==0){};
	USART1->DR = (u8) ch;      
	return ch;
}
#endif 

u16 USART_RX_BUF[USART_REC_LEN-1];     //接收缓冲，最大63个字节，末字节为换行符
//USART_RX_STA
//bit15接收完成标志
//bit14接收到0X0D标志
//bit13~0接收到的有效数据个数
u8 USART_RX_STA = 0;

u16 receivedAByte = 0;

void usart_init(u32 baud)
{
	GPIO_InitTypeDef GPIO_InitStructure;
	USART_InitTypeDef USART_InitStructure;
	NVIC_InitTypeDef NVIC_InitStructure;
	//TIM_TimeBaseInitTypeDef TIM_TimeBaseStructure;
	//
	//RCC_APB2PeriphClockCmd(RCC_APB2Periph_TIM1, ENABLE );
	//TIM_DeInit(TIM1);
	//TIM_TimeBaseStructure.TIM_Prescaler = 287;                                                                        
	//TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up; 
	//TIM_TimeBaseStructure.TIM_Period = 1000*25;	             
	//TIM_TimeBaseStructure.TIM_ClockDivision = 0;			  
	//TIM_TimeBaseStructure.TIM_RepetitionCounter = 0x0;		  
	//TIM_TimeBaseInit(TIM1,&TIM_TimeBaseStructure);	        
	//TIM_ClearFlag(TIM1, TIM_FLAG_Update);      
	//TIM_ITConfig(TIM1, TIM_IT_Update, ENABLE); 
	//TIM_Cmd(TIM1, ENABLE); 
	//
	//NVIC_PriorityGroupConfig(NVIC_PriorityGroup_0);
	//NVIC_InitStructure.NVIC_IRQChannel = TIM1_UP_IRQn;  
	//NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;  
	//NVIC_InitStructure.NVIC_IRQChannelSubPriority = 2;         
	//NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;            
	//NVIC_Init(&NVIC_InitStructure);  

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1|RCC_APB2Periph_GPIOA|RCC_APB2Periph_AFIO, ENABLE);
	//USART1_TX   PA.9
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_9;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;										//复用推挽输出
	GPIO_Init(GPIOA, &GPIO_InitStructure);

	//USART1_RX	  PA.10
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_10;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;							//浮空输入
	GPIO_Init(GPIOA, &GPIO_InitStructure);  

	//Usart1 NVIC 配置

	NVIC_InitStructure.NVIC_IRQChannel = USART1_IRQn;
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 3 ;
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 3;
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;			
	NVIC_Init(&NVIC_InitStructure);	

	//USART init

	USART_InitStructure.USART_BaudRate = baud;//一般为9600;
	USART_InitStructure.USART_WordLength = USART_WordLength_8b;
	USART_InitStructure.USART_StopBits = USART_StopBits_1;						//一个停止位
	USART_InitStructure.USART_Parity = USART_Parity_No;								//不校验
	USART_InitStructure.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
	USART_InitStructure.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;		//收发模式

	USART_Init(USART1, &USART_InitStructure);
	USART_ITConfig(USART1, USART_IT_RXNE, ENABLE);										//开启中断
	USART_Cmd(USART1, ENABLE);                    
}

//void TIM1_UP_IRQHandler(void)
//{
//	u16 i;
//	if(USART_RX_STA > 0 && !(USART_RX_STA & 0x80))
//	{
//		USART_RX_STA |= 0x80;
//	}
//	if(USART_RX_STA & 0x80)
//	{
//		printf("\r\n(PC)");
//		for(i=0; i<USART_RX_STA; i++)
//		{
//			//USART_SendData(USART1, USART_RX_BUF[i]);
//			//while(USART_GetFlagStatus(USART1, USART_FLAG_TC) != SET){;}	//USART_FLAG_TC是发送完成位
//			printf("%c", USART_RX_BUF[i]);
//		}
//		USART_RX_STA = 0;
//	}
//  TIM_ClearITPendingBit(TIM1, TIM_IT_Update); 
//}

void USART1_IRQHandler(void)                	//串口1中断服务程序
{
	u8 Res;
	if(USART_GetITStatus(USART1, USART_IT_RXNE) != RESET)  //接收中断(接收到的数据必须是0x0d 0x0a结尾)
	{
		Res =USART_ReceiveData(USART1);//(USART1->DR);	//读取接收到的数据

		if((USART_RX_STA&0x80)==0)//接收未完成
		{
			if(USART_RX_STA&0x40)//接收到了0x0d
			{
				if(Res!=0x0a)USART_RX_STA=0;//接收错误,重新开始
				else USART_RX_STA|=0x80;	//接收完成了 
			}
			else //还没收到0X0D
			{	
				if(Res==0x0d)USART_RX_STA|=0x40;
				else
				{
					USART_RX_BUF[USART_RX_STA&0X3F]=Res ;
					USART_RX_STA++;
					if(USART_RX_STA>30)
					{
						USART_RX_STA=0;//接收数据错误,重新开始接收	 
						printf("too many words"); newline();
					}
				}		 
			}
		}   		 
	} 
} 

void newline(void)
{
	printf("%c%c%c", (char)0x0d, (char)0x0a, (char)0);	
}

