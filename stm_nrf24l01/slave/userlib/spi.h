#ifndef __SPI_H
#define __SPI_H
#include "sys.h"

void SPI1_Init(u8 SpeedSet);			 //��ʼ��SPI��
u8 SPI1_ReadWriteByte(u8 TxData);//SPI���߶�дһ���ֽ�
		 
#endif
