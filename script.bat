@echo off
setlocal enabledelayedexpansion

echo =================================================================
echo        프로그램 자동 설치 및 설정 스크립트
echo =================================================================
echo.
echo 설치 가능한 프로그램:
echo   1. Google Chrome (GitHub 시작페이지 설정 포함)
echo   2. Visual Studio Code
echo   3. Batch to Exe Converter
echo.
echo 설치 방법을 선택해주세요:
echo   [Enter] 또는 [Y]: 모든 프로그램 설치
echo   [N]: 개별 프로그램 선택하여 설치
echo.
set /p "choice=선택 (Enter/Y/N): "

:: 기본값 처리 (엔터만 눌렀을 경우)
if "!choice!"=="" set "choice=Y"

:: 선택에 따른 분기
if /i "!choice!"=="Y" goto :install_all
if /i "!choice!"=="N" goto :select_programs
goto :invalid_choice

:invalid_choice
echo.
echo [오류] 잘못된 선택입니다. Enter, Y, 또는 N을 입력해주세요.
echo.
pause
exit /b

:select_programs
echo.
echo =================================================================
echo              개별 프로그램 선택
echo =================================================================
echo.

set /p "install_chrome=Google Chrome을 설치하시겠습니까? (Y/N): "
set /p "install_vscode=Visual Studio Code를 설치하시겠습니까? (Y/N): "
set /p "install_bat2exe=Batch to Exe Converter를 설치하시겠습니까? (Y/N): "

goto :start_installation

:install_all
echo.
echo 모든 프로그램을 설치합니다...
set "install_chrome=Y"
set "install_vscode=Y"
set "install_bat2exe=Y"

:start_installation
echo.
echo =================================================================
echo        선택된 프로그램의 설치를 시작합니다.
echo =================================================================
echo.
echo 잠시 기다려 주세요...
echo.

:: 다운로드 및 임시 파일 저장을 위한 폴더 설정
set "WORK_DIR=%TEMP%\Installers"
if not exist "%WORK_DIR%" (
    mkdir "%WORK_DIR%"
)
cd /d "%WORK_DIR%"

set "step=1"
set "total_steps=1"

:: 총 단계 수 계산
if /i "!install_chrome!"=="Y" set /a "total_steps+=2"
if /i "!install_vscode!"=="Y" set /a "total_steps+=1"
if /i "!install_bat2exe!"=="Y" set /a "total_steps+=1"

:: 1. 레지스트리 편집 제한 해제 시도
echo [!step!/!total_steps!] 레지스트리 편집 제한 정책 해제를 시도합니다...
set "VBS_SCRIPT=%TEMP%\unlock_reg.vbs"

:: VBScript 내용을 한 줄씩 임시 폴더에 씁니다.
echo On Error Resume Next > "%VBS_SCRIPT%"
echo Dim WshShell, RegKey >> "%VBS_SCRIPT%"
echo Set WshShell = CreateObject^("WScript.Shell"^) >> "%VBS_SCRIPT%"
echo RegKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableRegistryTools" >> "%VBS_SCRIPT%"
echo WshShell.RegWrite RegKey, 0, "REG_DWORD" >> "%VBS_SCRIPT%"
echo Set WshShell = Nothing >> "%VBS_SCRIPT%"

if exist "%VBS_SCRIPT%" (
    cscript //nologo "%VBS_SCRIPT%"
    echo 정책 해제 시도 완료.
) else (
    echo.
    echo [오류] 임시 파일 생성에 실패했습니다.
    echo 안티바이러스 프로그램이 파일 생성을 차단했거나,
    echo 시스템에 드문 문제가 있을 수 있습니다.
    echo.
    pause
    exit /b
)
echo.
set /a "step+=1"

:: 2. Google Chrome 설치
if /i "!install_chrome!"=="Y" (
    echo [!step!/!total_steps!] 최신 버전의 Google Chrome을 다운로드합니다...
    curl -L "https://dl.google.com/chrome/install/375.126/chrome_installer.exe" -o ChromeInstaller.exe
    
    if exist "ChromeInstaller.exe" (
        echo Chrome 다운로드 완료.
    ) else (
        echo [경고] Chrome 다운로드에 실패했습니다. 인터넷 연결을 확인해주세요.
        goto :skip_chrome
    )
    echo.
    set /a "step+=1"

    echo [!step!/!total_steps!] Google Chrome을 설치합니다...
    start /wait ChromeInstaller.exe /silent /install
    echo Google Chrome 설치 완료.
    
    :: GitHub 홈페이지 열기
    echo GitHub 홈페이지를 Chrome으로 엽니다...
    set "CHROME_PATH="
    if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
        set "CHROME_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe"
    ) else if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" (
        set "CHROME_PATH=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
    )

    if defined CHROME_PATH (
        start "" "!CHROME_PATH!" "https://github.com"
        echo GitHub 홈페이지를 열었습니다.
    ) else (
        echo [경고] Chrome 실행 파일을 찾을 수 없어 GitHub을 자동으로 열지 못했습니다.
    )

    :: Chrome 시작 페이지 설정
    echo Google Chrome의 시작 페이지를 https://github.com 으로 설정합니다...
    reg add "HKCU\Software\Policies\Google\Chrome" /v RestoreOnStartup /t REG_DWORD /d 4 /f > nul 2>&1
    reg add "HKCU\Software\Policies\Google\Chrome\RestoreOnStartupURLs" /v 1 /t REG_SZ /d "https://github.com" /f > nul 2>&1
    echo 시작 페이지 설정 완료.
    echo.
    set /a "step+=1"
    
    :skip_chrome
)

:: 3. Visual Studio Code 설치
if /i "!install_vscode!"=="Y" (
    echo [!step!/!total_steps!] 최신 버전의 VSCode를 다운로드하고 설치합니다...
    curl -L "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user" -o VSCodeSetup.exe
    
    if exist "VSCodeSetup.exe" (
        start /wait VSCodeSetup.exe /VERYSILENT /MERGETASKS=!runcode
        echo Visual Studio Code 설치 완료.
    ) else (
        echo [경고] VSCode 다운로드에 실패했습니다. 인터넷 연결을 확인해주세요.
    )
    echo.
    set /a "step+=1"
)

:: 4. Batch to Exe Converter 설치
if /i "!install_bat2exe!"=="Y" (
    echo [!step!/!total_steps!] Batch to Exe Converter를 다운로드하고 설치합니다...
    
    :: PowerShell을 사용하여 ZIP 파일 다운로드 및 압축 해제
    powershell -Command "& {try { Invoke-WebRequest -Uri 'https://ipfs.io/ipfs/QmPBp7wBSC9GukPUcp7LXFCGXBvc2e45PUfWUbCJzuLG65?filename=Bat_To_Exe_Converter.zip' -OutFile 'Bat_To_Exe_Converter.zip' -UserAgent 'Mozilla/5.0'; if (Test-Path 'Bat_To_Exe_Converter.zip') { Expand-Archive -Path 'Bat_To_Exe_Converter.zip' -DestinationPath '%USERPROFILE%\Desktop\Bat_To_Exe_Converter' -Force; Write-Host 'Batch to Exe Converter 압축 해제 완료: 바탕화면\Bat_To_Exe_Converter 폴더' } else { Write-Host '[경고] 파일 다운로드에 실패했습니다.' } } catch { Write-Host '[오류] 다운로드 중 문제가 발생했습니다:' $_.Exception.Message } }"
    
    echo Batch to Exe Converter 설치 완료.
    echo 설치 위치: %USERPROFILE%\Desktop\Bat_To_Exe_Converter
    echo.
    set /a "step+=1"
)

:: 5. 정리 작업
echo 다운로드한 임시 파일을 정리합니다...
cd /d "%~dp0"
rmdir /s /q "%WORK_DIR%" 2>nul
echo.

echo =================================================================
echo          선택된 프로그램의 설치가 완료되었습니다.
echo =================================================================
echo.
echo 설치된 프로그램:
if /i "!install_chrome!"=="Y" echo   ✓ Google Chrome (시작페이지: GitHub)
if /i "!install_vscode!"=="Y" echo   ✓ Visual Studio Code
if /i "!install_bat2exe!"=="Y" echo   ✓ Batch to Exe Converter (바탕화면 폴더)
echo.

pause
endlocal