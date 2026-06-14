# Legacy URLMon Download Bridge

A lightweight Windows utility that restores the classic Internet Explorer-era download dialog by directly invoking legacy `urlmon.dll` behavior, bypassing modern browser download UI layers.

This project is primarily for research, UI exploration, and compatibility experimentation with legacy Windows components.

---

## Overview

Modern Windows browsers (including IE11 shell on Windows 10/11) no longer expose the classic download dialog UI. Instead, they use integrated download managers.

This tool attempts to restore the older experience by:

- Bypassing `iexplore.exe` shell UI
- Directly leveraging legacy COM-based download behavior
- Running inside 32-bit (`SysWOW64`) context for compatibility
- Using `System.Windows.Forms.WebBrowser` to trigger legacy engine behavior

---

## Key Idea

Internet Explorer architecture can be roughly divided into:

- Shell Layer (`iexplore.exe`)
  - Address bar UI
  - Modern download manager

- Engine Layer (`mshtml.dll`, `urlmon.dll`)
  - HTML rendering
  - Network / download APIs

This project avoids the shell entirely and interacts with the engine layer only.

---

## Legacy Download Behavior

Historically, Windows used:

- urlmon.dll
- shdocvw.dll
- DoFileDownload-based flows

These components still exist in Windows 11 for backward compatibility, and in some cases still trigger the classic download dialog UI depending on execution context.

---

## How It Works

1. User right-clicks a download link in the browser
2. Context menu adds:
   - "Download via Legacy IE"
3. Browser extension sends URL to native host
4. Native host executes:
   - run_host.bat
5. Batch script:
   - Reads URL from JSON payload
   - Calls PowerShell
   - Launches compiled .NET executable
6. Executable:
   - Creates hidden WinForms process
   - Uses WebBrowser.Navigate(url)
   - Triggers legacy download stack

---

## Core C# Logic

using System.Windows.Forms;

Form f = new Form();
f.Opacity = 0;
f.ShowInTaskbar = false;
f.WindowState = FormWindowState.Minimized;

// Hidden UI host

WebBrowser wb = new WebBrowser();

// Legacy IE engine layer trigger
wb.Navigate(args[0]);

---

## Why 32-bit (SysWOW64)?

This tool must run under 32-bit context because:

- Legacy COM interfaces behave differently under WoW64
- Some URLMON behaviors are only reliably triggered in 32-bit host processes
- 64-bit execution may fall back to modern download handlers

---

## FEATURE_BROWSER_EMULATION Note

System.Windows.Forms.WebBrowser behavior depends on registry settings:

- Without configuration → legacy IE mode
- With emulation key → IE11 rendering mode

This project intentionally avoids forcing IE11 emulation.

---

## Installation

1. Download all project files to a local directory
   - Path must contain ASCII-only characters
2. Run Setup.bat as Administrator
3. Follow instructions

Installer will:
- Compile C# executable locally
- Register batch scripts
- Configure browser integration

---

## Browser Integration

Right-click any downloadable link:

Download via Legacy IE

Flow:
- Extract URL
- Send to native host
- Execute legacy download pipeline

---

## Compatibility

Vivaldi: Working (minor tweaks may be required)  
Microsoft Edge: Failing (native messaging issues)  
Chrome: Not tested  
Opera: Not tested  
Brave: Not tested  

---

## Safety Notes

- No external dependencies
- Source code is transparent
- Executable is built locally during setup

However:
- Not production software
- Future Windows updates may break behavior
- Use for research only

---

## Why Use This?

- Temporary-file download behavior (reduces clutter)
- Legacy Windows UI reproduction
- COM / URLMON research
- No VM required

---

## Disclaimer

Depends on legacy Windows behavior not guaranteed by Microsoft.

---

## License

No license. Research use only.
