@echo off
setlocal enabledelayedexpansion
chcp 949 > nul

title Cyberstart

:main_menu
call :show_section_header "Cyberstart: 프로그램 자동 설치 및 설정 스크립트"
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
call :show_section_header "설치를 진행 할 프로그램 선택"
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
set "total_steps=1"
if /i "!install_chrome!"=="Y" set /a "total_steps+=4"
if /i "!install_vscode!"=="Y" set /a "total_steps+=1"
if /i "!install_bat2exe!"=="Y" set /a "total_steps+=1"

goto :start_installation

:start_installation
call :show_section_header "선택된 프로그램의 설치를 시작합니다"

set "WORK_DIR=%TEMP%\Installers"
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
cd /d "%WORK_DIR%"

if "%CD%" neq "%WORK_DIR%" (
    echo [오류] 작업 폴더로 이동할 수 없습니다: %WORK_DIR%
    pause
    exit /b
)

:: 1. 레지스트리 정책 해제
call :show_progress_message !step! !total_steps! "레지스트리 편집 제한 정책 해제를 시도합니다..."
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
set /a "step+=1"
timeout /t 1 > nul


if /i "!install_chrome!"=="Y" goto :chrome_install_start
goto :chrome_install_end

:chrome_install_start
call :show_section_header "Google Chrome 설치"
call :show_progress_message !step! !total_steps! "Google Chrome 설치 상태를 확인합니다..."

set "CHROME_INSTALLED=false"
set "CHROME_NEEDS_UPDATE=false"

if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" set "CHROME_INSTALLED=true"
if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" set "CHROME_INSTALLED=true"

if "!CHROME_INSTALLED!"=="true" (
    echo Chrome이 설치되어 있습니다. 버전을 확인합니다...
    call :check_chrome_version
    if "!CHROME_IS_LEGACY!"=="true" (
        set "CHROME_NEEDS_UPDATE=true"
        echo.
        echo 레거시 버전이므로 제거 후 재설치합니다.
    ) else (
        echo 최신 버전이므로 설치를 건너뜁니다.
    )
) else (
    echo Chrome이 설치되지 않았습니다. 설치를 시작합니다.
)

if "!CHROME_INSTALLED!"=="false" goto :chrome_fresh_install
if "!CHROME_NEEDS_UPDATE!"=="true" goto :chrome_update_install
goto :chrome_skip_installation

:chrome_update_install
set /a "step+=1"

:: 레거시 Chrome 제거
call :show_section_header "Google Chrome 업데이트"
call :show_progress_message !step! !total_steps! "레거시 Chrome을 제거합니다..."
call :uninstall_legacy_chrome
set /a "step+=1"
goto :chrome_fresh_install

:chrome_fresh_install
:: Chrome 다운로드
call :show_section_header "Google Chrome 설치"
call :show_progress_message !step! !total_steps! "최신 버전의 Google Chrome을 다운로드합니다..."
curl -L "https://dl.google.com/chrome/install/375.126/chrome_installer.exe" -o ChromeInstaller.exe --progress-bar
if not exist "ChromeInstaller.exe" (
    echo [경고] Chrome 다운로드 실패. 인터넷 연결을 확인해주세요.
    set "CHROME_ACTION=Failed"
    goto :chrome_install_end
)
set /a "step+=1"

:: Chrome 설치
call :show_section_header "Google Chrome 설치"
call :show_progress_message !step! !total_steps! "Google Chrome을 설치합니다 (완료될 때까지 대기)..."
start /wait ChromeInstaller.exe /install
if "!CHROME_NEEDS_UPDATE!"=="true" (
    set "CHROME_ACTION=Updated"
    echo Chrome 업데이트가 완료되었습니다.
) else (
    set "CHROME_ACTION=Installed"
    echo Chrome 신규 설치가 완료되었습니다.
)
goto :chrome_setup_start

:: --- Chrome이 이미 최신 버전으로 설치된 경우 여기로 점프합니다 ---
:chrome_skip_installation
set "CHROME_ACTION=Skipped"
if "!CHROME_NEEDS_UPDATE!"=="true" (
    set /a "step+=4"
) else (
    set /a "step+=3"
)
timeout /t 2 > nul
goto :chrome_setup_start

:: --- Chrome 설정 (공통 실행 부분) ---
:chrome_setup_start
call :show_section_header "Google Chrome 설정"
call :show_progress_message !step! !total_steps! "Chrome 설정을 완료합니다..."

set "CHROME_PATH="
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" set "CHROME_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe"
if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" set "CHROME_PATH=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
if defined CHROME_PATH start "" "!CHROME_PATH!" "https://github.com"

echo GitHub 홈페이지를 엽니다.
set /a "step+=1"
timeout /t 2 > nul

:chrome_install_end

if /i "!install_vscode!"=="Y" goto :vscode_install_start
goto :vscode_install_end

:vscode_install_start
call :show_section_header "Visual Studio Code 설치"
call :show_progress_message !step! !total_steps! "Visual Studio Code 설치를 진행합니다..."

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
set /a "step+=1"
timeout /t 2 > nul

:vscode_install_end

if /i "!install_bat2exe!"=="Y" goto :bat2exe_install_start
goto :bat2exe_install_end

:bat2exe_install_start
call :show_section_header "Batch to Exe Converter 다운로드"
call :show_progress_message !step! !total_steps! "Batch to Exe Converter를 다운로드 및 설치합니다..."

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
set /a "step+=1"
timeout /t 2 > nul

:bat2exe_install_end

goto :cleanup

:cleanup
call :show_section_header "임시 파일 정리"
echo.
echo 다운로드한 임시 파일을 정리합니다...
cd /d "%~dp0"
rmdir /s /q "%WORK_DIR%" 2>nul
echo 정리 완료.
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
    )
    if "!CHROME_ACTION!"=="Updated" (
        echo   - 레거시 버전 제거 후 최신 버전으로 업데이트 완료
    )
    if "!CHROME_ACTION!"=="Skipped" (
        echo   - 이미 최신 버전으로 설치되어 있어 건너뜀
    )
    if "!CHROME_ACTION!"=="Failed" (
        echo   - 다운로드 실패로 설치하지 못함
    )
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
)

if /i "!install_bat2exe!"=="Y" (
    echo ▶ Batch to Exe Converter
    if "!BAT2EXE_ACTION!"=="Installed" (
        echo   - 다운로드 및 압축 해제 완료 ^(바탕화면^)
    )
    if "!BAT2EXE_ACTION!"=="Failed" (
        echo   - 다운로드 실패로 설치하지 못함
    )
)

echo.
echo.
echo Made with ♥ by switch1220
echo.

pause
endlocal
exit /b

:: =================================================================
:: 섹션 헤더 출력 서브루틴
:: 사용법: call :show_section_header "섹션 제목"
:: =================================================================
:show_section_header
cls
echo =================================================================
echo                      %~1
echo =================================================================
goto :eof

:: =================================================================
:: 프로그레스와 함께 메시지 출력 서브루틴
:: 사용법: call :show_progress_message [단계] [총단계] "메시지"
:: =================================================================
:show_progress_message
call :draw_progress_bar %1 %2
echo [%1/%2] %~3
echo.
goto :eof

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

:: =================================================================
:: Chrome 버전 검사 서브루틴
:: 사용법: call :check_chrome_version
:: 결과: CHROME_IS_LEGACY 변수 설정 (true/false)
:: =================================================================
:check_chrome_version
setlocal
set "CHROME_IS_LEGACY=false"
set "CHROME_PATH="

:: Chrome 경로 찾기
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set "CHROME_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe"
) else if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" (
    set "CHROME_PATH=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
)

if not defined CHROME_PATH (
    endlocal & set "CHROME_IS_LEGACY=false"
    goto :eof
)

:: Chrome 버전 가져오기
powershell -Command "(Get-Item '%CHROME_PATH%').VersionInfo.ProductVersion" 2>nul > "%TEMP%\chrome_version.txt"
set "CHROME_VERSION="
for /f "tokens=*" %%v in (%TEMP%\chrome_version.txt) do (
    set "CHROME_VERSION=%%v"
)
del "%TEMP%\chrome_version.txt" 2>nul

if not defined CHROME_VERSION (
    echo [경고] Chrome 버전을 확인할 수 없습니다. 레거시로 간주합니다.
    endlocal & set "CHROME_IS_LEGACY=true"
    goto :eof
) else (
    echo 현재 Chrome 버전: !CHROME_VERSION!
)

:: 주 버전 번호 추출 (예: 120.0.6099.109 -> 120)
for /f "tokens=1 delims=." %%m in ("!CHROME_VERSION!") do set "MAJOR_VERSION=%%m"

:: Chrome 버전 130 미만은 레거시로 간주 (2024년 이전)
if !MAJOR_VERSION! LSS 130 (
    endlocal & set "CHROME_IS_LEGACY=true"
) else (
    endlocal & set "CHROME_IS_LEGACY=false"
)
goto :eof

:: =================================================================
:: 레거시 Chrome 제거 서브루틴
:: 사용법: call :uninstall_legacy_chrome
:: =================================================================
:uninstall_legacy_chrome
setlocal
echo.
echo [작업] 레거시 Chrome을 제거합니다...

:: Chrome 프로세스 종료
taskkill /f /im chrome.exe >nul 2>&1
taskkill /f /im GoogleUpdate.exe >nul 2>&1
timeout /t 2 > nul

:: Windows Installer를 사용한 제거 시도
echo   - Windows 설치 프로그램을 통한 제거 시도 중...
wmic product where "name like '%Google Chrome%'" call uninstall /nointeractive >nul 2>&1

:: 레지스트리 기반 제거 시도
echo   - 레지스트리 기반 제거 시도 중...
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "Google Chrome"') do (
    for /f "tokens=1" %%k in ("%%a") do (
        for /f "tokens=2*" %%u in ('reg query "%%k" /v UninstallString 2^>nul') do (
            if defined %%v (
                echo     실행 중: %%v --uninstall --force-uninstall
                start /wait "" %%v --uninstall --force-uninstall >nul 2>&1
            )
        )
    )
)

:: 사용자별 제거 시도
for /f "tokens=2*" %%a in ('reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "Google Chrome"') do (
    for /f "tokens=1" %%k in ("%%a") do (
        for /f "tokens=2*" %%u in ('reg query "%%k" /v UninstallString 2^>nul') do (
            if defined %%v (
                echo     실행 중: %%v --uninstall --force-uninstall
                start /wait "" %%v --uninstall --force-uninstall >nul 2>&1
            )
        )
    )
)

:: 폴더 직접 삭제
echo   - 잔여 파일 정리 중...
if exist "C:\Program Files\Google" (
    rmdir /s /q "C:\Program Files\Google" >nul 2>&1
)
if exist "C:\Program Files (x86)\Google" (
    rmdir /s /q "C:\Program Files (x86)\Google" >nul 2>&1
)
if exist "%LOCALAPPDATA%\Google" (
    rmdir /s /q "%LOCALAPPDATA%\Google" >nul 2>&1
)

echo   - 레거시 Chrome 제거 완료.
timeout /t 1 > nul
endlocal
goto :eof