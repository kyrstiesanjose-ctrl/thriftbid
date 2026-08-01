@echo off
REM ============================================================
REM start_bidbot.bat
REM Place this inside: C:\xampp\htdocs\thriftbid\bidbot
REM (same folder as app.py, requirements.txt, and your .env)
REM Double-click to start MySQL (XAMPP) + the BidBot service.
REM ============================================================

REM Database is now the shared cloud MySQL (ccscloud.dlsu.edu.ph),
REM not a local service — so we wait for network/DNS to be ready at
REM login instead of polling a local port.
echo Waiting for network connection to database server...
:waitloop
powershell -Command "try { (New-Object System.Net.Sockets.TcpClient('ccscloud.dlsu.edu.ph', 21003)).Close(); exit 0 } catch { exit 1 }"
if errorlevel 1 (
    timeout /t 2 >nul
    goto waitloop
)
echo Database server is reachable.

cd /d "%~dp0"

REM Create the venv once if it doesn't exist yet
if not exist venv (
    echo Creating virtual environment...
    python -m venv venv
)

call venv\Scripts\activate

echo Installing/checking dependencies...
pip install -r requirements.txt --quiet

echo Building/refreshing the search index...
python build_index.py

echo Starting BidBot service on port 8000...
uvicorn app:app --host 0.0.0.0 --port 8000

pause