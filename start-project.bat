@echo off
echo Dang kiem tra moi truong...

REM Kiem tra Node.js
node --version > nul 2>&1
if %errorlevel% neq 0 (
    echo "Khong tim thay Node.js. Vui long cai dat Node.js (phien ban >= 18.18.0) tu https://nodejs.org/"
    pause
    exit /b 1
)

REM Kiem tra phien ban Node.js
for /f "tokens=1,2,3 delims=." %%a in ('node --version') do (
    set node_major=%%a
    set node_minor=%%b
)
set node_major=%node_major:~1%

if %node_major% LSS 18 (
    echo "Phien ban Node.js qua cu. Can phien ban >= 18.18.0"
    echo "Phien ban hien tai: %node_major%.%node_minor%"
    pause
    exit /b 1
)

if %node_major% EQU 18 (
    if %node_minor% LSS 18 (
        echo "Phien ban Node.js qua cu. Can phien ban >= 18.18.0"
        echo "Phien ban hien tai: %node_major%.%node_minor%"
        pause
        exit /b 1
    )
)

echo Node.js OK!

REM Kiem tra, go cai dat va cai dat lai pnpm
echo Dang go cai dat pnpm hien tai...
call npm uninstall -g pnpm >nul 2>&1
call npm uninstall -g corepack >nul 2>&1

echo Dang cai dat pnpm moi...
call npm install -g pnpm --force
if %errorlevel% neq 0 (
    echo "Khong the cai dat pnpm. Se dung npm thay the."
    set USE_NPM=1
) else (
    echo "Da cai dat pnpm thanh cong!"
    set USE_NPM=0
)

REM Kiem tra node_modules
if not exist "node_modules" (
    echo "Dang cai dat cac dependencies..."
    if %USE_NPM%==0 (
        call pnpm install
        if %errorlevel% neq 0 (
            echo "Loi khi dung pnpm, thu dung npm thay the..."
            call npm install
            if %errorlevel% neq 0 (
                echo "Khong the cai dat dependencies. Vui long thu lai sau."
                pause
                exit /b 1
            )
        )
    ) else (
        call npm install
        if %errorlevel% neq 0 (
            echo "Khong the cai dat dependencies. Vui long thu lai sau."
            pause
            exit /b 1
        )
    )
    echo "Da cai dat dependencies thanh cong!"
) else (
    echo Dependencies OK!
)

echo Dang khoi dong ung dung...
if %USE_NPM%==0 (
    call pnpm run dev
    if %errorlevel% neq 0 (
        echo "Loi khi dung pnpm, thu dung npm thay the..."
        call npm run dev
    )
) else (
    call npm run dev
)

pause