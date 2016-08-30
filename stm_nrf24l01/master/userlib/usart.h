#ifndef __USART_H
#define __USART_H
#include "stdio.h"
#include "stm32f10x.h"


#define USART_REC_LEN 128				//接受数据最大字节数
extern u16 USART_RX_BUF[USART_REC_LEN-1];     //接收缓冲，最大USART_REC_LEN-1个字节，末字节为换行符
extern u8 USART_RX_STA;         //接收状态标记	
//最高位表示接收完成

void usart_init(u32 baud);
void USART1_IRQHandler(void);
void TIM1_UP_IRQHandler(void);
void newline(void);

#endif

