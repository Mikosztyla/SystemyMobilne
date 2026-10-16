@echo off
chcp 65001 >nul
cd /d "%~dp0.."
echo Sprawdzanie projektu (analiza + testy), prosze czekac...
(
  echo ==== flutter pub get ====
  call flutter pub get
  echo.
  echo ==== flutter analyze ====
  call flutter analyze
  echo.
  echo ==== flutter test ====
  call flutter test
) > check_log.txt 2>&1
type check_log.txt
echo.
echo Wynik zapisany w check_log.txt
pause
