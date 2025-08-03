"use client";

import { useState } from "react";
import { Download, CheckCircle, Sparkles, AlertCircle } from "lucide-react";
import { Button } from "@/components/ui/button";

import ChromeIcon from "./assets/chrome.svg";
import VscodeIcon from "./assets/vscode.svg";
import GithubIcon from "./assets/github.svg";

const FILE_NAME = `cyberstart.exe`;
const DOWNLOAD_URL = `https://rnseo.kr/${FILE_NAME}`;

type DownloadState = "idle" | "downloading" | "completed" | "error";

// 배경 장식
const BackgroundDecorations = () => (
  <div className="absolute inset-0 overflow-hidden">
    <div className="absolute -top-40 -right-40 w-80 h-80 bg-purple-500 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-pulse"></div>
    <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-pink-500 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-pulse delay-1000"></div>
    <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-blue-500 rounded-full mix-blend-multiply filter blur-xl opacity-10 animate-pulse delay-500"></div>
  </div>
);

const Header = () => (
  <div className="mb-2">
    <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 backdrop-blur-sm border border-white/20">
      <Sparkles className="w-4 h-4 text-yellow-400" />
      <span className="text-sm font-medium text-white/90">.exe로 문제없이</span>
    </div>

    <h1 className="text-5xl md:text-7xl font-medium bg-gradient-to-r from-white via-purple-200 to-pink-200 bg-clip-text text-transparent md:mb-6 leading-tight">
      원클릭으로
    </h1>

    <div className="flex flex-col md:flex-row justify-center items-center text-xl md:text-2xl text-white/70 font-light">
      <div className="flex flex-row">
        <img src={ChromeIcon} alt="" className="w-6 ml-2 mr-1" />
        <span>Chrome과</span>
      </div>
      <div className="flex flex-row">
        <img src={VscodeIcon} alt="" className="w-6 ml-2 mr-1" />
        <span>Vscode를</span>
      </div>
      <span>빠르게 설치하고싶다면.</span>
    </div>
  </div>
);

const getButtonContent = (state: DownloadState) => {
  const contentMap = {
    idle: {
      icon: (
        <Download className="w-6 h-6 group-hover:animate-bounce transition-transform duration-300" />
      ),
      text: "다운로드",
    },
    downloading: {
      icon: (
        <div className="w-6 h-6 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
      ),
      text: "다운로드 중...",
    },
    completed: {
      icon: <CheckCircle className="w-6 h-6 animate-in zoom-in duration-500" />,
      text: "다운로드 완료!",
    },
    error: {
      icon: <AlertCircle className="w-6 h-6 animate-in zoom-in duration-300" />,
      text: "에러 발생",
    },
  };

  return contentMap[state];
};

// 버튼 스타일 반환 함수 (애니메이션 추가)
const getButtonStyles = (state: DownloadState) => {
  const baseStyles = `
    relative overflow-hidden group
    h-16 px-12 text-lg font-semibold
    border-0 rounded-full
    transform transition-all duration-500 ease-in-out
    hover:scale-105 hover:shadow-2xl hover:shadow-purple-500/25
    disabled:opacity-70 disabled:cursor-not-allowed disabled:transform-none
  `;

  const stateStyles = {
    idle: "bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700",
    downloading: "bg-gradient-to-r from-purple-600 to-pink-600 animate-pulse",
    completed:
      "bg-gradient-to-r from-green-600 to-emerald-600 animate-in zoom-in duration-500",
    error:
      "bg-gradient-to-r from-red-600 to-orange-600 animate-in fade-in duration-300",
  };

  return `${baseStyles} ${stateStyles[state]}`;
};

// 글로우 효과 스타일 반환 함수 (애니메이션 추가)
const getGlowStyles = (state: DownloadState) => {
  const glowColors = {
    idle: "from-purple-600 to-pink-600",
    downloading: "from-purple-600 to-pink-600",
    completed: "from-green-600 to-emerald-600",
    error: "from-red-600 to-orange-600",
  };

  return `absolute inset-0 rounded-2xl blur-lg opacity-50 group-hover:opacity-75 transition-all duration-500 ease-in-out -z-10 bg-gradient-to-r ${glowColors[state]}`;
};

// 다운로드 버튼 컴포넌트 (애니메이션 개선)
const DownloadButton = ({
  state,
  onDownload,
}: {
  state: DownloadState;
  onDownload: () => void;
}) => {
  const { icon, text } = getButtonContent(state);

  return (
    <div className="flex justify-center">
      <div className="relative">
        <Button
          onClick={onDownload}
          disabled={state === "downloading"}
          className={getButtonStyles(state)}
        >
          {/* 버튼 배경 효과 */}
          <div className="absolute inset-0 bg-gradient-to-r from-white/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>

          {/* 버튼 내용 */}
          <div className="relative flex items-center gap-3 font-light">
            <div className="transition-all duration-300 ease-in-out">
              {icon}
            </div>
            <span className="transition-all duration-300 ease-in-out">
              {text}
            </span>
          </div>

          {/* 버튼 글로우 효과 */}
          <div className={getGlowStyles(state)}></div>
        </Button>

        {/* 성공/에러 시 추가 효과 */}
        {state === "completed" && (
          <div className="absolute inset-0 pointer-events-none">
            <div className="absolute inset-0 bg-green-400/20 rounded-full animate-ping"></div>
          </div>
        )}

        {state === "error" && (
          <div className="absolute inset-0 pointer-events-none">
            <div className="absolute inset-0 bg-red-500/50 rounded-full animate-pulse"></div>
          </div>
        )}
      </div>
    </div>
  );
};

// 다운로드 카드 컴포넌트
const DownloadCard = ({
  state,
  onDownload,
}: {
  state: DownloadState;
  onDownload: () => void;
}) => {
  const hasMessage = state !== "idle";

  return (
    <div className="bg-white/10 backdrop-blur-lg rounded-3xl border border-white/20 p-8 md:p-10 shadow-2xl transition-all duration-500 ease-in-out hover:bg-white/15">
      {/* 설명 텍스트 */}
      <div className="mb-6">
        <div className="text-white/80 text-balance text-lg mb-2 transition-colors duration-300">
          <span>사지방에서 매번</span>
          <span>설치하기 귀찮아.</span>
        </div>
        <p className="text-white/60 text-balance text-sm transition-colors duration-300">
          그래서준비했습니다당신을위한원클릭프로그램
        </p>
      </div>

      {/* 다운로드 버튼 */}
      <DownloadButton state={state} onDownload={onDownload} />

      {/* 상태별 추가 메시지 - 높이 변화를 부드럽게 */}
      <div
        className={`overflow-hidden transition-all duration-500 ease-in-out ${
          hasMessage ? "max-h-20 mt-2" : "max-h-0 mt-0"
        }`}
      >
        <div className="flex items-center justify-center">
          {state === "downloading" && (
            <p className="text-white/60 text-sm animate-in fade-in duration-300">
              잠시만 기다려주세요...
            </p>
          )}
          {state === "completed" && (
            <p className="text-green-400 text-sm animate-in slide-in-from-bottom duration-500">
              다운로드가 완료되었습니다! 🎉
            </p>
          )}
          {state === "error" && (
            <div className="flex flex-col md:flex-row md:gap-1 text-red-400 text-sm text-balance animate-in slide-in-from-bottom duration-300">
              <span>다운로드 중 문제가 발생했습니다.</span>
              <span>다시 시도해주세요.</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

// 다운로드 상태 관리 훅
const useDownload = () => {
  const [state, setState] = useState<DownloadState>("idle");

  const startDownload = async () => {
    setState("downloading");

    try {
      await downloadFile();
      setState("completed");
      setTimeout(() => setState("idle"), 2000);
    } catch (error) {
      setState("error");
      setTimeout(() => setState("idle"), 3000);
    }
  };

  return { state, startDownload };
};

// 메인 컴포넌트
export default function App() {
  const { state, startDownload } = useDownload();

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 flex items-center justify-center p-4 relative overflow-hidden">
      <BackgroundDecorations />

      <div className="relative z-10 text-center mx-auto">
        <Header />
        <DownloadCard state={state} onDownload={startDownload} />
        <div className="mt-4 flex items-center justify-center gap-2 text-sm">
          <a
            href="https://github.com/Switch1220"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1 px-2 py-1 text-white/80 hover:text-white transition-colors duration-300 rounded-md hover:bg-white/10"
            title="GitHub Profile"
          >
            by =한믿음
          </a>
          <a
            href="https://github.com/Switch1220/cyberstart"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1 px-2 py-1 text-white/80 hover:text-white transition-colors duration-300 rounded-md hover:bg-white/10"
            title="GitHub Repository"
          >
            <img src={GithubIcon} alt="GitHub" className="w-4 h-4" />
            <span>cyberstart</span>
          </a>
        </div>
      </div>
    </div>
  );
}

// 다운로드 유틸리티 함수
async function downloadFile(): Promise<void> {
  await new Promise((resolve) => setTimeout(resolve, 600)); // 600ms 대기

  const response = await fetch(DOWNLOAD_URL, {
    method: "GET",
    headers: {
      "Cache-Control": "no-cache", // 캐시 무효화
      Pragma: "no-cache", // 구형 브라우저용
      Expires: "0",
    },
  });

  if (!response.ok) {
    throw new Error("네트워크 오류.");
  }

  const blob = await response.blob();
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement("a");

  a.href = url;
  a.download = FILE_NAME;
  document.body.appendChild(a);
  a.click();
  a.remove();

  window.URL.revokeObjectURL(url);
}
