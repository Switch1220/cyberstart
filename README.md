# Cyberstart

사지방에서 컴퓨터를 킬 때 마다 손수 크롬과 vscode를 설치해야 하는 장병을 위한 프로그램 입니다.

홈페이지: [switch1220.github.io/cyberstart](https://switch1220.github.io/cyberstart)

### 별거 없는 주요 기능

- 윈도우 레지스트리 편집 제한 해제. 용도는 전 몰라유~
- Chrome 설치 후 `github.com`을 띄워 줌!
- vscode 설치

### 사지방 팁

- bat, ps1 파일은 직접적으로 실행 못하지만 `exe` 실행파일로 변환한 뒤 실행하면 가능함.
- 레지스트리 편집은 아래 스크립트를 실행하면 이후 bat, ps1 파일에서 직접 수정이 가능함.

```cmd
set "VBS_SCRIPT=%TEMP%\unlock.vbs"

echo On Error Resume Next > "%VBS_SCRIPT%"
echo Dim WshShell, RegKey >> "%VBS_SCRIPT%"
echo Set WshShell = CreateObject^("WScript.Shell"^) >> "%VBS_SCRIPT%"
echo RegKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableRegistryTools" >> "%VBS_SCRIPT%"
echo WshShell.RegWrite RegKey, 0, "REG_DWORD" >> "%VBS_SCRIPT%"
echo Set WshShell = Nothing >> "%VBS_SCRIPT%"

cscript //nologo "%VBS_SCRIPT%"
```

### 본인의 셋업

Vscode는 JS/TS에 대해 전체 프로젝트 기반 IntelliSense를 제공하지만, 아래와 같은 경우 일부 기능만 제공하는 부분 모드(partial mode)로 작동함.

- vscode.dev / github.dev / github codespace 등에서 브라우저로 실행 중일 때
- 가상 파일 시스템(GitHub Repositories 확장 등)을 사용할 때

위 경우, 열려 있는 파일에는 IntelliSense가 작동하지만, 파일 간 기능(예: `자동 import`, `정의로 이동` 등)은 제한됨.

참고: [Partial Intellisense mode][1]

그래서 필자는 로컬에 설치 후 `Codespace > Open in Visual Studio Code`로 연동 해 사용하고 있음.

추가로 대학교 휴학 후 입대했다면 휴가 나가서 서류를 준비해 github student pack을 신청하는 것이 좋다. [Github Pro 혜택][2]

### 군대생활

#### 매크로

군대에서 사용하는 한글, 한셀의 매크로 기능을 잘 활용한다면 이쁨받을 수 있다. 개인정비 시간에 열심히 `Visual Basic`을 배워놓고 필요한 도구들을 만들어 보자.

#### Python

국방망을 잘 찾아보면 `Anaconda` 설치파일이 있다(허용된 부대 한정). Flask, Beautifulsoup 등 여러 유용한 라이브러리가 탑재되어있어 별걸 다 만들 수 있다. 하지만 잘 알아보고 사용하는게 좋다. 보안감사빔을 맞게되면...

####

---

### 여담

**7포병여단 758대대 본부포대는 전설이다..! 뭔 훈련을 2주동안 가냐**

[1]: https://code.visualstudio.com/docs/nodejs/working-with-javascript#_partial-intellisense-mode
[2]: https://docs.github.com/en/get-started/learning-about-github/githubs-plans#github-pro
