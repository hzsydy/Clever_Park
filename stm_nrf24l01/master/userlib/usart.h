#ifndef __USART_H
#define __USART_H
#include "stdio.h"
#include "stm32f10x.h"


#define USART_REC_LEN 128				//������������ֽ���
extern u16 USART_RX_BUF[USART_REC_LEN-1];     //���ջ��壬���USART_REC_LEN-1���ֽڣ�ĩ�ֽ�Ϊ���з�
extern u8 USART_RX_STA;         //����״̬���	
//���λ��ʾ�������

void usart_init(u32 baud);
void USART1_IRQHandler(void);
void TIM1_UP_IRQHandler(void);
void newline(void);

#endif

