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

u16 USART_RX_BUF[USART_REC_LEN-1];     //���ջ��壬���63���ֽڣ�ĩ�ֽ�Ϊ���з�
//USART_RX_STA
//bit15������ɱ�־
//bit14���յ�0X0D��־
//bit13~0���յ�����Ч���ݸ���
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
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;										//�����������
	GPIO_Init(GPIOA, &GPIO_InitStructure);

	//USART1_RX	  PA.10
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_10;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;							//��������
	GPIO_Init(GPIOA, &GPIO_InitStructure);  

	//Usart1 NVIC ����

	NVIC_InitStructure.NVIC_IRQChannel = USART1_IRQn;
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 3 ;
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 3;
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;			
	NVIC_Init(&NVIC_InitStructure);	

	//USART init

	USART_InitStructure.USART_BaudRate = baud;//һ��Ϊ9600;
	USART_InitStructure.USART_WordLength = USART_WordLength_8b;
	USART_InitStructure.USART_StopBits = USART_StopBits_1;						//һ��ֹͣλ
	USART_InitStructure.USART_Parity = USART_Parity_No;								//��У��
	USART_InitStructure.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
	USART_InitStructure.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;		//�շ�ģʽ

	USART_Init(USART1, &USART_InitStructure);
	USART_ITConfig(USART1, USART_IT_RXNE, ENABLE);										//�����ж�
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
//			//while(USART_GetFlagStatus(USART1, USART_FLAG_TC) != SET){;}	//USART_FLAG_TC�Ƿ������λ
//			printf("%c", USART_RX_BUF[i]);
//		}
//		USART_RX_STA = 0;
//	}
//  TIM_ClearITPendingBit(TIM1, TIM_IT_Update); 
//}

void USART1_IRQHandler(void)                	//����1�жϷ������
{
	u8 Res;
	if(USART_GetITStatus(USART1, USART_IT_RXNE) != RESET)  //�����ж�(���յ������ݱ�����0x0d 0x0a��β)
	{
		Res =USART_ReceiveData(USART1);//(USART1->DR);	//��ȡ���յ�������

		if((USART_RX_STA&0x80)==0)//����δ���
		{
			if(USART_RX_STA&0x40)//���յ���0x0d
			{
				if(Res!=0x0a)USART_RX_STA=0;//���մ���,���¿�ʼ
				else USART_RX_STA|=0x80;	//��������� 
			}
			else //��û�յ�0X0D
			{	
				if(Res==0x0d)USART_RX_STA|=0x40;
				else
				{
					USART_RX_BUF[USART_RX_STA&0X3F]=Res ;
					USART_RX_STA++;
					if(USART_RX_STA>30)
					{
						USART_RX_STA=0;//�������ݴ���,���¿�ʼ����	 
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

