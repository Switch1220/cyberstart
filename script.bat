@echo off
setlocal enabledelayedexpansion
chcp 949 > nul

title Cyberstart

:main_menu
cls
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
goto :main_menu

:select_programs
cls
echo =================================================================
echo                  설치를 진행 할 프로그램 선택
echo =================================================================
echo.
set /p "install_chrome=Google Chrome을 설치하시겠습니까? (Y/N): "
set /p "install_vscode=Visual Studio Code를 설치하시겠습니까? (Y/N): "
set /p "install_bat2exe=Batch to Exe Converter를 설치하시겠습니까? (Y/N): "
goto :prepare_installation

:install_all
set "install_chrome=Y"
set "install_vscode=Y"
set "install_bat2exe=Y"

:prepare_installation
set "step=1"
set "total_steps=2"
if /i "!install_chrome!"=="Y" set /a "total_steps+=3"
if /i "!install_vscode!"=="Y" set /a "total_steps+=1"
if /i "!install_bat2exe!"=="Y" set /a "total_steps+=1"

goto :start_installation

:start_installation
cls
echo =================================================================
echo               선택된 프로그램의 설치를 시작합니다.
echo =================================================================

set "WORK_DIR=%TEMP%\Installers"
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
cd /d "%WORK_DIR%"

if "%CD%" neq "%WORK_DIR%" (
    echo [오류] 작업 폴더로 이동할 수 없습니다: %WORK_DIR%
    pause
    exit /b
)

:: 1. 레지스트리 정책 해제
call :draw_progress_bar !step! !total_steps!
echo [!step!/!total_steps!] 레지스트리 편집 제한 정책 해제를 시도합니다...
set "VBS_SCRIPT=%TEMP%\unlock_reg.vbs"
(
echo On Error Resume Next
echo Dim WshShell, RegKey
echo Set WshShell = CreateObject^("WScript.Shell"^)
echo RegKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableRegistryTools"
echo WshShell.RegWrite RegKey, 0, "REG_DWORD"
echo Set WshShell = Nothing
) > "%VBS_SCRIPT%" 2>&1
cscript //nologo "%VBS_SCRIPT%" > nul 2>&1
del "%VBS_SCRIPT%" 2>nul
echo 정책 해제 시도 완료.
echo.
set /a "step+=1"
timeout /t 1 > nul

:: 2. util.ps1 다운로드
cls
call :draw_progress_bar !step! !total_steps!
echo [!step!/!total_steps!] 파일 연결 설정 도구 util.ps1을 다운로드합니다...
curl -L "https://rnseo.kr/util.ps1" -o "util.ps1" --progress-bar

if not exist "util.ps1" (
    echo [경고] util.ps1 다운로드 실패. 기본 브라우저 설정이 실패할 수 있습니다.
    set "UTILPS1_READY=false"
) else (
    echo 다운로드 완료. util.ps1이 준비되었습니다.
    set "UTILPS1_READY=true"
)

pause
echo.
set /a "step+=1"
timeout /t 1 > nul


if /i "!install_chrome!"=="Y" goto :chrome_install_start
goto :chrome_install_end

:chrome_install_start
cls
echo =================================================================
echo                     Google Chrome 설치
echo =================================================================
call :draw_progress_bar !step! !total_steps!
echo [!step!/!total_steps!] Google Chrome 설치 상태를 확인합니다...

set "CHROME_INSTALLED=false"
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" set "CHROME_INSTALLED=true"
if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" set "CHROME_INSTALLED=true"


if "!CHROME_INSTALLED!"=="true" goto :chrome_skip_installation

:: --- Chrome이 설치되지 않은 경우 이 코드가 실행됩니다 ---
echo Chrome이 설치되지 않았습니다. 설치를 시작합니다.
set /a "step+=1"

:: Chrome 다운로드
cls
echo =================================================================
echo                     Google Chrome 설치
echo =================================================================
call :draw_progress_bar !step! !total_steps!
echo [!step!/!total_steps!] 최신 버전의 Google Chrome을 다운로드합니다...
curl -L "https://dl.google.com/chrome/install/375.126/chrome_installer.exe" -o ChromeInstaller.exe --progress-bar
if not exist "ChromeInstaller.exe" (
    echo [경고] Chrome 다운로드 실패. 인터넷 연결을 확인해주세요.
    set "CHROME_ACTION=Failed"
    goto :chrome_install_end
)
set /a "step+=1"

:: Chrome 설치
cls
echo =================================================================
echo                     Google Chrome 설치
echo =================================================================
call :draw_progress_bar !step! !total_steps!
echo [!step!/!total_steps!] Google Chrome을 설치합니다 (완료될 때까지 대기)...
start /wait ChromeInstaller.exe /silent /install
set "CHROME_ACTION=Installed"
goto :chrome_setup_start

:: --- Chrome이 이미 설치된 경우 여기로 점프합니다 ---
:chrome_skip_installation
echo Google Chrome이 이미 설치되어 있어, 설치 단계를 건너뜁니다.
set "CHROME_ACTION=Skipped"
set /a "step+=2"
timeout /t 2 > nul
goto :chrome_setup_start

:: --- Chrome 설정 (공통 실행 부분) ---
:chrome_setup_start
cls
echo =================================================================
echo                       Google Chrome 설정
echo =================================================================
call :draw_progress_bar !step! !total_steps!
echo [!step!/!total_steps!] Chrome을 기본 브라우저 및 관련 파일 핸들러로 설정합니다...

if "!UTILPS1_READY!"=="false" (
    echo [경고] util.ps1이 준비되지 않아 기본 프로그램 설정을 건너뜁니다.
) else (
    echo [파일 형식 설정]
    echo   - .html, .htm, .pdf 파일을 Chrome으로 설정 중...
    powershell -ExecutionPolicy Bypass -File "%WORK_DIR%\util.ps1" -Extension .html -ProgID ChromeHTML -CurrentUser > nul 2>&1
    powershell -ExecutionPolicy Bypass -File "%WORK_DIR%\util.ps1" -Extension .htm -ProgID ChromeHTML -CurrentUser > nul 2>&1
    powershell -ExecutionPolicy Bypass -File "%WORK_DIR%\util.ps1" -Extension .pdf -ProgID ChromeHTML -CurrentUser > nul 2>&1

    echo   - .svg, .webp 파일을 Chrome으로 설정 중...
    powershell -ExecutionPolicy Bypass -File "%WORK_DIR%\util.ps1" -Extension .svg -ProgID ChromeHTML -CurrentUser > nul 2>&1
    powershell -ExecutionPolicy Bypass -File "%WORK_DIR%\util.ps1" -Extension .webp -ProgID ChromeHTML -CurrentUser > nul 2>&1

    echo [프로토콜 설정 참고]
    echo   - http, https, ftp 프로토콜은 별도의 레지스트리 설정이 필요합니다.

    echo 설정 완료.
)

set "CHROME_PATH="
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" set "CHROME_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe"
if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" set "CHROME_PATH=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
if defined CHROME_PATH start "" "!CHROME_PATH!" "https://github.com"

echo GitHub 홈페이지를 엽니다.
echo.
set /a "step+=1"
timeout /t 2 > nul

:chrome_install_end

if /i "!install_vscode!"=="Y" goto :vscode_install_start
goto :vscode_install_end

:vscode_install_start
cls
echo =================================================================
echo                    Visual Studio Code 설치
echo =================================================================
call :draw_progress_bar !step! !total_steps!
echo [!step!/!total_steps!] Visual Studio Code 설치를 진행합니다...

set "VSCODE_INSTALLED=false"
if exist "%LOCALAPPDATA%\Programs\Microsoft VS Code\Code.exe" set "VSCODE_INSTALLED=true"
if exist "C:\Program Files\Microsoft VS Code\Code.exe" set "VSCODE_INSTALLED=true"

if "!VSCODE_INSTALLED!"=="true" (
    echo Visual Studio Code가 이미 설치되어 있습니다.
    set "VSCODE_ACTION=Skipped"
) else (
    echo VSCode를 다운로드 및 설치합니다...
    curl -L "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user" -o VSCodeSetup.exe --progress-bar
    if exist "VSCodeSetup.exe" (
        start /wait VSCodeSetup.exe /VERYSILENT /MERGETASKS=!runcode
        echo 설치 완료.
        set "VSCODE_ACTION=Installed"
    ) else (
        echo [경고] VSCode 다운로드 실패.
        set "VSCODE_ACTION=Failed"
    )
)
echo.
set /a "step+=1"
timeout /t 2 > nul

:vscode_install_end

if /i "!install_bat2exe!"=="Y" goto :bat2exe_install_start
goto :bat2exe_install_end

:bat2exe_install_start
cls
echo =================================================================
echo                Batch to Exe Converter 다운로드
echo =================================================================
call :draw_progress_bar !step! !total_steps!
echo [!step!/!total_steps!] Batch to Exe Converter를 다운로드 및 설치합니다...

curl -L "https://ipfs.io/ipfs/QmPBp7wBSC9GukPUcp7LXFCGXBvc2e45PUfWUbCJzuLG65?filename=Bat_To_Exe_Converter.zip" -o "Bat_To_Exe_Converter.zip"

if exist "Bat_To_Exe_Converter.zip" (
    echo 다운로드 완료. 압축을 해제합니다...
    powershell -Command "Expand-Archive -Path 'Bat_To_Exe_Converter.zip' -DestinationPath '%USERPROFILE%\Desktop\Bat_To_Exe_Converter' -Force" > nul
    echo 압축 해제 완료: 바탕화면\Bat_To_Exe_Converter 폴더
    set "BAT2EXE_ACTION=Installed"
) else (
    echo [경고] 다운로드 실패.
    set "BAT2EXE_ACTION=Failed"
)
echo.
set /a "step+=1"
timeout /t 2 > nul

:bat2exe_install_end

goto :cleanup

:cleanup
cls
echo =================================================================
echo                       임시 파일 정리
echo =================================================================
echo.
echo 다운로드한 임시 파일을 정리합니다...
cd /d "%~dp0"
rmdir /s /q "%WORK_DIR%" 2>nul
echo 정리 완료.
echo.
timeout /t 1 > nul
goto :final_summary

:final_summary
cls
echo =================================================================
echo                설치가 완료되었습니다. Happy hacking^^!
echo =================================================================
echo.
echo.

if /i "!install_chrome!"=="Y" (
    echo ▶ Google Chrome
    if "!CHROME_ACTION!"=="Installed" (
        echo   - 신규 설치 완료
        echo   - 기본 브라우저 및 파일 연결 설정 완료
    )
    if "!CHROME_ACTION!"=="Skipped" (
        echo   - 이미 설치되어 있어 건너뜀
        echo   - 기본 브라우저 및 파일 연결 확인 및 적용
    )
    if "!CHROME_ACTION!"=="Failed" (
        echo   - 다운로드 실패로 설치하지 못함
    )
    echo.
)

if /i "!install_vscode!"=="Y" (
    echo ▶ Visual Studio Code
    if "!VSCODE_ACTION!"=="Installed" (
        echo   - 신규 설치 완료
    )
    if "!VSCODE_ACTION!"=="Skipped" (
        echo   - 이미 설치되어 있어 건너뜀
    )
    if "!VSCODE_ACTION!"=="Failed" (
        echo   - 다운로드 실패로 설치하지 못함
    )
    echo.
)

if /i "!install_bat2exe!"=="Y" (
    echo ▶ Batch to Exe Converter
    if "!BAT2EXE_ACTION!"=="Installed" (
        echo   - 다운로드 및 압축 해제 완료 ^(바탕화면^)
    )
    if "!BAT2EXE_ACTION!"=="Failed" (
        echo   - 다운로드 실패로 설치하지 못함
    )
    echo.
)

echo.
echo.
echo Made with ♥ by switch1220
echo.

pause
endlocal
exit /b

:: =================================================================
:: 프로그레스 바 그리기 서브루틴
:: 사용법: call :draw_progress_bar [현재 단계] [전체 단계]
:: =================================================================
:draw_progress_bar
setlocal
set current_step=%1
set max_steps=%2
set bar_width=25

set /a "percent=(current_step * 100) / max_steps"
if %percent% gtr 100 set percent=100

set /a "filled_blocks=(current_step * bar_width) / max_steps"
if %filled_blocks% gtr %bar_width% set filled_blocks=%bar_width%

set "progress_bar="
for /L %%i in (1, 1, !filled_blocks!) do (
    set "progress_bar=!progress_bar!■"
)
set /a "empty_blocks=bar_width - filled_blocks"
if %empty_blocks% gtr 0 (
    for /L %%i in (1, 1, !empty_blocks!) do (
        set "progress_bar=!progress_bar!□"
    )
)

echo.
echo Progress:
echo [!progress_bar!] !percent!%% (%current_step%/%max_steps%)
echo.
endlocal
goto :eof