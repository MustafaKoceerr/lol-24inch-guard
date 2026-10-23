# LoL24InchGuard.ps1
# 27" 2K (2560x1440) ekranda sadece League of Legends mac ekrani (League of Legends.exe) acikken
# oyunu tam ortada 24" (2276x1280) cercevesiz pencereye alir ve etrafini siyah perdeyle kapatir.

param(
    [int]$TargetWidth = 2276,
    [int]$TargetHeight = 1280
)

$ErrorActionPreference = "SilentlyContinue"

# Tek kopya (Single Instance) kontrolu
$mutexName = "Local\LoL24InchGuardMutex"
$createdNew = $false
$mutex = New-Object System.Threading.Mutex($true, $mutexName, [ref]$createdNew)
if (-not $createdNew) {
    exit 0
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class Win32LoL {
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern bool IsWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool IsIconic(IntPtr hWnd);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool GetClientRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool ClipCursor(ref RECT lpRect);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool ClipCursor(IntPtr lpRect);

    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);

    [DllImport("user32.dll")]
    public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

    public static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
    public static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
    public static readonly IntPtr HWND_TOP = new IntPtr(0);

    public const int GWL_STYLE = -16;
    public const int GWL_EXSTYLE = -20;

    public const int WS_CAPTION = 0x00C00000;
    public const int WS_THICKFRAME = 0x00040000;
    public const int WS_BORDER = 0x00800000;
    public const int WS_DLGFRAME = 0x00400000;
    public const int WS_POPUP = unchecked((int)0x80000000);
    public const int WS_VISIBLE = 0x10000000;

    public const uint SWP_NOSIZE = 0x0001;
    public const uint SWP_NOMOVE = 0x0002;
    public const uint SWP_NOZORDER = 0x0004;
    public const uint SWP_NOACTIVATE = 0x0010;
    public const uint SWP_FRAMECHANGED = 0x0020;
    public const uint SWP_SHOWWINDOW = 0x0040;
    public const uint SWP_HIDEWINDOW = 0x0080;

    public const int VK_MENU = 0x12; // Alt key
    public const int VK_LWIN = 0x5B; // Left Windows key
    public const int VK_TAB = 0x09;  // Tab key
}

public class BlackOverlayForm : Form {
    public BlackOverlayForm() {
        this.FormBorderStyle = FormBorderStyle.None;
        this.BackColor = System.Drawing.Color.Black;
        this.StartPosition = FormStartPosition.Manual;
        this.ShowInTaskbar = false;
        this.Text = "LoL24InchBlackOverlay";
    }

    protected override CreateParams CreateParams {
        get {
            CreateParams cp = base.CreateParams;
            // WS_EX_TOOLWINDOW (0x80) | WS_EX_NOACTIVATE (0x08000000)
            cp.ExStyle |= 0x00000080 | 0x08000000;
            return cp;
        }
    }

    protected override bool ShowWithoutActivation {
        get { return true; }
    }
}
"@ -ReferencedAssemblies System.Windows.Forms, System.Drawing

function Get-LoLConfigPath {
    $candidates = @(
        "C:\Riot Games\League of Legends\Config\game.cfg",
        "D:\Riot Games\League of Legends\Config\game.cfg",
        "E:\Riot Games\League of Legends\Config\game.cfg"
    )
    $riotInstalls = "C:\ProgramData\Riot Games\RiotClientInstalls.json"
    if (Test-Path $riotInstalls) {
        try {
            $json = Get-Content $riotInstalls -Raw | ConvertFrom-Json
            if ($json.associated_client) {
                foreach ($prop in $json.associated_client.PSObject.Properties) {
                    if ($prop.Name -like "*League of Legends*") {
                        $cfg = Join-Path ($prop.Name -replace '/', '\') "Config\game.cfg"
                        $candidates = @($cfg) + $candidates
                    }
                }
            }
        } catch {}
    }
    foreach ($path in $candidates) {
        if (Test-Path $path) {
            return $path
        }
    }
    return $candidates[0]
}

$CfgPath = Get-LoLConfigPath

function Ensure-LoLConfig {
    if (Test-Path $CfgPath) {
        $text = [System.IO.File]::ReadAllText($CfgPath)
        $updated = $text
        $updated = $updated -replace '(?m)^WindowMode=\d+\r?$', 'WindowMode=2'
        $updated = $updated -replace '(?m)^Height=\d+\r?$', "Height=$TargetHeight"
        $updated = $updated -replace '(?m)^Width=\d+\r?$', "Width=$TargetWidth"
        if ($updated -ne $text) {
            [System.IO.File]::WriteAllText($CfgPath, $updated)
        }
    }
}

Ensure-LoLConfig

$blackForm = New-Object BlackOverlayForm
$blackForm.CreateControl()
$blackHwnd = $blackForm.Handle

$wasFocused = $false
$wasRunning = $false

try {
    while ($true) {
        [System.Windows.Forms.Application]::DoEvents()

        $lolHwnd = [Win32LoL]::FindWindow("RiotWindowClass", [NullString]::Value)
        if ($lolHwnd -eq [IntPtr]::Zero) {
            $proc = Get-Process -Name "League of Legends" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($null -ne $proc -and $proc.MainWindowHandle -ne [IntPtr]::Zero) {
                $lolHwnd = $proc.MainWindowHandle
            }
        }

        $isValidGameWindow = ($lolHwnd -ne [IntPtr]::Zero) -and [Win32LoL]::IsWindow($lolHwnd) -and [Win32LoL]::IsWindowVisible($lolHwnd) -and (-not [Win32LoL]::IsIconic($lolHwnd))

        if (-not $isValidGameWindow) {
            if ($wasFocused -or $blackForm.Visible) {
                [void][Win32LoL]::ClipCursor([IntPtr]::Zero)
                $blackForm.Hide()
                $wasFocused = $false
            }
            if ($wasRunning -and ($lolHwnd -eq [IntPtr]::Zero)) {
                Ensure-LoLConfig
                $wasRunning = $false
            }
            Start-Sleep -Milliseconds 1000
            continue
        }

        $wasRunning = $true
        $screen = [System.Windows.Forms.Screen]::FromHandle($lolHwnd).Bounds

        # Sadece hedef cozunurlukten daha buyuk ekranda (or. 27" 2K) ortalama uygula
        if ($screen.Width -le $TargetWidth -or $screen.Height -le $TargetHeight) {
            Start-Sleep -Milliseconds 1000
            continue
        }

        $targetX = $screen.X + [int](($screen.Width - $TargetWidth) / 2)
        $targetY = $screen.Y + [int](($screen.Height - $TargetHeight) / 2)

        # Pencere kenarliklarini kaldir (Borderless)
        $style = [Win32LoL]::GetWindowLong($lolHwnd, [Win32LoL]::GWL_STYLE)
        $borderMask = [Win32LoL]::WS_CAPTION -bor [Win32LoL]::WS_THICKFRAME -bor [Win32LoL]::WS_BORDER -bor [Win32LoL]::WS_DLGFRAME
        if (($style -band $borderMask) -ne 0) {
            $newStyle = ($style -band (-bnot $borderMask)) -bor [Win32LoL]::WS_POPUP -bor [Win32LoL]::WS_VISIBLE
            [void][Win32LoL]::SetWindowLong($lolHwnd, [Win32LoL]::GWL_STYLE, $newStyle)
        }

        # Oyun penceresinin boyutu ve konumu 2276x1280 (X=142, Y=80) degilse merkeze tasi
        $winRect = New-Object Win32LoL+RECT
        [void][Win32LoL]::GetWindowRect($lolHwnd, [ref]$winRect)
        $curW = $winRect.Right - $winRect.Left
        $curH = $winRect.Bottom - $winRect.Top

        # Yükleme ekrani öncesi kücük splash penceresiyse (ör. < 800px) dokunma
        if ($curW -lt 800 -or $curH -lt 600) {
            Start-Sleep -Milliseconds 300
            continue
        }

        $needsMove = ($winRect.Left -ne $targetX) -or ($winRect.Top -ne $targetY) -or ($curW -ne $TargetWidth) -or ($curH -ne $TargetHeight)
        if ($needsMove) {
            [void][Win32LoL]::SetWindowPos(
                $lolHwnd,
                [Win32LoL]::HWND_TOP,
                $targetX,
                $targetY,
                $TargetWidth,
                $TargetHeight,
                [Win32LoL]::SWP_NOACTIVATE -bor [Win32LoL]::SWP_FRAMECHANGED -bor [Win32LoL]::SWP_SHOWWINDOW
            )
            # LoL'e yeni pencere koordinatini bildir (WM_MOVE = 0x0003)
            $lParam = [IntPtr](($targetY -shl 16) -bor ($targetX -band 0xFFFF))
            [void][Win32LoL]::PostMessage($lolHwnd, 0x0003, [IntPtr]::Zero, $lParam)
        }

        $fgHwnd = [Win32LoL]::GetForegroundWindow()
        $altPressed = ([Win32LoL]::GetAsyncKeyState([Win32LoL]::VK_MENU) -band 0x8000) -ne 0
        $winPressed = ([Win32LoL]::GetAsyncKeyState([Win32LoL]::VK_LWIN) -band 0x8000) -ne 0

        if ($fgHwnd -eq $lolHwnd -and (-not $winPressed)) {
            if (-not $wasFocused -or -not $blackForm.Visible) {
                $blackForm.Bounds = $screen
                $blackForm.Show()
                # Siyah arka plani görev cubugunu da kapatacak sekilde TOPMOST yap, hemen üstüne LoL'ü TOPMOST koy
                [void][Win32LoL]::SetWindowPos(
                    $blackHwnd,
                    [Win32LoL]::HWND_TOPMOST,
                    $screen.X,
                    $screen.Y,
                    $screen.Width,
                    $screen.Height,
                    [Win32LoL]::SWP_NOACTIVATE -bor [Win32LoL]::SWP_SHOWWINDOW
                )
                [void][Win32LoL]::SetWindowPos(
                    $lolHwnd,
                    [Win32LoL]::HWND_TOPMOST,
                    $targetX,
                    $targetY,
                    $TargetWidth,
                    $TargetHeight,
                    [Win32LoL]::SWP_NOACTIVATE -bor [Win32LoL]::SWP_SHOWWINDOW
                )
                $wasFocused = $true
            }

            if ($altPressed) {
                [void][Win32LoL]::ClipCursor([IntPtr]::Zero)
            } else {
                $clipRect = New-Object Win32LoL+RECT
                $clipRect.Left = $targetX
                $clipRect.Top = $targetY
                $clipRect.Right = $targetX + $TargetWidth
                $clipRect.Bottom = $targetY + $TargetHeight
                [void][Win32LoL]::ClipCursor([ref]$clipRect)
            }
        } else {
            if ($wasFocused -or $blackForm.Visible) {
                [void][Win32LoL]::ClipCursor([IntPtr]::Zero)
                [void][Win32LoL]::SetWindowPos(
                    $lolHwnd,
                    [Win32LoL]::HWND_NOTOPMOST,
                    0, 0, 0, 0,
                    [Win32LoL]::SWP_NOMOVE -bor [Win32LoL]::SWP_NOSIZE -bor [Win32LoL]::SWP_NOACTIVATE
                )
                $blackForm.Hide()
                if ($fgHwnd -ne [IntPtr]::Zero -and $fgHwnd -ne $lolHwnd) {
                    [void][Win32LoL]::SetWindowPos(
                        $fgHwnd,
                        [Win32LoL]::HWND_TOP,
                        0, 0, 0, 0,
                        [Win32LoL]::SWP_NOMOVE -bor [Win32LoL]::SWP_NOSIZE -bor [Win32LoL]::SWP_NOACTIVATE
                    )
                }
                $wasFocused = $false
            }
        }

        Start-Sleep -Milliseconds 80
    }
} finally {
    [void][Win32LoL]::ClipCursor([IntPtr]::Zero)
    if ($null -ne $blackForm) {
        $blackForm.Close()
    }
    if ($null -ne $mutex) {
        $mutex.ReleaseMutex()
        $mutex.Dispose()
    }
}
