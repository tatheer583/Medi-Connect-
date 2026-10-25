# Copies the golden-rendered logo PNGs to every platform target.
# Regenerate goldens first:  flutter test test/logo_golden_test.dart --update-goldens
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot   # mobile/
$g = Join-Path $root 'test\goldens'

$map = @{
    'logo_512.png'          = @('web\icons\Icon-512.png', 'assets\icons\app_icon.png')
    'logo_maskable_512.png' = @('web\icons\Icon-maskable-512.png')
    'logo_192.png'          = @('web\icons\Icon-192.png', 'web\favicon.png', 'android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png')
    'logo_maskable_192.png' = @('web\icons\Icon-maskable-192.png')
    'logo_144.png'          = @('android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png')
    'logo_96.png'           = @('android\app\src\main\res\mipmap-xhdpi\ic_launcher.png')
    'logo_72.png'           = @('android\app\src\main\res\mipmap-hdpi\ic_launcher.png')
    'logo_48.png'           = @('android\app\src\main\res\mipmap-mdpi\ic_launcher.png')
}

foreach ($entry in $map.GetEnumerator()) {
    $src = Join-Path $g $entry.Key
    foreach ($dest in $entry.Value) {
        $destPath = Join-Path $root $dest
        $destDir = Split-Path -Parent $destPath
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }
        Copy-Item $src $destPath -Force
        Write-Host "  $entry.Key -> $dest"
    }
}
Write-Host "`nLogo assets updated." -ForegroundColor Green
