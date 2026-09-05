# ==============================================================================
# Antigravity IDE RTL & Vazirmatn Setup & Automation Script (Windows)
# ==============================================================================
# Project: https://github.com/mehdichamani/antigravity-rtl
# Author:  Mehdi Chamani
# License: MIT
# Target:  Antigravity IDE (Windows PowerShell 7+)
# ==============================================================================

function Setup-AntigravityRtl {
    [CmdletBinding(DefaultParameterSetName = 'Install')]
    param(
        [Parameter(ParameterSetName = 'Install')]
        [switch]$Install,

        [Parameter(ParameterSetName = 'Uninstall')]
        [switch]$Uninstall,

        [Parameter(ParameterSetName = 'Status')]
        [switch]$Status,

        [Parameter()]
        [string]$AppDir
    )

    $ErrorActionPreference = 'Stop'

    # 1. Locate Antigravity IDE application directory
    if (-not $AppDir) {
        $candidates = @(
            "$env:LOCALAPPDATA\Programs\Antigravity IDE\resources\app",
            "$env:ProgramFiles\Antigravity IDE\resources\app",
            "$env:ProgramFiles(x86)\Antigravity IDE\resources\app",
            "$env:USERPROFILE\AppData\Local\Programs\Antigravity IDE\resources\app"
        )
        foreach ($c in $candidates) {
            if ((Test-Path -LiteralPath $c) -and (Test-Path -LiteralPath "$c\package.json")) {
                $AppDir = $c
                break
            }
        }
    }

    if (-not $AppDir -or -not (Test-Path -LiteralPath $AppDir)) {
        Write-Host "[X] Error: Antigravity IDE resources\app directory not found." -ForegroundColor Red
        Write-Host "    Please specify the path using -AppDir '<path>'." -ForegroundColor Yellow
        return
    }

    $workbenchDir  = Join-Path $AppDir "out\vs\workbench"
    $htmlFile      = Join-Path $AppDir "out\vs\code\electron-browser\workbench\workbench.html"
    $productJson   = Join-Path $AppDir "product.json"
    $userConfigDir = Join-Path $env:APPDATA "Antigravity IDE\User"
    $markdownCss   = Join-Path $userConfigDir "markdown-rtl.css"
    $settingsJson  = Join-Path $userConfigDir "settings.json"

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
            Write-Host "[v] Vazirmatn font detected." -ForegroundColor Green
            return
        }

        # Attempt offline installation from local repository if present
        $localFontsDir = Join-Path $env:USERPROFILE ".local\share\chezmoi\private_dot_local\private_share\fonts"
        $vazirFiles = Get-ChildItem -Path $localFontsDir -Filter "Vazirmatn-*.ttf" -ErrorAction SilentlyContinue
        if ($vazirFiles) {
            Write-Host "[*] Installing Vazirmatn from local dotfiles repository..." -ForegroundColor Cyan
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

            Write-Host "[v] Vazirmatn font installed and registered." -ForegroundColor Green
        } else {
            Write-Host "[!] Warning: Vazirmatn font is not detected in Windows Fonts." -ForegroundColor Yellow
            Write-Host "    Please install Vazirmatn font (e.g. from Google Fonts or GitHub)." -ForegroundColor Cyan
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
        Write-Host "=== Antigravity IDE RTL Status (Windows) ===" -ForegroundColor Cyan
        Write-Host "  App Directory:    $AppDir"
        Write-Host "  User Config:      $userConfigDir"
        Write-Host ""

        $cssPath = Join-Path $workbenchDir "antigravity-chat-rtl.css"
        $jsPath  = Join-Path $workbenchDir "antigravity-chat-rtl.js"

        if (Test-Path -LiteralPath $cssPath) {
            Write-Host "  Workbench CSS:    Installed" -ForegroundColor Green
        } else {
            Write-Host "  Workbench CSS:    Missing" -ForegroundColor Red
        }

        if (Test-Path -LiteralPath $jsPath) {
            Write-Host "  Workbench JS:     Installed" -ForegroundColor Green
        } else {
            Write-Host "  Workbench JS:     Missing" -ForegroundColor Red
        }

        if (Test-Path -LiteralPath $htmlFile) {
            $htmlRaw = Get-Content -LiteralPath $htmlFile -Raw
            $hasCss = $htmlRaw -match "antigravity-chat-rtl\.css"
            $hasJs  = $htmlRaw -match "antigravity-chat-rtl\.js"

            if ($hasCss -and $hasJs) {
                Write-Host "  workbench.html:   Patched (CSS & JS linked)" -ForegroundColor Green
            } elseif ($hasCss) {
                Write-Host "  workbench.html:   Partially Patched (CSS only)" -ForegroundColor Yellow
            } else {
                Write-Host "  workbench.html:   Not Patched" -ForegroundColor Red
            }
        }

        if (Test-Path -LiteralPath $markdownCss) {
            Write-Host "  Markdown Preview: Configured" -ForegroundColor Green
        } else {
            Write-Host "  Markdown Preview: Not Configured" -ForegroundColor Yellow
        }
        return
    }

    # --- UNINSTALL ACTION ---
    if ($Uninstall) {
        Write-Host "=== Reverting Antigravity IDE RTL Setup (Windows) ===" -ForegroundColor Yellow

        # 1. Restore workbench.html
        if (Test-Path -LiteralPath "$htmlFile.bak") {
            Copy-Item -LiteralPath "$htmlFile.bak" -Destination $htmlFile -Force
            Remove-Item -LiteralPath "$htmlFile.bak" -Force
            Write-Host "[v] Restored workbench.html from backup." -ForegroundColor Green
        } elseif (Test-Path -LiteralPath $htmlFile) {
            $lines = Get-Content -LiteralPath $htmlFile | Where-Object {
                $_ -notmatch "antigravity-chat-rtl\.css" -and $_ -notmatch "antigravity-chat-rtl\.js"
            }
            [System.IO.File]::WriteAllLines($htmlFile, $lines, [System.Text.Encoding]::UTF8)
            Write-Host "[v] Removed RTL tags from workbench.html." -ForegroundColor Green
        }

        # 2. Remove CSS and JS
        $cssPath = Join-Path $workbenchDir "antigravity-chat-rtl.css"
        $jsPath  = Join-Path $workbenchDir "antigravity-chat-rtl.js"
        if (Test-Path -LiteralPath $cssPath) {
            Remove-Item -LiteralPath $cssPath -Force
            Write-Host "[v] Removed antigravity-chat-rtl.css." -ForegroundColor Green
        }
        if (Test-Path -LiteralPath $jsPath) {
            Remove-Item -LiteralPath $jsPath -Force
            Write-Host "[v] Removed antigravity-chat-rtl.js." -ForegroundColor Green
        }

        # 3. Restore product.json if backup exists
        if (Test-Path -LiteralPath "$productJson.bak") {
            Copy-Item -LiteralPath "$productJson.bak" -Destination $productJson -Force
            Remove-Item -LiteralPath "$productJson.bak" -Force
            Write-Host "[v] Restored product.json from backup." -ForegroundColor Green
        }

        # 4. Remove Markdown CSS
        if (Test-Path -LiteralPath $markdownCss) {
            Remove-Item -LiteralPath $markdownCss -Force
            Write-Host "[v] Removed markdown-rtl.css." -ForegroundColor Green
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
                    Write-Host "[v] Cleaned up markdown styles from settings.json." -ForegroundColor Green
                }
            } catch {
                Write-Host "[!] Warning updating settings.json: $_" -ForegroundColor Yellow
            }
        }

        Write-Host ""
        Write-Host "Antigravity IDE RTL uninstalled cleanly." -ForegroundColor Green
        Write-Host "Please restart Antigravity IDE." -ForegroundColor Cyan
        return
    }

    # --- INSTALL ACTION (DEFAULT) ---
    Write-Host "=== Installing Antigravity IDE RTL & Vazirmatn Font (Windows) ===" -ForegroundColor Cyan
    Test-VazirmatnFont

    # 1. Write CSS file
    $cssTarget = Join-Path $workbenchDir "antigravity-chat-rtl.css"
    Write-Host "[*] Writing workbench CSS -> $cssTarget" -ForegroundColor Cyan
    [System.IO.File]::WriteAllText($cssTarget, $cssContent, [System.Text.Encoding]::UTF8)

    # 2. Write JS file
    $jsTarget = Join-Path $workbenchDir "antigravity-chat-rtl.js"
    Write-Host "[*] Writing workbench JS -> $jsTarget" -ForegroundColor Cyan
    [System.IO.File]::WriteAllText($jsTarget, $jsContent, [System.Text.Encoding]::UTF8)

    # 3. Patch workbench.html
    Write-Host "[*] Patching $htmlFile" -ForegroundColor Cyan
    if (-not (Test-Path -LiteralPath "$htmlFile.bak")) {
        Copy-Item -LiteralPath "$htmlFile" -Destination "$htmlFile.bak" -Force
        Write-Host "[i] Created backup: $htmlFile.bak" -ForegroundColor DarkCyan
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
    Write-Host "[v] Injected RTL CSS & JS references into workbench.html" -ForegroundColor Green

    # 4. Checksum Bypass in product.json
    if (Test-Path -LiteralPath $productJson) {
        Write-Host "[*] Checking product.json checksums..." -ForegroundColor Cyan
        try {
            $prodRaw = Get-Content -LiteralPath $productJson -Raw
            $prodObj = $prodRaw | ConvertFrom-Json
            $targetKey = "vs/code/electron-browser/workbench/workbench.html"

            if ($prodObj.checksums -and ($null -ne $prodObj.checksums.$targetKey)) {
                if (-not (Test-Path -LiteralPath "$productJson.bak")) {
                    Copy-Item -LiteralPath "$productJson" -Destination "$productJson.bak" -Force
                    Write-Host "[i] Created backup: $productJson.bak" -ForegroundColor DarkCyan
                }
                $prodObj.checksums.PSObject.Properties.Remove($targetKey)
                $updatedJson = $prodObj | ConvertTo-Json -Depth 20
                [System.IO.File]::WriteAllText($productJson, $updatedJson, [System.Text.Encoding]::UTF8)
                Write-Host "[v] Checksum bypass applied for workbench.html." -ForegroundColor Green
            } else {
                Write-Host "[v] Checksum bypass already active or not required." -ForegroundColor Green
            }
        } catch {
            Write-Host "[!] Notice on product.json: $_" -ForegroundColor Yellow
        }
    }

    # 5. Configure Markdown RTL preview
    Write-Host "[*] Configuring user Markdown preview..." -ForegroundColor Cyan
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
        Write-Host "[v] Markdown RTL preview styles & settings configured." -ForegroundColor Green
    } catch {
        Write-Host "[!] Warning updating settings.json: $_" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Antigravity IDE RTL and Vazirmatn successfully installed!" -ForegroundColor Green
    Write-Host "Please restart Antigravity IDE to apply all visual changes." -ForegroundColor Cyan
}

# Alias for seamless usage
Set-Alias -Name setup-antigravity-rtl -Value Setup-AntigravityRtl -Scope Global -ErrorAction SilentlyContinue

# If executed directly as a script (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.' -and $MyInvocation.Line -match 'setup\.ps1') {
    Setup-AntigravityRtl @args
}
