@echo off
setlocal enabledelayedexpansion

echo =================================================================
echo          Cyberstart: 프로그램 자동 설치 및 설정 스크립트
echo =================================================================
echo.
echo 설치 가능한 프로그램:
echo   1. Google Chrome
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
echo                  설치를 진행 할 프로그램 선택
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
echo               선택된 프로그램의 설치를 시작합니다.
echo =================================================================
echo.
echo 잠시 기다려 주세요...
echo.

set "WORK_DIR=%TEMP%\Installers"

echo 작업 디렉토리 설정: !WORK_DIR!
if not exist "%WORK_DIR%" (
    echo 작업 폴더를 생성합니다...
    mkdir "%WORK_DIR%"
    
    if not exist "%WORK_DIR%" (
        echo [오류] 작업 폴더 생성에 실패했습니다: %WORK_DIR%
        echo 권한 문제이거나 디스크 공간이 부족할 수 있습니다.
        pause
        exit /b
    )
)

echo 작업 폴더로 이동합니다...

cd /d "%WORK_DIR%"

if "%CD%" neq "%WORK_DIR%" (
    echo [오류] 작업 폴더로 이동할 수 없습니다.
    echo 현재 위치: %CD%
    echo 목표 위치: %WORK_DIR%
    pause
    exit /b
)

set "step=1"
set "total_steps=1"

if /i "!install_chrome!"=="Y" set /a "total_steps+=3"
if /i "!install_vscode!"=="Y" set /a "total_steps+=1"
if /i "!install_bat2exe!"=="Y" set /a "total_steps+=1"

echo [!step!/!total_steps!] 레지스트리 편집 제한 정책 해제를 시도합니다...
set "VBS_SCRIPT=%TEMP%\unlock_reg.vbs"

echo VBScript 파일을 생성합니다: !VBS_SCRIPT!

(
echo On Error Resume Next
echo Dim WshShell, RegKey
echo Set WshShell = CreateObject^("WScript.Shell"^)
echo RegKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableRegistryTools"
echo WshShell.RegWrite RegKey, 0, "REG_DWORD"
echo Set WshShell = Nothing
) > "%VBS_SCRIPT%" 2>&1

if not exist "%VBS_SCRIPT%" (
    echo [오류] VBScript 파일 생성에 실패했습니다.
    echo 안티바이러스 프로그램이 파일 생성을 차단했거나,
    echo 시스템에 드문 문제가 있을 수 있습니다.
    echo 임시 폴더: %TEMP%
    pause
    exit /b
)

echo VBScript 파일이 생성되었습니다. 실행합니다...
cscript //nologo "%VBS_SCRIPT%"

if errorlevel 1 (
    echo [경고] VBScript 실행 중 오류가 발생했습니다.
) else (
    echo 정책 해제 시도 완료.
)

del "%VBS_SCRIPT%" 2>nul

echo.
set /a "step+=1"

if /i "!install_chrome!"=="Y" goto :chrome_install_start
goto :chrome_install_end

:chrome_install_start
echo [!step!/!total_steps!] Google Chrome 설치 상태를 확인합니다...

set "CHROME_INSTALLED=false"
set "CHROME_PATH="

if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set "CHROME_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe"
    set "CHROME_INSTALLED=true"
) else if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" (
    set "CHROME_PATH=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
    set "CHROME_INSTALLED=true"
)

if "!CHROME_INSTALLED!"=="true" (
    echo Google Chrome이 이미 설치되어 있습니다.
    echo 설치 경로: !CHROME_PATH!
    echo Chrome 설치 단계를 건너뜁니다.
    set /a "step+=1"
    goto :chrome_browser_setup
)

echo Chrome이 설치되지 않아 설치를 진행합니다...
echo.
set /a "step+=1"

echo [!step!/!total_steps!] 최신 버전의 Google Chrome을 다운로드합니다...

curl -L "https://dl.google.com/chrome/install/375.126/chrome_installer.exe" -o ChromeInstaller.exe

if exist "ChromeInstaller.exe" (
    echo Chrome 다운로드 완료.
) else (
    echo [경고] Chrome 다운로드에 실패했습니다. 인터넷 연결을 확인해주세요.
    goto :chrome_install_end
)

echo.
set /a "step+=1"

echo [!step!/!total_steps!] Google Chrome을 설치합니다...

start /wait ChromeInstaller.exe /silent /install

echo Google Chrome 설치 완료.

if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set "CHROME_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe"
) else if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" (
    set "CHROME_PATH=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
)

echo.
set /a "step+=1"

:chrome_browser_setup
echo [!step!/!total_steps!] Chrome을 기본 브라우저로 설정하고 URL 핸들링을 구성합니다...

reg add "HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" /v ProgId /t REG_SZ /d "ChromeHTML" /f > nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" /v ProgId /t REG_SZ /d "ChromeHTML" /f > nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice" /v ProgId /t REG_SZ /d "ChromeHTML" /f > nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\Shell\Associations\FileAssociations\.html\UserChoice" /v ProgId /t REG_SZ /d "ChromeHTML" /f > nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\Shell\Associations\FileAssociations\.htm\UserChoice" /v ProgId /t REG_SZ /d "ChromeHTML" /f > nul 2>&1

reg add "HKCU\Software\Clients\StartMenuInternet" /ve /t REG_SZ /d "Google Chrome" /f > nul 2>&1
reg add "HKCU\Software\RegisteredApplications" /v "Google Chrome" /t REG_SZ /d "Software\Clients\StartMenuInternet\Google Chrome\Capabilities" /f > nul 2>&1

reg add "HKCR\ChromeHTML" /ve /t REG_SZ /d "Chrome HTML Document" /f > nul 2>&1
reg add "HKCR\ChromeHTML\shell\open\command" /ve /t REG_SZ /d "\"!CHROME_PATH!\" -- \"%%1\"" /f > nul 2>&1
reg add "HKCR\ChromeHTML\DefaultIcon" /ve /t REG_SZ /d "\"!CHROME_PATH!\",0" /f > nul 2>&1

reg add "HKCR\http\shell\open\command" /ve /t REG_SZ /d "\"!CHROME_PATH!\" -- \"%%1\"" /f > nul 2>&1
reg add "HKCR\https\shell\open\command" /ve /t REG_SZ /d "\"!CHROME_PATH!\" -- \"%%1\"" /f > nul 2>&1
reg add "HKCR\ftp\shell\open\command" /ve /t REG_SZ /d "\"!CHROME_PATH!\" -- \"%%1\"" /f > nul 2>&1

reg add "HKCR\.html" /ve /t REG_SZ /d "ChromeHTML" /f > nul 2>&1
reg add "HKCR\.htm" /ve /t REG_SZ /d "ChromeHTML" /f > nul 2>&1
reg add "HKCR\.shtml" /ve /t REG_SZ /d "ChromeHTML" /f > nul 2>&1
reg add "HKCR\.xht" /ve /t REG_SZ /d "ChromeHTML" /f > nul 2>&1
reg add "HKCR\.xhtml" /ve /t REG_SZ /d "ChromeHTML" /f > nul 2>&1

echo Chrome 기본 브라우저 설정 완료.

echo GitHub 홈페이지를 Chrome으로 엽니다...

if defined CHROME_PATH (
    start "" "!CHROME_PATH!" "https://github.com"
    echo GitHub 홈페이지를 열었습니다.
) else (
    echo [경고] Chrome 실행 파일을 찾을 수 없어 GitHub을 자동으로 열지 못했습니다.
)

echo.
set /a "step+=1"

:chrome_install_end

if /i "!install_vscode!"=="Y" goto :vscode_install_start
goto :vscode_install_end

:vscode_install_start
echo [!step!/!total_steps!] Visual Studio Code 설치 상태를 확인합니다...

set "VSCODE_INSTALLED=false"
set "VSCODE_PATH="

REM 사용자별 설치 경로 확인 (기본 설치 방식)
if exist "%LOCALAPPDATA%\Programs\Microsoft VS Code\Code.exe" (
    set "VSCODE_PATH=%LOCALAPPDATA%\Programs\Microsoft VS Code\Code.exe"
    set "VSCODE_INSTALLED=true"
REM 시스템 전체 설치 경로 확인
) else if exist "C:\Program Files\Microsoft VS Code\Code.exe" (
    set "VSCODE_PATH=C:\Program Files\Microsoft VS Code\Code.exe"
    set "VSCODE_INSTALLED=true"
REM Program Files (x86) 경로 확인
) else if exist "C:\Program Files (x86)\Microsoft VS Code\Code.exe" (
    set "VSCODE_PATH=C:\Program Files (x86)\Microsoft VS Code\Code.exe"
    set "VSCODE_INSTALLED=true"
)

if "!VSCODE_INSTALLED!"=="true" (
    echo Visual Studio Code가 이미 설치되어 있습니다.
    echo 설치 경로: !VSCODE_PATH!
    echo VSCode 설치 단계를 건너뜁니다.
    set /a "step+=1"
    goto :vscode_install_end
)

echo VSCode가 설치되지 않아 설치를 진행합니다...
echo.
set /a "step+=1"

echo [!step!/!total_steps!] 최신 버전의 VSCode를 다운로드하고 설치합니다...

curl -L "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user" -o VSCodeSetup.exe

if exist "VSCodeSetup.exe" (
    start /wait VSCodeSetup.exe /VERYSILENT /MERGETASKS=!runcode
    echo Visual Studio Code 설치 완료.
    
    REM 설치 후 경로 다시 확인
    if exist "%LOCALAPPDATA%\Programs\Microsoft VS Code\Code.exe" (
        set "VSCODE_PATH=%LOCALAPPDATA%\Programs\Microsoft VS Code\Code.exe"
    ) else if exist "C:\Program Files\Microsoft VS Code\Code.exe" (
        set "VSCODE_PATH=C:\Program Files\Microsoft VS Code\Code.exe"
    ) else if exist "C:\Program Files (x86)\Microsoft VS Code\Code.exe" (
        set "VSCODE_PATH=C:\Program Files (x86)\Microsoft VS Code\Code.exe"
    )
) else (
    echo [경고] VSCode 다운로드에 실패했습니다. 인터넷 연결을 확인해주세요.
)
echo.
set /a "step+=1"

:vscode_install_end

if /i "!install_bat2exe!"=="Y" goto :bat2exe_install_start
goto :bat2exe_install_end

:bat2exe_install_start
echo [!step!/!total_steps!] Batch to Exe Converter를 다운로드하고 설치합니다...

curl -L "https://ipfs.io/ipfs/QmPBp7wBSC9GukPUcp7LXFCGXBvc2e45PUfWUbCJzuLG65?filename=Bat_To_Exe_Converter.zip" -o "Bat_To_Exe_Converter.zip"

if exist "Bat_To_Exe_Converter.zip" (
    echo 다운로드 완료. 압축을 해제합니다...
    powershell -Command "Expand-Archive -Path 'Bat_To_Exe_Converter.zip' -DestinationPath '%USERPROFILE%\Desktop\Bat_To_Exe_Converter' -Force"
    echo Batch to Exe Converter 압축 해제 완료: 바탕화면\Bat_To_Exe_Converter 폴더
) else (
    echo [경고] Batch to Exe Converter 다운로드에 실패했습니다.
)

echo.
set /a "step+=1"

:bat2exe_install_end

echo 다운로드한 임시 파일을 정리합니다...
cd /d "%~dp0"

rmdir /s /q "%WORK_DIR%" 2>nul

echo.

echo =================================================================
echo       선택된 프로그램의 설치가 완료되었습니다. Happy hacking!
echo.
echo.
echo                  Made with ♥ by switch1220
echo =================================================================
echo.
echo 설치된 프로그램:
if /i "!install_chrome!"=="Y" echo   ▶ Google Chrome (기본 브라우저)
if /i "!install_vscode!"=="Y" echo   ▶ Visual Studio Code
if /i "!install_bat2exe!"=="Y" echo   ▶ Batch to Exe Converter (바탕화면 폴더)
echo.

pause
endlocal
