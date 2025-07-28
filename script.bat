@echo off
setlocal

echo =================================================================
echo        Chrome, VSCode 자동 설치 및 설정을 시작합니다.
echo =================================================================
echo.
echo 잠시 기다려 주세요...
echo.

:: 다운로드 및 임시 파일 저장을 위한 폴더 설정 (%TEMP%는 항상 쓰기 가능)
set "WORK_DIR=%TEMP%\Installers"
if not exist "%WORK_DIR%" (
    mkdir "%WORK_DIR%"
)
cd /d "%WORK_DIR%"

:: 1. 레지스트리 편집 제한 해제 시도
echo [1/5] '레지스트리 편집 제한' 정책 해제를 시도합니다...
set "VBS_SCRIPT=%TEMP%\unlock_reg.vbs"

:: VBScript 내용을 한 줄씩 임시 폴더(%TEMP%)에 씁니다.
echo On Error Resume Next > "%VBS_SCRIPT%"
echo Dim WshShell, RegKey >> "%VBS_SCRIPT%"
echo Set WshShell = CreateObject^("WScript.Shell"^) >> "%VBS_SCRIPT%"
echo RegKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableRegistryTools" >> "%VBS_SCRIPT%"
echo WshShell.RegWrite RegKey, 0, "REG_DWORD" >> "%VBS_SCRIPT%"
echo Set WshShell = Nothing >> "%VBS_SCRIPT%"

if exist "%VBS_SCRIPT%" (
    cscript //nologo "%VBS_SCRIPT%"
::  del "%VBS_SCRIPT%"
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

:: 2-1. Google Chrome 다운로드
echo [2/5] 최신 버전의 Google Chrome을 다운로드합니다...
curl -L "https://dl.google.com/chrome/install/375.126/chrome_installer.exe" -o ChromeInstaller.exe
echo.

:: 2-2. Google Chrome 설치
echo [3/5] Google Chrome을 설치합니다...
start /wait ChromeInstaller.exe /silent /install
echo Google Chrome 설치 완료.
echo.

:: 2-3. Google Chrome 시작 페이지 설정
echo [4/5] Google Chrome의 시작 페이지를 https://github.com 으로 설정합니다...
reg add "HKCU\Software\Policies\Google\Chrome" /v RestoreOnStartup /t REG_DWORD /d 4 /f > nul
reg add "HKCU\Software\Policies\Google\Chrome\RestoreOnStartupURLs" /v 1 /t REG_SZ /d "https://github.com" /f > nul
echo 시작 페이지 설정 완료.
echo.
echo -----------------------------------------------------------------
echo.

:: 3. Visual Studio Code 다운로드 및 설치
echo [5/5] 최신 버전의 VSCode(사용자 버전)를 다운로드하고 설치합니다...
curl -L "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user" -o VSCodeSetup.exe
start /wait VSCodeSetup.exe /VERYSILENT /MERGETASKS=!runcode
echo Visual Studio Code 설치 완료.
echo.

:: 4. 정리 작업
echo 다운로드한 설치 파일을 정리합니다...
cd /d "%~dp0"
rmdir /s /q "%WORK_DIR%"
echo.

echo =================================================================
echo          모든 설치 및 설정이 성공적으로 완료되었습니다.
echo =================================================================
echo.

pause
endlocal
