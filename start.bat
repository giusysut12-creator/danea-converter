@echo off
title Bolla PDF → Danea Converter

echo ============================================
echo   Bolla PDF ^> Danea Excel Converter
echo ============================================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ERRORE: Python non trovato. Installalo da https://python.org
    echo.
    echo In alternativa, apri direttamente converter.html nel browser!
    pause
    exit /b 1
)

REM Install dependencies if needed
echo Verifica dipendenze...
pip install -r requirements.txt -q

echo.
echo Avvio server su http://localhost:8000
echo Premi CTRL+C per fermare.
echo.

REM Open browser after 2 seconds
start "" /min cmd /c "timeout /t 2 /nobreak >nul && start http://localhost:8000"

REM Start server
cd /d "%~dp0"
python main.py
pause
