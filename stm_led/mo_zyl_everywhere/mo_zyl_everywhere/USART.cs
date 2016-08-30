using System;
using System.Text;
using System.IO.Ports;
using Microsoft.SPOT;
using Microsoft.SPOT.Input;
using Microsoft.SPOT.Presentation;
using Microsoft.SPOT.Presentation.Media;
using Microsoft.SPOT.Presentation.Controls;
using Microsoft.SPOT.Hardware;
using Microsoft.SPOT.Touch;
using STM32F429I_Discovery.Netmf.Hardware;

namespace mo_zyl_everywhere
{
    public class USART
    {
        static SerialPort serialPort;
        static int NbrReceivedBytes = 0;
        public static byte[] outBuffer { get; set; }
        const int MaxBufLen = 128;
        static byte[] inBuffer = new byte[MaxBufLen];

        public delegate void _onDataReceived(byte[] s, int len);
        public static _onDataReceived onDataReceived { set; get; }

        /// <summary>
        /// 初始化函数
        /// </summary>
        /// <param name="s">初始化结束后发送字符串的内容</param>
        public static void Init(string s = "")
        {
            outBuffer = Encoding.UTF8.GetBytes(s + "\r\n");

            /* Configure the USART1 (COM1):
            * RX pin (PA10)  
            * TX pin (PA9)
            * BaudRate = 9600 baud  
            * Word Length = 8 Bits (default settings)
            * One Stop Bit         (default settings)
            * Parity none          (default settings)
            * Hardware flow control disabled (default settings)
            */
            serialPort = new SerialPort(SerialPorts.SerialCOM1, 9600);
            serialPort.DataReceived += new SerialDataReceivedEventHandler(DataReceived_Interrupt);
            serialPort.Open();
            serialPort.Write(outBuffer, 0, outBuffer.Length);
        }

        private static void DataReceived_Interrupt(object com, SerialDataReceivedEventArgs arg)
        {
            /*Read received data */
            NbrReceivedBytes = serialPort.Read(inBuffer, 0, inBuffer.Length);
            onDataReceived(inBuffer, NbrReceivedBytes);
        }

        private static bool CmpBuffers(byte[] Buf1, byte[] Buf2, int Length)
        {
            for (int i = 0; i < Length; i++)
            {
                if (Buf1[i] != Buf2[i])
                    return false;
            }
            return true;
        }

        public static void SendData()
        {
            serialPort.Write(outBuffer, 0, outBuffer.Length);
        }

        public static void SetOutBuffer(string s = "")
        {
            outBuffer = Encoding.UTF8.GetBytes(s + "\r\n");
        }
    }
}
