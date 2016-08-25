using System;
using System.Windows.Forms;
using System.Text;
using System.IO.Ports;
using System.Threading;
using System.Collections.Generic;

namespace SerialPort_HomeworkWeGoFor
{
    public partial class MainForm : Form
    {
        private SerialPort _sp;

        public MainForm()
        {
            InitializeComponent();
            this.DoubleBuffered = true;
            _sp = new SerialPort();
            _sp.DataReceived += _sp_DataReceived;
            _sp.ReadTimeout = 500;
            _sp.WriteTimeout = 500;
            _sp.BaudRate = 9600;
            _sp.StopBits = StopBits.One;
            _sp.Parity = Parity.None;
            _sp.DataBits = 8;

            _curCode = _GB2312;
        }

        byte[] manual = new byte[] { 0x30, 0x0d, 0x0a };
        byte[] go_ahead = new byte[] { 0x57, 0x0d, 0x0a };
        byte[] go_back = new byte[] { 0x53, 0x0d, 0x0a };
        byte[] go_left = new byte[] { 0x41, 0x0d, 0x0a };
        byte[] go_right = new byte[] { 0x44, 0x0d, 0x0a };
        byte[] autorun = new byte[] { 0x30, 0x0d, 0x0a };
        byte[] stop = new byte[] { 0x30, 0x0d, 0x0a };


        bool isBufferReceived = false;
        List<byte> _buf = new List<byte>();
        void _sp_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            //button1.Enabled = false;
            int bytesToRead = _sp.BytesToRead;
            byte[] buf = new byte[bytesToRead];
            try
            {
                _sp.Read(buf, 0, bytesToRead);
            }
            catch (Exception ex)
            {
                //button1.Enabled = true;
                return;
            }

            for (int i = 0; i < bytesToRead; i++ )
            {
                _buf.Add(buf[i]);
            }
            isBufferReceived = true;
            //button1.Enabled = true;
        }

        private bool isPortLegal()
        {
            #region portname
            string _portname = "";
            string[] _legalports = SerialPort.GetPortNames();
            foreach (string s in _legalports)
            {
                if (s.Equals(comboBox1.Text))
                {
                    _portname = s;
                    break;
                }
            }
            if (_portname != "")
            {
                _sp.PortName = _portname;
            }
            else
            {
                textBox1.Text += Environment.NewLine + "不存在的端口号！无法开启";
                return false;
            }
            #endregion
            return true;
        }
        private void checkPortName()
        {
            comboBox1.Items.Clear();
            string[] ports = SerialPort.GetPortNames();
            Array.Sort(ports);
            
            if (ports.Length > 0)
            {
                foreach (string port in ports)
                {
                    comboBox1.Items.Add(port);
                }
                comboBox1.SelectedIndex = 0;
            }
        }
        private void button1_Click(object sender, EventArgs e)
        {
            if (_sp.IsOpen)
            {
                try
                {
                    _sp.Close();
                }
                catch (Exception ex)
                {
                    textBox1.Text += Environment.NewLine + ex.Message;
                    return;
                }
                if (!_sp.IsOpen)
                {
                    textBox1.Text += Environment.NewLine;
                    textBox1.Text += "端口已经关闭";
                    textBox1.Text += Environment.NewLine;
                    button1.Text = "Open";
                }  
            } 
            else
            {
                if (!isPortLegal())
                {
                    return;
                }
                try
                {
                    _sp.Open();
                }
                catch (Exception ex)
                {
                    textBox1.Text += Environment.NewLine + ex.Message;
                    return;
                }
                if (_sp.IsOpen)
                {
                    textBox1.Text = "";
                    textBox1.Text += "端口成功打开！在" + _sp.PortName + "上监听中";
                    textBox1.Text += Environment.NewLine;
                    button1.Text = "Close";
                }  
            }
        }
        private void textBox1_TextChanged(object sender, EventArgs e)
        {
            textBox1.SelectionStart = textBox1.Text.Length;
            textBox1.ScrollToCaret();
        }


        private Encoding _GB2312 = Encoding.GetEncoding("GB2312");
        private Encoding _Unicode = Encoding.GetEncoding("Unicode");
        private Encoding _UTF_8 = Encoding.GetEncoding("UTF-8");
        private Encoding _curCode;
        private bool ishex = false;

        private void button2_Click(object sender, EventArgs e)
        {
            if (_sp.IsOpen)
            {
                button1.Enabled = false;
                try
                {
                    byte[] _writebuf = _curCode.GetBytes(textBox2.Text);
                    _sp.Write(_writebuf, 0 ,_writebuf.Length);
                }
                catch { }
                finally
                {
                    button1.Enabled = true;
                    textBox2.Text = "";
                }
            }
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (isBufferReceived)
            {
                byte[] buf = new byte[_buf.Count];
                int i = 0;
                foreach (byte b in _buf)
                {
                    buf[i] = b;
                    i++;
                }
                _buf.Clear();
                if (ishex)
                {
                    foreach (byte b in buf)
                    {
                        textBox1.Text += b.ToString("x") + Environment.NewLine;
                    }
                } 
                else
                {
                    textBox1.Text += _curCode.GetString(buf);
                }
                

                isBufferReceived = false;
                timer1.Enabled = true;
            }
        }

        private void radioButton1_CheckedChanged(object sender, EventArgs e)
        {
            ishex = false;
            _curCode = _GB2312;
        }

        private void radioButton2_CheckedChanged(object sender, EventArgs e)
        {
            ishex = false;
            _curCode = _Unicode;
        }

        private void radioButton3_CheckedChanged(object sender, EventArgs e)
        {
            ishex = false;
            _curCode = _UTF_8;
        }

        private void button3_Click(object sender, EventArgs e)
        {
            textBox1.Text = "";
        }

        private void MainForm_Resize(object sender, EventArgs e)
        {
            textBox1.Width = this.Width - textBox1.Left - 40;
        }

        private void radioButton4_CheckedChanged(object sender, EventArgs e)
        {
            ishex = true;
        }

        private void button4_Click(object sender, EventArgs e)
        {
            checkPortName();
        }

        private void textBox3_KeyDown(object sender, KeyEventArgs e)
        {
            switch (e.KeyCode)
            {
                case Keys.Enter:
                    button2_Click(sender, e);
                    e.Handled = true;
                    textBox3.Text = "";
                    break;
                case Keys.A:
                    if (_sp.IsOpen)
                    {
                        try
                        {
                            _sp.Write(go_left, 0, go_left.Length);
                        }
                        catch { }
                    }
                    e.Handled = true;
                    textBox3.Text = "";
                    break;
                case Keys.S:
                    if (_sp.IsOpen)
                    {
                        try
                        {
                            _sp.Write(go_back, 0, go_back.Length);
                        }
                        catch { }
                    }
                    e.Handled = true;
                    textBox3.Text = "";
                    break;
                case Keys.D:
                    if (_sp.IsOpen)
                    {
                        try
                        {
                            _sp.Write(go_right, 0, go_right.Length);
                        }
                        catch { }
                    }
                    e.Handled = true;
                    textBox3.Text = "";
                    break;
                case Keys.W:
                    if (_sp.IsOpen)
                    {
                        try
                        {
                            _sp.Write(go_ahead, 0, go_ahead.Length);
                        }
                        catch { }
                    }
                    e.Handled = true;
                    textBox3.Text = "";
                    break;
                case Keys.D0:
                case Keys.NumPad0:
                    if (_sp.IsOpen)
                    {
                        try
                        {
                            _sp.Write(manual, 0, manual.Length);
                        }
                        catch { }
                    }
                    e.Handled = true;
                    textBox3.Text = "";
                    break;
            }
            //
        }






    }
}
