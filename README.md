Internet Explorer tightly connected to Windows Shell.
So, it is difficult to enjoy IE experiences, especially older version than that was built-in inside Windows version you're using. For example, you can use IE9, 10, 11 on Windows 8, however, not 6 or 8.
However, Windows has some legacy assets inside itself for compatibility, which we can research.
I wanted to see -IE8 style downloader, which includes its own pop-up dialog, as well as the animation of paper flying from the globe to your folder, so I tried to immitate it.
While using the securities trading program, I suddenly faced what I wanted. IE8, not IE9+, the old style still exists in Windows 11!
There are some famous ways to override regulations and execute Internet Explorer Window in Windows 11, such as VBScript. But it is IE11, whose download dialog appears at the bottom of the window, simillar to other modern browsers.
So I observed how the HTS(Home Trading System)'s news article viewer/downloader works to call the vintage dialog.
I found that I must call the urlmon.dll directly, bypassing IE11. Also, calling it on 64-bit system fails to make it. So, I made a script to execute urlmon.dll in the SysWOW64 32-bit subsystem.
I defined arguments to send the URL to the dll, and all other options.

Why should you use my program?
1. Modern browsers don't provide an option to save as temporary file and just 'open' it. Even if you click 'Open', it will just save at your disk and open the file. So your download folder will soon be full of disposable installers, documents, or other unknown garbages. You can make the file be saved inside temporary directory, and be automatically deleted when you power off the computer.
2. You don't have to use Virtual Machines to touch vintage computing environments. It coexists with modern Windows, and will show you a beautiful harmony containing the history of Windows.

How to use?
I have made a installer batch file for you.
1. Download all files to the directory wherever you want the program to be installed, but it's path must contain ONLY ASCII characters.
2. Run the 'Setup.bat' in the root directory as an Administrator permission.
3. Follow the instructions.

How it works?
Just right-click on the download link you want. Then there will be an option of "Download via Legacy IE". Click it.
The browser will connect to the extension and provide the address. The extension will execute run_host.bat, while obtaining the URL in its JSON file.
The run_host.bat sets its working directory correctly, and executes the PowerShell script.
The PowerShell script will find the URL in the JSON file, and set as an argument. After that, it will call the exe file that deserves to call the urlmon.dll.

Is it safe?
Since it is not a commercial software, i don't gurantee anything about future risks. However, there is no virus or anything not good for your computer. I attached the C# source of the exe file, the only thing you cannot view source directly.
Its logic is below:
Form f = new Form(); f.Opacity = 0; f.ShowInTaskbar = false; f.WindowState = FormWindowState.Minimized;
This create an invisible window, which also doesn't appear at the taskbar.

WebBrowser wb = new WebBrowser();
This calls the hidden legacy layer of

wb.Navigate(args[0]);
PowerShell 브릿지가 넘겨준 다운로드 URL(args[0])을 이 투명한 IE 엔진에게 "이 주소로 접속해!"라고 명령합니다.
