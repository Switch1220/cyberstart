# Cyberstart

사지방에서 컴퓨터를 킬 때 마다 손수 크롬과 vscode를 설치하는 용사를 위한 프로그램 입니다.

### 별거 없는 주요 기능
- Chrome 설치 후 `github.com`을 띄워 줌!
- vscode 설치

### 사지방 팁
- bat, ps1 파일은 직접적으로 실행 못하지만 `exe` 실행파일로 변환한 뒤 실행하면 가능 함.
- 레지스트리 편집또한 다르지 않게 vbs로 저장한 뒤


```cmd
set "VBS_SCRIPT=%TEMP%\some.vbs"

echo On Error Resume Next > "%VBS_SCRIPT%"
echo Dim WshShell, RegKey >> "%VBS_SCRIPT%"
echo Set WshShell = CreateObject^("WScript.Shell"^) >> "%VBS_SCRIPT%"
echo RegKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableRegistryTools" >> "%VBS_SCRIPT%"
echo WshShell.RegWrite RegKey, 0, "REG_DWORD" >> "%VBS_SCRIPT%"
echo Set WshShell = Nothing >> "%VBS_SCRIPT%"

cscript //nologo "%VBS_SCRIPT%"
```

**7포병여단 758대대 본부포대 화이팅!**
