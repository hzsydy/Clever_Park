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
    public class Program : Microsoft.SPOT.Application
    {
        public class MainWindow : Window
        {
            #region 控件
            Panel panel = new Panel();
            Text text1 = new Text();
            Bitmap zyl = new Bitmap(Resources.GetBytes(Resources.BinaryResources.zhuyilin),
                Bitmap.BitmapImageType.Bmp);
            Image zyl_image = new Image();
            DispatcherTimer clockTimer;                     //相当于winform里面的timer
            #endregion

            #region 私有变量
            int grade;                                      //成绩
            int pos_x;                                      //朱奕霖头像位置
            int pos_y;
            bool zyl_caught = false;                        //到9999次会停止     
            #endregion

            public MainWindow()
            {
                #region 布置控件
                this.Child = panel;

                text1.TextContent = "您的得分：0";
                text1.TextWrap = true;
                text1.Font = Resources.GetFont(Resources.FontResources.msyh);
                text1.HorizontalAlignment = HorizontalAlignment.Center;
                text1.VerticalAlignment = VerticalAlignment.Bottom;
                panel.Children.Add(text1);

                zyl_image.Bitmap = zyl;
                panel.Children.Add(zyl_image);

                USART.Init("早上好");
                USART.onDataReceived += new USART._onDataReceived(onDataReceived);

                clockTimer = new DispatcherTimer(this.Dispatcher);
                clockTimer.Interval = new TimeSpan(0, 0, 0, 0, 500);
                clockTimer.Tick += new EventHandler(TimerTick);       
                clockTimer.Start();
                #endregion
            }

            private void onDataReceived(byte[] s, int len)
            {
                byte[] outbuf = new byte[len];
                for (int i = 0; i < len; i++ )
                {
                    outbuf[i] = s[i];
                }
                USART.outBuffer = outbuf;
                USART.SendData();
            }

            private void TimerTick(object sender, EventArgs e)
            {
                if (!zyl_caught)
                {
                    Random r = new Random();
                    int x = r.Next(4);
                    int y = r.Next(4);

                    pos_x = x * zyl.Width;
                    pos_y = y * zyl.Height;

                    zyl_image.Arrange(pos_x, pos_y, zyl.Width, zyl.Height);
                    text1.TextContent = "您的得分：" + grade.ToString();
                    Invalidate();  
                }
            }

            protected override void OnTouchDown(TouchEventArgs e)
            {
                base.OnTouchDown(e);

                int x;
                int y;
                e.GetPosition((UIElement)this, 0, out x, out y);

                if (!zyl_caught)
                {
                    if (x > pos_x && x < pos_x + zyl.Width)
                    {
                        if (y > pos_y && y < pos_y + zyl.Height)
                        {
                            grade++;
                            USART.SetOutBuffer("你成功膜拜了男神！");
                            USART.SendData();
                            if (grade == 9999)
                            {
                                zyl_caught = true;
                                text1.TextContent = "男神也是要休息的。。。";
                            }
                        }
                    }
                }
                e.Handled = true;
            }

            public override void OnRender(DrawingContext dc)
            {
                base.OnRender(dc);
            }
        }

        private MainWindow mainWindow;
        public static void Main()
        {
            Program myApplication = new Program();
            Touch.Initialize(myApplication);
            Window mainWindow = myApplication.CreateWindow();
            myApplication.Run(mainWindow);
        }
        public Window CreateWindow()
        {
            mainWindow = new MainWindow();
            mainWindow.Height = SystemMetrics.ScreenHeight;
            mainWindow.Width = SystemMetrics.ScreenWidth;
            mainWindow.Visibility = Visibility.Visible;
            Buttons.Focus(mainWindow);
            return mainWindow;
        }
    }
}
