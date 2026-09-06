# ==============================================================================
# PersianAntigravityIDE - فارسی ساز محیط توسعه آنتی گرویتی
# Setup & Automation Script (Windows)
# ==============================================================================
# Project: https://github.com/mehdichamani/PersianAntigravityIDE
# Author:  Mehdi Chamani
# License: MIT
# Target:  Antigravity IDE (Windows PowerShell 7+)
# ==============================================================================

function Setup-PersianAntigravityIDE {
    [CmdletBinding(DefaultParameterSetName = 'Install')]
    param(
        [Parameter(ParameterSetName = 'Install')]
        [switch]$Install,

        [Parameter(ParameterSetName = 'Uninstall')]
        [switch]$Uninstall,

        [Parameter(ParameterSetName = 'Status')]
        [switch]$Status,

        [Parameter()]
        [ValidateSet('fa', 'en')]
        [string]$Lang,

        [Parameter()]
        [string]$AppDir
    )

    $ErrorActionPreference = 'Stop'

    # Language Selection (Persian text test / Terminal compatibility)
    if (-not $Lang) {
        Write-Host ""
        Write-Host "======================================================================" -ForegroundColor Cyan
        Write-Host "به پروژه فارسی ساز محیط توسعه آنتی گرویتی (PersianAntigravityIDE) خوش آمدید!" -ForegroundColor White
        Write-Host "اگر این متن فارسی را بدون به‌هم‌ریختگی می‌بینید، با فارسی ادامه دهید." -ForegroundColor Yellow
        Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "If the Persian text above looks garbled or broken, continue in English." -ForegroundColor White
        Write-Host "======================================================================" -ForegroundColor Cyan
        Write-Host "  [1] فارسی (Persian)" -ForegroundColor White
        Write-Host "  [2] English [Default]" -ForegroundColor White
        Write-Host ""

        $choice = Read-Host "Select language / انتخاب زبان [1/2] (Default: 2)"
        if ($choice -match '^\s*1\s*$') {
            $Lang = 'fa'
            Write-Host "زبان فارسی انتخاب شد.`n" -ForegroundColor Green
        } else {
            $Lang = 'en'
            Write-Host "English selected.`n" -ForegroundColor Green
        }
    }

    # Localization dictionary
    $M = if ($Lang -eq 'fa') {
        @{
            ErrAppDirNotFound   = "[X] خطا: پوشه resources\app نرم‌افزار Antigravity IDE پیدا نشد!"
            ErrPathDetails       = "    دستور antigravity-ide در متغیر PATH یافت نشد و مسیرهای پیش‌فرض نیز وجود ندارند."
            PathsInspected       = "مسیرهای بررسی شده:"
            TroubleshootTitle    = "راهنما و روش‌های رفع مشکل:"
            TrbStep1             = "  1. اطمینان حاصل کنید که Antigravity IDE روی سیستم شما نصب است."
            TrbStep2             = "  2. پوشه bin برنامه (حاوی فایل antigravity-ide.cmd) را به متغیر PATH سیستم اضافه کنید."
            TrbStep3             = "  3. یا مسیر دقیق را از طریق پارامتر AppDir- مشخص نمایید:"
            TrbStep4             = "  4. یا متغیر محیطی ANTIGRAVITY_APP_DIR را تنظیم کنید:"
            ErrMissingFiles      = "[X] خطا: فایل‌های اصلی و حیاتی Antigravity IDE یافت نشدند در: {0}"
            MissingItem          = "    یافت نشد: {0}"
            TrbCorrupt           = "  - ممکن است نصب برنامه ناقص یا آسیب‌دیده باشد."
            TrbReinstall         = "  - برنامه را مجدداً نصب کنید یا مسیر دقیق resources\app را با پارامتر AppDir- ارسال فرمایید."
            SuccessDetected      = "[v] نرم‌افزار Antigravity IDE با موفقیت شناسایی شد از طریق: {0}"
            AppDirectory         = "    مسیر برنامه: {0}"
            VerifiedReady        = "[v] تمام فایل‌های هسته برنامه تأیید شدند. سیستم آماده اعمال فارسی‌سازی و راست‌چین‌سازی است!"
            FontDetected         = "[v] قلم وزیرمتن (Vazirmatn) شناسایی شد."
            FontLocalInstall     = "[*] در حال نصب قلم وزیرمتن از مخزن محلی..."
            FontInstalled        = "[v] قلم وزیرمتن نصب و ثبت گردید."
            FontNotDetected      = "[!] هشدار: قلم وزیرمتن (Vazirmatn) در فونت‌های ویندوز یافت نشد."
            FontInstallGuide     = "    پیشنهاد می‌شود جهت زیبایی بیشتر، فونت Vazirmatn را نصب فرمایید."
            StatusHeader         = "=== وضعیت فارسی ساز محیط توسعه آنتی گرویتی (PersianAntigravityIDE - ویندوز) ==="
            StatusAppDir         = "  مسیر برنامه:        {0}"
            StatusUserCfg        = "  تنظیمات کاربر:      {0}"
            StatusWorkbenchCss   = "  استایل CSS محیط:    {0}"
            StatusWorkbenchJs    = "  اسکریپت JS محیط:    {0}"
            StatusInstalled      = "نصب شده"
            StatusMissing        = "یافت نشد"
            StatusPatched        = "پچ شده (لینک کامل CSS و JS)"
            StatusPartialPatched = "پچ ناقص (فقط CSS)"
            StatusNotPatched     = "پچ نشده"
            StatusMarkdown       = "  پیش‌نمایش مارک‌داون:  {0}"
            StatusConfigured     = "پیکربندی شده"
            StatusNotConfigured  = "پیکربندی نشده"
            UninstHeader         = "=== بازگردانی تغییرات فارسی ساز محیط توسعه آنتی گرویتی (PersianAntigravityIDE - ویندوز) ==="
            UninstRestoredHtml   = "[v] فایل workbench.html از نسخه پشتیبان بازگردانی شد."
            UninstRemovedHtmlTag = "[v] تگ‌های راست‌چین از workbench.html حذف گردید."
            UninstRemovedCss     = "[v] فایل antigravity-chat-rtl.css حذف شد."
            UninstRemovedJs      = "[v] فایل antigravity-chat-rtl.js حذف شد."
            UninstRestoredProd   = "[v] فایل product.json از نسخه پشتیبان بازگردانی شد."
            UninstRemovedMdCss   = "[v] فایل markdown-rtl.css حذف شد."
            UninstCleanedMdStyle = "[v] استایل‌های مارک‌داون از settings.json پاکسازی شد."
            UninstWarningCfg     = "[!] هشدار هنگام به‌روزرسانی settings.json: {0}"
            UninstDone           = "فارسی ساز محیط توسعه آنتی گرویتی (PersianAntigravityIDE) با موفقیت حذف گردید."
            UninstRestart        = "لطفاً جهت اعمال، نرم‌افزار Antigravity IDE را مجدداً راه‌اندازی (Restart) کنید."
            InstHeader           = "=== در حال نصب فارسی ساز محیط توسعه آنتی گرویتی (PersianAntigravityIDE - ویندوز) ==="
            InstWriteCss         = "[*] در حال نوشتن فایل CSS محیط کاری -> {0}"
            InstWriteJs          = "[*] در حال نوشتن فایل JS محیط کاری -> {0}"
            InstPatchHtml        = "[*] در حال پچ کردن فایل {0}"
            InstBackupHtml       = "[i] نسخه پشتیبان ایجاد شد: {0}"
            InstInjectedHtml     = "[v] کدهای RTL در workbench.html تزریق شدند."
            InstCheckSum         = "[*] بررسی چک‌سام در product.json..."
            InstBackupProd       = "[i] نسخه پشتیبان ایجاد شد: {0}"
            InstBypassApplied    = "[v] بای‌پس چک‌سام برای workbench.html اعمال شد."
            InstBypassActive     = "[v] بای‌پس چک‌سام از قبل فعال بوده یا نیاز نیست."
            InstNoticeProd       = "[!] هشدار در product.json: {0}"
            InstConfigMd         = "[*] در حال تنظیم پیش‌نمایش مارک‌داون..."
            InstMdSuccess        = "[v] استایل‌ها و تنظیمات مارک‌داون راست‌چین ذخیره شد."
            InstSuccess          = "فارسی ساز محیط توسعه آنتی گرویتی (PersianAntigravityIDE) با موفقیت اعمال شد!"
            InstRestart          = "لطفاً نرم‌افزار Antigravity IDE را ببندید و دوباره باز کنید تا تغییرات اعمال گردند."
        }
    } else {
        @{
            ErrAppDirNotFound   = "[X] Error: Antigravity IDE 'resources\app' directory could not be found!"
            ErrPathDetails       = "    The 'antigravity-ide' command was not found in your PATH, and default directories were missing."
            PathsInspected       = "Paths inspected:"
            TroubleshootTitle    = "Troubleshooting & Solutions:"
            TrbStep1             = "  1. Ensure Antigravity IDE is installed on your computer."
            TrbStep2             = "  2. Add Antigravity IDE's 'bin' directory (containing 'antigravity-ide.cmd') to your system PATH."
            TrbStep3             = "  3. Or specify the path directly via -AppDir parameter:"
            TrbStep4             = "  4. Or set the ANTIGRAVITY_APP_DIR environment variable:"
            ErrMissingFiles      = "[X] Error: Required Antigravity IDE core files are missing in: {0}"
            MissingItem          = "    Missing: {0}"
            TrbCorrupt           = "  - The detected installation might be corrupted or incomplete."
            TrbReinstall         = "  - Reinstall Antigravity IDE or provide the correct resources\app directory with -AppDir."
            SuccessDetected      = "[v] Antigravity IDE detected successfully via: {0}"
            AppDirectory         = "    App Directory: {0}"
            VerifiedReady        = "[v] All core files verified. Environment is ready to apply RTL patches!"
            FontDetected         = "[v] Vazirmatn font detected."
            FontLocalInstall     = "[*] Installing Vazirmatn from local dotfiles repository..."
            FontInstalled        = "[v] Vazirmatn font installed and registered."
            FontNotDetected      = "[!] Warning: Vazirmatn font is not detected in Windows Fonts."
            FontInstallGuide     = "    Please install Vazirmatn font (e.g. from Google Fonts or GitHub)."
            StatusHeader         = "=== PersianAntigravityIDE Status (Windows) ==="
            StatusAppDir         = "  App Directory:    {0}"
            StatusUserCfg        = "  User Config:      {0}"
            StatusWorkbenchCss   = "  Workbench CSS:    {0}"
            StatusWorkbenchJs    = "  Workbench JS:     {0}"
            StatusInstalled      = "Installed"
            StatusMissing        = "Missing"
            StatusPatched        = "Patched (CSS & JS linked)"
            StatusPartialPatched = "Partially Patched (CSS only)"
            StatusNotPatched     = "Not Patched"
            StatusMarkdown       = "  Markdown Preview: {0}"
            StatusConfigured     = "Configured"
            StatusNotConfigured  = "Not Configured"
            UninstHeader         = "=== Reverting PersianAntigravityIDE Setup (Windows) ==="
            UninstRestoredHtml   = "[v] Restored workbench.html from backup."
            UninstRemovedHtmlTag = "[v] Removed RTL tags from workbench.html."
            UninstRemovedCss     = "[v] Removed antigravity-chat-rtl.css."
            UninstRemovedJs      = "[v] Removed antigravity-chat-rtl.js."
            UninstRestoredProd   = "[v] Restored product.json from backup."
            UninstRemovedMdCss   = "[v] Removed markdown-rtl.css."
            UninstCleanedMdStyle = "[v] Cleaned up markdown styles from settings.json."
            UninstWarningCfg     = "[!] Warning updating settings.json: {0}"
            UninstDone           = "PersianAntigravityIDE uninstalled cleanly."
            UninstRestart        = "Please restart Antigravity IDE."
            InstHeader           = "=== Installing PersianAntigravityIDE (Windows) ==="
            InstWriteCss         = "[*] Writing workbench CSS -> {0}"
            InstWriteJs          = "[*] Writing workbench JS -> {0}"
            InstPatchHtml        = "[*] Patching {0}"
            InstBackupHtml       = "[i] Created backup: {0}"
            InstInjectedHtml     = "[v] Injected RTL CSS & JS references into workbench.html"
            InstCheckSum         = "[*] Checking product.json checksums..."
            InstBackupProd       = "[i] Created backup: {0}"
            InstBypassApplied    = "[v] Checksum bypass applied for workbench.html."
            InstBypassActive     = "[v] Checksum bypass already active or not required."
            InstNoticeProd       = "[!] Notice on product.json: {0}"
            InstConfigMd         = "[*] Configuring user Markdown preview..."
            InstMdSuccess        = "[v] Markdown RTL preview styles & settings configured."
            InstSuccess          = "PersianAntigravityIDE and Vazirmatn successfully installed!"
            InstRestart          = "Please restart Antigravity IDE to apply all visual changes."
        }
    }

    # 1. Dynamically locate Antigravity IDE resources\app directory
    $detectedVia = $null
    $searchedPaths = [System.Collections.Generic.List[string]]::new()

    if (-not $AppDir) {
        # Priority 1: Check environment variable ANTIGRAVITY_APP_DIR
        if ($env:ANTIGRAVITY_APP_DIR -and (Test-Path -LiteralPath $env:ANTIGRAVITY_APP_DIR)) {
            $AppDir = $env:ANTIGRAVITY_APP_DIR
            $detectedVia = "Environment variable ANTIGRAVITY_APP_DIR"
        }

        # Priority 2: Locate via 'antigravity-ide' in PATH
        if (-not $AppDir) {
            $cmd = Get-Command "antigravity-ide" -ErrorAction SilentlyContinue
            if ($cmd -and $cmd.Source) {
                $searchedPaths.Add("PATH: $($cmd.Source)")
                # Resolve script or binary location (e.g., ...\Antigravity IDE\bin\antigravity-ide.cmd)
                $cmdDir = Split-Path -Parent $cmd.Source
                $candidateApp = Join-Path (Split-Path -Parent $cmdDir) "resources\app"
                if ((Test-Path -LiteralPath $candidateApp) -and (Test-Path -LiteralPath "$candidateApp\package.json")) {
                    $AppDir = $candidateApp
                    $detectedVia = "PATH command: '$($cmd.Name)' ($($cmd.Source))"
                }
            }
        }

        # Priority 3: Fallback standard installation paths
        if (-not $AppDir) {
            $candidates = @(
                "$env:LOCALAPPDATA\Programs\Antigravity IDE\resources\app",
                "$env:ProgramFiles\Antigravity IDE\resources\app",
                "$env:ProgramFiles(x86)\Antigravity IDE\resources\app",
                "$env:USERPROFILE\AppData\Local\Programs\Antigravity IDE\resources\app"
            )
            foreach ($c in $candidates) {
                $searchedPaths.Add("Default Path: $c")
                if ((Test-Path -LiteralPath $c) -and (Test-Path -LiteralPath "$c\package.json")) {
                    $AppDir = $c
                    $detectedVia = "Standard install location ($c)"
                    break
                }
            }
        }
    } else {
        $searchedPaths.Add("User specified (-AppDir): $AppDir")
        $detectedVia = "User specified parameter (-AppDir)"
    }

    # Error handling & actionable troubleshooting
    if (-not $AppDir -or -not (Test-Path -LiteralPath $AppDir)) {
        Write-Host ""
        Write-Host $M.ErrAppDirNotFound -ForegroundColor Red
        Write-Host $M.ErrPathDetails -ForegroundColor Yellow
        Write-Host ""
        Write-Host $M.PathsInspected -ForegroundColor DarkGray
        foreach ($p in $searchedPaths) {
            Write-Host "  - $p" -ForegroundColor DarkGray
        }
        Write-Host ""
        Write-Host $M.TroubleshootTitle -ForegroundColor Cyan
        Write-Host $M.TrbStep1 -ForegroundColor White
        Write-Host $M.TrbStep2 -ForegroundColor White
        Write-Host $M.TrbStep3 -ForegroundColor White
        Write-Host "     .\setup.ps1 -AppDir `"C:\Path\To\Antigravity IDE\resources\app`"" -ForegroundColor Yellow
        Write-Host $M.TrbStep4 -ForegroundColor White
        Write-Host "     `$env:ANTIGRAVITY_APP_DIR = `"C:\Path\To\Antigravity IDE\resources\app`"" -ForegroundColor Yellow
        Write-Host ""
        return
    }

    $workbenchDir  = Join-Path $AppDir "out\vs\workbench"
    $htmlFile      = Join-Path $AppDir "out\vs\code\electron-browser\workbench\workbench.html"
    $productJson   = Join-Path $AppDir "product.json"
    $userConfigDir = Join-Path $env:APPDATA "Antigravity IDE\User"
    $markdownCss   = Join-Path $userConfigDir "markdown-rtl.css"
    $settingsJson  = Join-Path $userConfigDir "settings.json"

    # Integrity & Health Check of required files
    $missingFiles = [System.Collections.Generic.List[string]]::new()
    if (-not (Test-Path -LiteralPath (Join-Path $AppDir "package.json"))) { $missingFiles.Add("package.json") }
    if (-not (Test-Path -LiteralPath $workbenchDir))                      { $missingFiles.Add("out\vs\workbench") }
    if (-not (Test-Path -LiteralPath $htmlFile))                          { $missingFiles.Add("out\vs\code\electron-browser\workbench\workbench.html") }
    if (-not (Test-Path -LiteralPath $productJson))                       { $missingFiles.Add("product.json") }

    if ($missingFiles.Count -gt 0) {
        Write-Host ""
        Write-Host ($M.ErrMissingFiles -f $AppDir) -ForegroundColor Red
        foreach ($mf in $missingFiles) {
            Write-Host ($M.MissingItem -f $mf) -ForegroundColor Yellow
        }
        Write-Host ""
        Write-Host $M.TroubleshootTitle -ForegroundColor Cyan
        Write-Host $M.TrbCorrupt -ForegroundColor White
        Write-Host $M.TrbReinstall -ForegroundColor White
        Write-Host ""
        return
    }

    Write-Host ($M.SuccessDetected -f $detectedVia) -ForegroundColor Green
    Write-Host ($M.AppDirectory -f $AppDir) -ForegroundColor DarkCyan
    Write-Host $M.VerifiedReady -ForegroundColor Green
    Write-Host ""

    # Helper: Check fonts
    function Test-VazirmatnFont {
        $fontDirs = @(
            "$env:WINDIR\Fonts",
            "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
        )
        $found = $false
        foreach ($d in $fontDirs) {
            if (Test-Path -LiteralPath $d) {
                $matches = Get-ChildItem -Path $d -Filter "*vazir*" -ErrorAction SilentlyContinue
                if ($matches) {
                    $found = $true
                    break
                }
            }
        }
        if ($found) {
            Write-Host $M.FontDetected -ForegroundColor Green
            return
        }

        # Attempt offline installation from local repository if present
        $localFontsDir = Join-Path $env:USERPROFILE ".local\share\chezmoi\private_dot_local\private_share\fonts"
        $vazirFiles = Get-ChildItem -Path $localFontsDir -Filter "Vazirmatn-*.ttf" -ErrorAction SilentlyContinue
        if ($vazirFiles) {
            Write-Host $M.FontLocalInstall -ForegroundColor Cyan
            $userFontsDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
            if (-not (Test-Path $userFontsDir)) {
                New-Item -ItemType Directory -Path $userFontsDir -Force | Out-Null
            }
            $fontRegPath = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
            if (-not (Test-Path $fontRegPath)) {
                New-Item -Path $fontRegPath -Force | Out-Null
            }

            try {
                Add-Type -Namespace Win32Font -Name NativeMethods -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("gdi32.dll")]
public static extern int AddFontResource(string lpFileName);
[System.Runtime.InteropServices.DllImport("user32.dll")]
public static extern int SendMessage(System.IntPtr hWnd, uint Msg, System.IntPtr wParam, System.IntPtr lParam);
'@ -ErrorAction SilentlyContinue
            } catch {}

            foreach ($file in $vazirFiles) {
                $dest = Join-Path $userFontsDir $file.Name
                Copy-Item -Path $file.FullName -Destination $dest -Force
                $weight = if ($file.Name -match '^Vazirmatn-(.+)\.ttf$') { $Matches[1] } else { "Regular" }
                Set-ItemProperty -Path $fontRegPath -Name "Vazirmatn $weight (TrueType)" -Value $dest -Force
                try { [Win32Font.NativeMethods]::AddFontResource($dest) | Out-Null } catch {}
            }

            try {
                [Win32Font.NativeMethods]::SendMessage([System.IntPtr]0xffff, 0x001D, [System.IntPtr]::Zero, [System.IntPtr]::Zero) | Out-Null
            } catch {}

            Write-Host $M.FontInstalled -ForegroundColor Green
        } else {
            Write-Host $M.FontNotDetected -ForegroundColor Yellow
            Write-Host $M.FontInstallGuide -ForegroundColor Cyan
        }
    }

    # Load CSS & JS content (modular file or embedded fallback)
    $localCssFile = if ($PSScriptRoot) { Join-Path $PSScriptRoot "styles\antigravity-chat-rtl.css" } else { "" }
    $localJsFile  = if ($PSScriptRoot) { Join-Path $PSScriptRoot "scripts\antigravity-chat-rtl.js" } else { "" }
    $localMdCss   = if ($PSScriptRoot) { Join-Path $PSScriptRoot "styles\markdown-rtl.css" } else { "" }

    $cssContent = if ($localCssFile -and (Test-Path -LiteralPath $localCssFile)) {
        [System.IO.File]::ReadAllText($localCssFile, [System.Text.Encoding]::UTF8)
    } else {
@'
.antigravity-agent-side-panel,
.antigravity-agent-side-panel p,
.antigravity-agent-side-panel span,
.antigravity-agent-side-panel li,
.antigravity-agent-side-panel h1,
.antigravity-agent-side-panel h2,
.antigravity-agent-side-panel h3,
.antigravity-agent-side-panel h4,
.antigravity-agent-side-panel textarea,
.antigravity-agent-side-panel input,
.antigravity-agent-side-panel [contenteditable="true"],
.jetski-custom-editor-pane,
.jetski-custom-editor-pane p,
.jetski-custom-editor-pane span,
.jetski-custom-editor-pane li,
.jetski-custom-editor-pane h1,
.jetski-custom-editor-pane h2,
.jetski-custom-editor-pane h3 {
    font-family: 'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif !important;
}
.antigravity-is-rtl {
    direction: rtl !important;
    text-align: right !important;
}
.jetski-custom-editor-pane .antigravity-is-rtl {
    line-height: 1.8 !important;
}
.jetski-custom-editor-pane ol.antigravity-is-rtl,
.jetski-custom-editor-pane ul.antigravity-is-rtl {
    padding-right: 2.25rem !important;
    padding-left: 1rem !important;
    margin-right: 0.5rem !important;
}
.jetski-custom-editor-pane li.antigravity-is-rtl {
    padding-right: 0.35rem !important;
    margin-bottom: 0.4rem !important;
}
.jetski-custom-editor-pane > div,
.jetski-custom-editor-pane .pb-6 {
    padding-right: 2rem !important;
    padding-left: 2rem !important;
}
.antigravity-agent-side-panel textarea,
.antigravity-agent-side-panel input,
.antigravity-agent-side-panel [contenteditable="true"] {
    unicode-bidi: plaintext !important;
    text-align: start !important;
}
.antigravity-agent-side-panel pre,
.antigravity-agent-side-panel code,
.antigravity-agent-side-panel pre *,
.antigravity-agent-side-panel code *,
.antigravity-agent-side-panel .interactive-result-code-block,
.antigravity-agent-side-panel .code-block-container,
.jetski-custom-editor-pane pre,
.jetski-custom-editor-pane code,
.jetski-custom-editor-pane pre *,
.jetski-custom-editor-pane code *,
.antigravity-is-rtl pre,
.antigravity-is-rtl code,
.antigravity-is-rtl .interactive-result-code-block,
.antigravity-is-rtl .code-block-container {
    direction: ltr !important;
    unicode-bidi: isolate !important;
    text-align: left !important;
    font-family: 'JetBrainsMono Nerd Font', 'Jet Brains Mono Nerd Font', 'JetBrainsMono NF', monospace !important;
}
.codicon,
.codicon[class*='codicon-'],
[class*='codicon'],
.material-symbols-outlined,
.material-icons,
[class*='lucide'] {
    font-family: codicon, 'Material Symbols Outlined', 'Material Icons', inherit !important;
}
.antigravity-is-rtl table,
.jetski-custom-editor-pane table {
    direction: ltr !important;
    text-align: left !important;
}
#antigravity-rtl-toggle-btn {
    font-size: 14px !important;
    font-weight: bold !important;
    transition: opacity 0.2s, background 0.2s;
    text-decoration: none !important;
    cursor: pointer !important;
}
#antigravity-rtl-toggle-btn.antigravity-rtl-active {
    color: #4facfe !important;
}
'@
    }

    $jsContent = if ($localJsFile -and (Test-Path -LiteralPath $localJsFile)) {
        [System.IO.File]::ReadAllText($localJsFile, [System.Text.Encoding]::UTF8)
    } else {
@'
(function() {
    'use strict';
    var RTL_REGEX = /[\u0590-\u05FF\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]/;

    function updateRtlElements() {
        var selectors = [
            '.antigravity-agent-side-panel .whitespace-pre-wrap.text-sm',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > p',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > ul',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > ol',
            '.antigravity-agent-side-panel .leading-relaxed.select-text li',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > h1',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > h2',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > h3',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > h4',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > blockquote',
            '.jetski-custom-editor-pane p',
            '.jetski-custom-editor-pane ul',
            '.jetski-custom-editor-pane ol',
            '.jetski-custom-editor-pane li',
            '.jetski-custom-editor-pane h1',
            '.jetski-custom-editor-pane h2',
            '.jetski-custom-editor-pane h3',
            '.jetski-custom-editor-pane h4',
            '.jetski-custom-editor-pane h5',
            '.jetski-custom-editor-pane h6',
            '.jetski-custom-editor-pane blockquote'
        ].join(', ');

        var elements = document.querySelectorAll(selectors);
        elements.forEach(function(el) {
            if (el.tagName === 'PRE' || el.tagName === 'CODE' || el.closest('pre') || el.closest('.interactive-result-code-block') || el.closest('.code-block-container')) {
                return;
            }
            if (RTL_REGEX.test(el.textContent)) {
                el.classList.add('antigravity-is-rtl');
            } else {
                el.classList.remove('antigravity-is-rtl');
            }
        });
    }

    var updateTimeout = null;
    function scheduleUpdate() {
        if (updateTimeout) return;
        updateTimeout = setTimeout(function() {
            updateTimeout = null;
            updateRtlElements();
        }, 100);
    }

    var observer = new MutationObserver(function() {
        scheduleUpdate();
    });
    observer.observe(document.body, { childList: true, subtree: true });

    if (document.readyState !== 'loading') {
        scheduleUpdate();
    } else {
        document.addEventListener('DOMContentLoaded', scheduleUpdate);
    }
})();
'@
    }

    $markdownCssContent = if ($localMdCss -and (Test-Path -LiteralPath $localMdCss)) {
        [System.IO.File]::ReadAllText($localMdCss, [System.Text.Encoding]::UTF8)
    } else {
@'
body {
    font-family: 'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, 'Ubuntu', 'Droid Sans', sans-serif !important;
}
p, h1, h2, h3, h4, h5, h6, li, blockquote, td, th {
    unicode-bidi: plaintext;
    text-align: start;
}
pre, code, tt {
    direction: ltr !important;
    unicode-bidi: isolate !important;
    text-align: left !important;
    font-family: 'JetBrainsMono Nerd Font', 'Jet Brains Mono Nerd Font', monospace !important;
}
li:dir(rtl) {
    direction: rtl;
    text-align: right;
}
'@
    }

    # --- STATUS ACTION ---
    if ($Status) {
        Write-Host $M.StatusHeader -ForegroundColor Cyan
        Write-Host ($M.StatusAppDir -f $AppDir)
        Write-Host ($M.StatusUserCfg -f $userConfigDir)
        Write-Host ""

        $cssPath = Join-Path $workbenchDir "antigravity-chat-rtl.css"
        $jsPath  = Join-Path $workbenchDir "antigravity-chat-rtl.js"

        if (Test-Path -LiteralPath $cssPath) {
            Write-Host ($M.StatusWorkbenchCss -f $M.StatusInstalled) -ForegroundColor Green
        } else {
            Write-Host ($M.StatusWorkbenchCss -f $M.StatusMissing) -ForegroundColor Red
        }

        if (Test-Path -LiteralPath $jsPath) {
            Write-Host ($M.StatusWorkbenchJs -f $M.StatusInstalled) -ForegroundColor Green
        } else {
            Write-Host ($M.StatusWorkbenchJs -f $M.StatusMissing) -ForegroundColor Red
        }

        if (Test-Path -LiteralPath $htmlFile) {
            $htmlRaw = Get-Content -LiteralPath $htmlFile -Raw
            $hasCss = $htmlRaw -match "antigravity-chat-rtl\.css"
            $hasJs  = $htmlRaw -match "antigravity-chat-rtl\.js"

            if ($hasCss -and $hasJs) {
                Write-Host "  workbench.html:   $($M.StatusPatched)" -ForegroundColor Green
            } elseif ($hasCss) {
                Write-Host "  workbench.html:   $($M.StatusPartialPatched)" -ForegroundColor Yellow
            } else {
                Write-Host "  workbench.html:   $($M.StatusNotPatched)" -ForegroundColor Red
            }
        }

        if (Test-Path -LiteralPath $markdownCss) {
            Write-Host ($M.StatusMarkdown -f $M.StatusConfigured) -ForegroundColor Green
        } else {
            Write-Host ($M.StatusMarkdown -f $M.StatusNotConfigured) -ForegroundColor Yellow
        }
        return
    }

    # --- UNINSTALL ACTION ---
    if ($Uninstall) {
        Write-Host $M.UninstHeader -ForegroundColor Yellow

        # 1. Restore workbench.html
        if (Test-Path -LiteralPath "$htmlFile.bak") {
            Copy-Item -LiteralPath "$htmlFile.bak" -Destination $htmlFile -Force
            Remove-Item -LiteralPath "$htmlFile.bak" -Force
            Write-Host $M.UninstRestoredHtml -ForegroundColor Green
        } elseif (Test-Path -LiteralPath $htmlFile) {
            $lines = Get-Content -LiteralPath $htmlFile | Where-Object {
                $_ -notmatch "antigravity-chat-rtl\.css" -and $_ -notmatch "antigravity-chat-rtl\.js"
            }
            [System.IO.File]::WriteAllLines($htmlFile, $lines, [System.Text.Encoding]::UTF8)
            Write-Host $M.UninstRemovedHtmlTag -ForegroundColor Green
        }

        # 2. Remove CSS and JS
        $cssPath = Join-Path $workbenchDir "antigravity-chat-rtl.css"
        $jsPath  = Join-Path $workbenchDir "antigravity-chat-rtl.js"
        if (Test-Path -LiteralPath $cssPath) {
            Remove-Item -LiteralPath $cssPath -Force
            Write-Host $M.UninstRemovedCss -ForegroundColor Green
        }
        if (Test-Path -LiteralPath $jsPath) {
            Remove-Item -LiteralPath $jsPath -Force
            Write-Host $M.UninstRemovedJs -ForegroundColor Green
        }

        # 3. Restore product.json if backup exists
        if (Test-Path -LiteralPath "$productJson.bak") {
            Copy-Item -LiteralPath "$productJson.bak" -Destination $productJson -Force
            Remove-Item -LiteralPath "$productJson.bak" -Force
            Write-Host $M.UninstRestoredProd -ForegroundColor Green
        }

        # 4. Remove Markdown CSS
        if (Test-Path -LiteralPath $markdownCss) {
            Remove-Item -LiteralPath $markdownCss -Force
            Write-Host $M.UninstRemovedMdCss -ForegroundColor Green
        }

        # 5. Clean settings.json
        if (Test-Path -LiteralPath $settingsJson) {
            try {
                $rawJson = Get-Content -LiteralPath $settingsJson -Raw
                $cfg = $rawJson | ConvertFrom-Json
                if ($cfg.'markdown.styles') {
                    $normMarkdownCss = $markdownCss.Replace('\', '/')
                    $newStyles = @()
                    foreach ($s in $cfg.'markdown.styles') {
                        $ns = "$s".Replace('\', '/')
                        if ($ns -ne $normMarkdownCss) {
                            $newStyles += $s
                        }
                    }
                    $cfg.'markdown.styles' = $newStyles
                    $outJson = $cfg | ConvertTo-Json -Depth 10
                    [System.IO.File]::WriteAllText($settingsJson, $outJson, [System.Text.Encoding]::UTF8)
                    Write-Host $M.UninstCleanedMdStyle -ForegroundColor Green
                }
            } catch {
                Write-Host ($M.UninstWarningCfg -f $_) -ForegroundColor Yellow
            }
        }

        Write-Host ""
        Write-Host $M.UninstDone -ForegroundColor Green
        Write-Host $M.UninstRestart -ForegroundColor Cyan
        return
    }

    # --- INSTALL ACTION (DEFAULT) ---
    Write-Host $M.InstHeader -ForegroundColor Cyan
    Test-VazirmatnFont

    # 1. Write CSS file
    $cssTarget = Join-Path $workbenchDir "antigravity-chat-rtl.css"
    Write-Host ($M.InstWriteCss -f $cssTarget) -ForegroundColor Cyan
    [System.IO.File]::WriteAllText($cssTarget, $cssContent, [System.Text.Encoding]::UTF8)

    # 2. Write JS file
    $jsTarget = Join-Path $workbenchDir "antigravity-chat-rtl.js"
    Write-Host ($M.InstWriteJs -f $jsTarget) -ForegroundColor Cyan
    [System.IO.File]::WriteAllText($jsTarget, $jsContent, [System.Text.Encoding]::UTF8)

    # 3. Patch workbench.html
    Write-Host ($M.InstPatchHtml -f $htmlFile) -ForegroundColor Cyan
    if (-not (Test-Path -LiteralPath "$htmlFile.bak")) {
        Copy-Item -LiteralPath "$htmlFile" -Destination "$htmlFile.bak" -Force
        Write-Host ($M.InstBackupHtml -f "$htmlFile.bak") -ForegroundColor DarkCyan
    }

    $htmlLines = [System.IO.File]::ReadAllLines($htmlFile, [System.Text.Encoding]::UTF8)
    $hasCss = $false
    $hasJs  = $false
    foreach ($l in $htmlLines) {
        if ($l -match "antigravity-chat-rtl\.css") { $hasCss = $true }
        if ($l -match "antigravity-chat-rtl\.js")  { $hasJs  = $true }
    }

    $newLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $htmlLines) {
        if (-not $hasCss -and $line.Trim() -eq "</head>") {
            $newLines.Add("`t<link rel=`"stylesheet`" href=`"../../../workbench/antigravity-chat-rtl.css`">")
            $hasCss = $true
        }
        if (-not $hasJs -and $line.Trim() -eq "</html>") {
            $newLines.Add("`t<script src=`"../../../workbench/antigravity-chat-rtl.js`"></script>")
            $hasJs = $true
        }
        $newLines.Add($line)
    }
    [System.IO.File]::WriteAllLines($htmlFile, $newLines, [System.Text.Encoding]::UTF8)
    Write-Host $M.InstInjectedHtml -ForegroundColor Green

    # 4. Checksum Bypass in product.json
    if (Test-Path -LiteralPath $productJson) {
        Write-Host $M.InstCheckSum -ForegroundColor Cyan
        try {
            $prodRaw = Get-Content -LiteralPath $productJson -Raw
            $prodObj = $prodRaw | ConvertFrom-Json
            $targetKey = "vs/code/electron-browser/workbench/workbench.html"

            if ($prodObj.checksums -and ($null -ne $prodObj.checksums.$targetKey)) {
                if (-not (Test-Path -LiteralPath "$productJson.bak")) {
                    Copy-Item -LiteralPath "$productJson" -Destination "$productJson.bak" -Force
                    Write-Host ($M.InstBackupProd -f "$productJson.bak") -ForegroundColor DarkCyan
                }
                $prodObj.checksums.PSObject.Properties.Remove($targetKey)
                $updatedJson = $prodObj | ConvertTo-Json -Depth 20
                [System.IO.File]::WriteAllText($productJson, $updatedJson, [System.Text.Encoding]::UTF8)
                Write-Host $M.InstBypassApplied -ForegroundColor Green
            } else {
                Write-Host $M.InstBypassActive -ForegroundColor Green
            }
        } catch {
            Write-Host ($M.InstNoticeProd -f $_) -ForegroundColor Yellow
        }
    }

    # 5. Configure Markdown RTL preview
    Write-Host $M.InstConfigMd -ForegroundColor Cyan
    if (-not (Test-Path -LiteralPath $userConfigDir)) {
        New-Item -ItemType Directory -Path $userConfigDir -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($markdownCss, $markdownCssContent, [System.Text.Encoding]::UTF8)

    try {
        $settings = @{}
        if (Test-Path -LiteralPath $settingsJson) {
            $raw = Get-Content -LiteralPath $settingsJson -Raw
            if ($raw.Trim()) {
                $settings = $raw | ConvertFrom-Json -AsHashtable
            }
        }
        $settings['markdown.preview.fontFamily'] = "'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif"

        $styles = @()
        if ($settings.ContainsKey('markdown.styles') -and ($settings['markdown.styles'] -is [System.Collections.IEnumerable])) {
            $styles = @($settings['markdown.styles'])
        }
        $normalizedMarkdownCss = $markdownCss.Replace('\', '/')
        $alreadyInStyles = $false
        foreach ($st in $styles) {
            if ("$st".Replace('\', '/') -eq $normalizedMarkdownCss) {
                $alreadyInStyles = $true
                break
            }
        }
        if (-not $alreadyInStyles) {
            $styles += $normalizedMarkdownCss
        }
        $settings['markdown.styles'] = $styles

        $finalJson = $settings | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText($settingsJson, $finalJson, [System.Text.Encoding]::UTF8)
        Write-Host $M.InstMdSuccess -ForegroundColor Green
    } catch {
        Write-Host ($M.UninstWarningCfg -f $_) -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host $M.InstSuccess -ForegroundColor Green
    Write-Host $M.InstRestart -ForegroundColor Cyan
}

# Alias for seamless usage
Set-Alias -Name setup-persian-antigravity-ide -Value Setup-PersianAntigravityIDE -Scope Global -ErrorAction SilentlyContinue
Set-Alias -Name setup-antigravity-rtl -Value Setup-PersianAntigravityIDE -Scope Global -ErrorAction SilentlyContinue

# If executed directly as a script (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.' -and $MyInvocation.Line -match 'setup\.ps1') {
    Setup-PersianAntigravityIDE @args
}
