@echo off
setlocal

:: =================================================================
echo        Chrome, VSCode �ڵ� ��ġ �� ������ �����մϴ�.
echo =================================================================
echo.
echo �� ��ũ��Ʈ�� ���� �۾��� �ڵ����� �����մϴ�.
echo 1. ������Ʈ�� ���� ���� ��å ���� �õ�
echo 2. Chrome �� VSCode �ֽ� ���� ��ġ (����� ����)
echo 3. Chrome ���� �������� https://github.com ���� ����
echo.
echo ��� ��ٷ� �ּ���...
echo.

:: �ٿ�ε� �� ��ġ�� ���� �ӽ� ���� ����
set "DOWNLOAD_DIR=%TEMP%\Installers"
if not exist "%DOWNLOAD_DIR%" (
    mkdir "%DOWNLOAD_DIR%"
)
cd /d "%DOWNLOAD_DIR%"

:: 1. ������Ʈ�� ���� ���� ���� �õ�
echo [1/5] '������Ʈ�� ���� ����' ��å�� �����մϴ�...
set "VBS_SCRIPT=%TEMP%\unlock_reg.vbs"
(
    echo On Error Resume Next
    echo Dim WshShell, RegKey
    echo Set WshShell = CreateObject("WScript.Shell")
    echo RegKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableRegistryTools"
    echo WshShell.RegWrite RegKey, 0, "REG_DWORD"
    echo Set WshShell = Nothing
) > "%VBS_SCRIPT%"

cscript //nologo "%VBS_SCRIPT%"
del "%VBS_SCRIPT%"
echo ��å ���� �õ� �Ϸ�.
echo.

:: 2-1. Google Chrome �ٿ�ε�
echo [2/5] �ֽ� ������ Google Chrome�� �ٿ�ε��մϴ�...
curl -L "https://dl.google.com/chrome/install/375.126/chrome_installer.exe" -o ChromeInstaller.exe
echo.

:: 2-2. Google Chrome ��ġ
echo [3/5] Google Chrome�� ��ġ�մϴ�...
start /wait ChromeInstaller.exe /silent /install
echo Google Chrome ��ġ �Ϸ�.
echo.

:: 2-3. Google Chrome ���� ������ ����
echo [4/5] Google Chrome�� ���� �������� https://github.com ���� �����մϴ�...
:: RestoreOnStartup: 4�� 'Ư�� ������ ��� ����'�� �ǹ��մϴ�.
reg add "HKCU\Software\Policies\Google\Chrome" /v RestoreOnStartup /t REG_DWORD /d 4 /f > nul
:: RestoreOnStartupURLs: ���� �� �� ������ ����� �����մϴ�.
reg add "HKCU\Software\Policies\Google\Chrome\RestoreOnStartupURLs" /v 1 /t REG_SZ /d "https://github.com" /f > nul
echo ���� ������ ���� �Ϸ�.
echo.
echo -----------------------------------------------------------------
echo.

:: 3. Visual Studio Code �ٿ�ε� �� ��ġ
echo [5/5] �ֽ� ������ VSCode(����� ����)�� �ٿ�ε��ϰ� ��ġ�մϴ�...
curl -L "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user" -o VSCodeSetup.exe
start /wait VSCodeSetup.exe /VERYSILENT /MERGETASKS=!runcode
echo Visual Studio Code ��ġ �Ϸ�.
echo.

:: 4. ���� �۾�
echo �ٿ�ε��� ��ġ ������ �����մϴ�...
cd /d "%~dp0"
rmdir /s /q "%DOWNLOAD_DIR%"
echo.

echo =================================================================
echo          ��� ��ġ �� ������ ���������� �Ϸ�Ǿ����ϴ�.
echo =================================================================
echo.

pause
endlocal