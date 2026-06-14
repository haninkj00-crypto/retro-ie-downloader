using System;
using System.Windows.Forms;

class P {
    [STAThread]
    static void Main(string[] args) {
        if (args.Length == 0) return;
        Application.EnableVisualStyles();

        Form f = new Form();
        f.Opacity = 0;
        f.ShowInTaskbar = false;
        f.WindowState = FormWindowState.Minimized;

        WebBrowser wb = new WebBrowser();
        f.Controls.Add(wb);

        f.Load += delegate { wb.Navigate(args[0]); };
        Application.Run(f);
    }
}