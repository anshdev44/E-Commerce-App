@echo off
echo ========================================
echo Testing Backend Connection
echo ========================================
echo.
echo Testing connection to: http://10.209.39.25:8000
echo.
curl -X GET http://10.209.39.25:8000/ 2>nul
if %errorlevel% equ 0 (
    echo.
    echo SUCCESS: Backend is accessible!
) else (
    echo.
    echo FAILED: Cannot connect to backend
    echo.
    echo Make sure:
    echo 1. Backend server is running (python backend/main.py)
    echo 2. Firewall allows connections on port 8000
    echo 3. IP address 10.209.39.25 is correct
    echo 4. Phone and computer are on the same Wi-Fi network
)
echo.
pause

