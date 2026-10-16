# Konfiguruje srodowisko do pracy nad projektem bursa_app na Windowsie.
# Mozna uruchamiac wielokrotnie - pomija kroki, ktore sa juz zrobione.

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$FlutterDir = 'C:\dev\flutter'
$FlutterBin = Join-Path $FlutterDir 'bin'
$AndroidStudioExe = 'C:\Program Files\Android\Android Studio\bin\studio64.exe'
$AndroidSdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk'

function Step($text) { Write-Host "`n==> $text" -ForegroundColor Cyan }
function Ok($text) { Write-Host "    [OK] $text" -ForegroundColor Green }
function Info($text) { Write-Host "    $text" }
function Warn($text) { Write-Host "    [!] $text" -ForegroundColor Yellow }

function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

function Has-Command($name) { [bool](Get-Command $name -ErrorAction SilentlyContinue) }

function Winget-Install($id, $label) {
    if (-not (Has-Command 'winget')) {
        throw "Brak programu winget. Zainstaluj recznie: $label (instrukcja w README.md)."
    }
    Info "Instaluje $label przez winget (moze poprosic o zgode administratora)..."
    winget install --id $id -e --source winget --accept-package-agreements --accept-source-agreements
    Refresh-Path
}

Write-Host '=============================================' -ForegroundColor Cyan
Write-Host '  bursa_app - konfiguracja srodowiska' -ForegroundColor Cyan
Write-Host '=============================================' -ForegroundColor Cyan

Step '1/7 Git'
if (Has-Command 'git') { Ok (git --version) } else { Winget-Install 'Git.Git' 'Git' ; Ok 'Git zainstalowany' }

Step '2/7 Android Studio'
if (Test-Path $AndroidStudioExe) { Ok 'Android Studio jest zainstalowane' }
else { Winget-Install 'Google.AndroidStudio' 'Android Studio'; Ok 'Android Studio zainstalowane' }

Step '3/7 Flutter SDK'
if (Has-Command 'flutter') {
    Ok 'Flutter jest juz w PATH'
} else {
    if (-not (Test-Path $FlutterDir)) {
        Info "Pobieram Flutter (kanal stable) do $FlutterDir ..."
        New-Item -ItemType Directory -Force -Path (Split-Path $FlutterDir) | Out-Null
        git clone https://github.com/flutter/flutter.git -b stable $FlutterDir
    }
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($userPath -notlike "*$FlutterBin*") {
        [Environment]::SetEnvironmentVariable('Path', "$userPath;$FlutterBin", 'User')
        Info "Dodano $FlutterBin do zmiennej PATH."
    }
    $env:Path += ";$FlutterBin"
    Info 'Pierwsze uruchomienie Fluttera pobiera narzedzia - to potrwa kilka minut.'
    flutter --version
    Ok 'Flutter gotowy'
}

Step '4/7 Tryb dewelopera Windows'
$devMode = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -ErrorAction SilentlyContinue
if ($devMode.AllowDevelopmentWithoutDevLicense -eq 1) { Ok 'Tryb dewelopera wlaczony' }
else {
    Warn 'Tryb dewelopera jest wylaczony. Otwieram Ustawienia - wlacz "Tryb dewelopera".'
    Start-Process 'ms-settings:developers'
    Read-Host '    Nacisnij Enter, gdy go wlaczysz'
}

Step '5/7 Android SDK i Command-line Tools'
while (-not (Test-Path (Join-Path $AndroidSdk 'cmdline-tools'))) {
    Warn 'Brakuje Android SDK albo Command-line Tools. Otwieram Android Studio.'
    Info '  a) Przy pierwszym uruchomieniu wybierz instalacje "Standard" i poczekaj na pobranie.'
    Info '  b) Na ekranie powitalnym: More Actions -> SDK Manager -> zakladka "SDK Tools".'
    Info '  c) Zaznacz "Android SDK Command-line Tools (latest)" i kliknij Apply.'
    Info '  d) Utworz emulator: More Actions -> Virtual Device Manager -> "+".'
    if (Test-Path $AndroidStudioExe) { Start-Process $AndroidStudioExe }
    Read-Host '    Nacisnij Enter, gdy skonczysz'
}
Ok "Android SDK: $AndroidSdk"
flutter config --android-sdk $AndroidSdk | Out-Null

Step '6/7 flutter doctor'
flutter doctor

Step '7/7 Zaleznosci projektu'
Push-Location $ProjectRoot
try { flutter pub get; Ok 'Zaleznosci pobrane' } finally { Pop-Location }

Write-Host "`n=============================================" -ForegroundColor Green
Write-Host '  Gotowe!' -ForegroundColor Green
Write-Host '=============================================' -ForegroundColor Green
Info 'Dalej:'
Info '  1. Otworz NOWY terminal (zeby odswiezyc PATH).'
Info '  2. Uruchom emulator w Android Studio (Device Manager -> przycisk Play).'
Info '  3. W folderze projektu wpisz:  flutter run'
Info 'Szczegoly i rozwiazywanie problemow: README.md'
