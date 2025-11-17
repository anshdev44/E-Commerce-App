@echo off
echo ========================================
echo Finding your computer's IP address...
echo ========================================
echo.
echo This is the IP address you need to use in App/lib/config.dart
echo Make sure your phone and computer are on the SAME Wi-Fi network!
echo.
ipconfig | findstr /i "IPv4"
echo.
echo ========================================
echo Copy the IP address above and update:
echo App/lib/config.dart -> computerIpAddress
echo ========================================
pause

