@echo off
:: Recovery Image 업데이트 스크립트
:: 관리자 권한으로 실행 필요

echo ========================================
echo Recovery Image 업데이트 스크립트
echo ========================================
echo.

:: 관리자 권한 확인
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 오류: 관리자 권한으로 실행해야 합니다.
    echo 명령 프롬프트를 관리자 권한으로 실행 후 다시 시도하세요.
    pause
    exit /b 1
)

:: 변수 설정
set RECOVERY_DRIVE=
set TEMP_DIR=C:\Temp\RecoveryUpdate
set BACKUP_DIR=C:\Temp\RecoveryBackup

echo 1. Recovery 파티션 찾는 중...

:: Recovery 파티션 찾기
for /f "tokens=1,2" %%i in ('diskpart /s recovery_list.txt 2^>nul') do (
    if "%%j"=="Recovery" set RECOVERY_DRIVE=%%i
)

:: diskpart 명령 파일 생성
echo list volume > recovery_list.txt
diskpart /s recovery_list.txt > volume_list.txt 2>nul

:: Recovery 파티션 드라이브 문자 할당
echo sel vol Recovery > assign_drive.txt
echo assign letter=R >> assign_drive.txt
diskpart /s assign_drive.txt >nul 2>&1

set RECOVERY_DRIVE=R:

echo Recovery 파티션: %RECOVERY_DRIVE%
echo.

echo 2. 임시 디렉토리 생성...
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

echo 3. 기존 install.wim 백업...
if exist "%RECOVERY_DRIVE%\Recovery\WindowsRE\install.wim" (
    copy "%RECOVERY_DRIVE%\Recovery\WindowsRE\install.wim" "%BACKUP_DIR%\install.wim.backup"
    echo 백업 완료: %BACKUP_DIR%\install.wim.backup
) else (
    echo 경고: 기존 install.wim을 찾을 수 없습니다.
)

echo.
echo 4. 현재 시스템으로 새 이미지 캡처 중...
echo 이 작업은 시간이 오래 걸립니다. 잠시 기다려주세요...

:: DISM을 사용해 현재 시스템 캡처
dism /Capture-Image /ImageFile:"%TEMP_DIR%\install.wim" /CaptureDir:C:\ /Name:"Windows Recovery" /Description:"Current System Recovery Image" /Compress:max

if %errorLevel% neq 0 (
    echo 오류: 이미지 캡처에 실패했습니다.
    goto :cleanup
)

echo.
echo 5. 기존 install.wim 교체...

:: 읽기 전용 속성 제거
if exist "%RECOVERY_DRIVE%\Recovery\WindowsRE\install.wim" (
    attrib -r "%RECOVERY_DRIVE%\Recovery\WindowsRE\install.wim"
)

:: 새 이미지로 교체
copy "%TEMP_DIR%\install.wim" "%RECOVERY_DRIVE%\Recovery\WindowsRE\install.wim" /Y

if %errorLevel% neq 0 (
    echo 오류: install.wim 교체에 실패했습니다.
    echo 백업 파일로 복원 중...
    copy "%BACKUP_DIR%\install.wim.backup" "%RECOVERY_DRIVE%\Recovery\WindowsRE\install.wim" /Y
    goto :cleanup
)

echo.
echo 6. 복구 환경 업데이트...

:: Windows RE 비활성화 후 재활성화하여 새 이미지 적용
reagentc /disable
timeout /t 3 /nobreak >nul
reagentc /enable

if %errorLevel% neq 0 (
    echo 경고: 복구 환경 재활성화에 문제가 있을 수 있습니다.
    echo 수동으로 'reagentc /enable' 명령을 실행해보세요.
)

echo.
echo 7. 복구 환경 상태 확인...
reagentc /info

:cleanup
echo.
echo 8. 정리 작업...

:: 임시 파일 정리
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
if exist "recovery_list.txt" del "recovery_list.txt"
if exist "volume_list.txt" del "volume_list.txt"
if exist "assign_drive.txt" del "assign_drive.txt"

:: Recovery 파티션 드라이브 문자 제거
echo sel vol R > remove_drive.txt
echo remove letter=R >> remove_drive.txt
diskpart /s remove_drive.txt >nul 2>&1
if exist "remove_drive.txt" del "remove_drive.txt"

echo.
echo ========================================
echo 작업 완료!
echo ========================================
echo.
echo - 백업 파일: %BACKUP_DIR%\install.wim.backup
echo - 복구 시 현재 시스템 상태로 복원됩니다.
echo.
echo 주의사항:
echo 1. 시스템 복구 시 현재 설치된 모든 프로그램과 설정이 복원됩니다.
echo 2. 개인 데이터는 별도 백업을 권장합니다.
echo 3. 백업 파일은 안전한 곳에 보관하세요.
echo.
pause
