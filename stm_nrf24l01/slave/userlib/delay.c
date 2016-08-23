#include "delay.h"

static u8  fac_us=0;
static u16 fac_ms=0;

void delay_init(void)
{
	SysTick_CLKSourceConfig(SysTick_CLKSource_HCLK_Div8);
	fac_us=SystemCoreClock/8000000;		    
	fac_ms=(u16)fac_us*1000;
}

void delay_us(u32 nus)
{
	u32 temp;
	//关于以下部分参见systick->ctrl的说明
	SysTick->LOAD = nus * fac_us;							//时间加载
	SysTick->VAL = 0x00;											//清空计数器
	SysTick->CTRL |= SysTick_CTRL_ENABLE_Msk;	//打开计数器
	do
	{
		temp = SysTick->CTRL;
	}while((temp&0x01) && !(temp&(1<<16)));		//定时器开启&&时间到
	
	SysTick->CTRL &= ~SysTick_CTRL_ENABLE_Msk;//关闭计数器
	SysTick->VAL = 0x00;
}

void delay_ms(u16 nms)
{
	u32 temp;
	//关于以下部分参见systick->ctrl的说明
	SysTick->LOAD = nms * fac_ms;							//时间加载
	SysTick->VAL = 0x00;											//清空计数器
	SysTick->CTRL |= SysTick_CTRL_ENABLE_Msk;	//打开计数器
	do
	{
		temp = SysTick->CTRL;
	}while((temp&0x01) && !(temp&(1<<16)));		//定时器开启&&时间到
	
	SysTick->CTRL &= ~SysTick_CTRL_ENABLE_Msk;//关闭计数器
	SysTick->VAL = 0x00;
}
