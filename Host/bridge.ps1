$log = Join-Path -Path $PSScriptRoot -ChildPath "host_log.txt"
function Out-Log($m) { Add-Content -Path $log -Value "$((Get-Date).ToString('HH:mm:ss')) | $m" }

$stdin = [System.Console]::OpenStandardInput()
$lenBuf = New-Object byte[] 4

Out-Log "Detached Bridge Active"

while ($true) {
    $read = $stdin.Read($lenBuf, 0, 4)
    if ($read -lt 4) { break }

    $len = [System.BitConverter]::ToUInt32($lenBuf, 0)
    if ($len -gt 0) {
        $msgBuf = New-Object byte[] $len
        $null = $stdin.Read($msgBuf, 0, $len)
        $url = ([System.Text.Encoding]::UTF8.GetString($msgBuf) | ConvertFrom-Json).url

        if ($url) {
            Out-Log "URL Received: $url"
            
            # [URLMon Bridge Execution]
            # Bypass the modern browser sandbox by directly invoking a hidden Win32 Shell object.
            # This forces the OS to launch the legacy 32-bit URLMon download dialog natively.
            $exePath = Join-Path -Path $PSScriptRoot -ChildPath "os_file_download.exe"
            $args = "`"$url`""

            $shell = New-Object -ComObject Shell.Application
            $shell.ShellExecute($exePath, $args, "", "open", 1)

            Out-Log "Escaped Blink Tree & Launched Natively"
        }
    }
}