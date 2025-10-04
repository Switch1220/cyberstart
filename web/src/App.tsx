"use client";

import { useState, useEffect, useRef } from "react";
import { Download, CheckCircle, Sparkles, AlertCircle, ChevronDown } from "lucide-react";
import { Button } from "@/components/ui/button";

import ChromeIcon from "./assets/chrome.svg";
import VscodeIcon from "./assets/vscode.svg";
import GithubIcon from "./assets/github.svg";

type FileName = "cyberstart.exe" | "kollus.exe";

const FILE_OPTIONS: { value: FileName; label: string }[] = [
  { value: "cyberstart.exe", label: "기본" },
  { value: "kollus.exe", label: "Kollus Agent 포함" },
];

const getDownloadUrl = (fileName: FileName) => `https://rnseo.kr/${fileName}`;

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
      <Sparkles 
        className="w-4 h-4" 
        style={{ color: '#facc15' }} // 명시적 yellow-400 색상
      />
      <span className="text-sm font-medium text-white/90">.exe로 문제없이</span>
    </div>

    <h1 className="text-5xl md:mt-3 md:text-7xl font-medium bg-gradient-to-r from-white via-purple-200 to-pink-200 bg-clip-text text-transparent md:mb-6 leading-tight">
      원클릭으로
    </h1>

    <div className="flex flex-col md:flex-row md:mt-4 justify-center items-center text-xl md:text-2xl text-white/70 font-light">
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

// 버튼 스타일 반환 함수 (레거시 브라우저 폴백 추가)
const getButtonStyles = (state: DownloadState) => {
  const baseStyles = `
    relative overflow-hidden
    h-16 pl-8 text-lg font-semibold
    border-0 rounded-full
    transition-all duration-500 ease-in-out
    hover:scale-105 hover:shadow-2xl hover:shadow-purple-500/25
    disabled:opacity-70 disabled:cursor-not-allowed disabled:hover:scale-100
  `;

  const stateStyles = {
    idle: "bg-purple-600 hover:bg-purple-700", // 레거시 폴백
    downloading: "bg-purple-600", // 레거시 폴백
    completed: "bg-green-600", // 레거시 폴백
    error: "bg-red-600", // 레거시 폴백
  };

  return `${baseStyles} ${stateStyles[state]}`;
};

// 글로우 효과 스타일 반환 함수 (레거시 브라우저 폴백 추가)
const getGlowStyles = (state: DownloadState) => {
  const baseGlowClass = "absolute inset-0 rounded-2xl blur-lg opacity-50 group-hover:opacity-75 transition-all duration-500 ease-in-out -z-10";
  
  const glowColors = {
    idle: "bg-purple-600", // 레거시 폴백
    downloading: "bg-purple-600", // 레거시 폴백  
    completed: "bg-green-600", // 레거시 폴백
    error: "bg-red-600", // 레거시 폴백
  };

  return `${baseGlowClass} ${glowColors[state]}`;
};

// 다운로드 버튼 컴포넌트 (레거시 브라우저 호환성 개선)
const DownloadButton = ({
  state,
  selectedFile,
  onFileChange,
  onDownload,
}: {
  state: DownloadState;
  selectedFile: FileName;
  onFileChange: (file: FileName) => void;
  onDownload: () => void;
}) => {
  const { icon, text } = getButtonContent(state);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // 외부 클릭 감지
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsDropdownOpen(false);
      }
    };

    if (isDropdownOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isDropdownOpen]);

  // 레거시 브라우저용 그라데이션 폴백
  const getInlineStyles = (state: DownloadState) => {
    const gradients = {
      idle: 'linear-gradient(to right, #9333ea, #db2777)',
      downloading: 'linear-gradient(to right, #9333ea, #db2777)', 
      completed: 'linear-gradient(to right, #059669, #047857)',
      error: 'linear-gradient(to right, #dc2626, #ea580c)',
    };

    return {
      background: gradients[state],
    };
  };

  const handleFileSelect = (file: FileName) => {
    onFileChange(file);
    setIsDropdownOpen(false);
    // 파일 선택 후 즉시 다운로드 시작
    onDownload();
  };

  return (
    <div className="flex justify-center">
      <div className="relative" ref={dropdownRef}>
        <Button
          onClick={onDownload}
          disabled={state === "downloading"}
          className={`${getButtonStyles(state)} group`}
          style={getInlineStyles(state)} // 인라인 스타일로 그라데이션 추가
        >
          {/* 버튼 배경 효과 */}
          <div className="absolute inset-0 rounded-full bg-gradient-to-r from-white/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>

          {/* 버튼 내용 */}
          <div className="relative flex items-center gap-3 font-light" style={{ color: '#ffffff' }}>
            <div className="transition-all duration-300 ease-in-out">
              {icon}
            </div>
            <span className="transition-all duration-300 ease-in-out">
              {text}
            </span>
          </div>

          {/* 드롭다운 버튼 (버튼 내부) */}
          <div
            role="button"
            tabIndex={state === "downloading" ? -1 : 0}
            onClick={(e) => {
              e.stopPropagation();
              if (state !== "downloading") {
                setIsDropdownOpen(!isDropdownOpen);
              }
            }}
            onKeyDown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                e.stopPropagation();
                if (state !== "downloading") {
                  setIsDropdownOpen(!isDropdownOpen);
                }
              }
            }}
            aria-disabled={state === "downloading"}
            aria-expanded={isDropdownOpen}
            aria-label="파일 선택"
            className={`
              group/dropdown relative overflow-hidden
              w-10 h-10 rounded-full
              flex items-center justify-center
              transition-all duration-300
              ${state === "downloading" ? "opacity-50 cursor-not-allowed" : "cursor-pointer"}
              bg-transparent
              hover:bg-white/10
              ml-1
            `}
          >
            {/* 호버 시 글래스 효과 */}
            <div className="absolute inset-0 rounded-full bg-white/0 group-hover/dropdown:bg-white/20 backdrop-blur-sm border border-transparent group-hover/dropdown:border-white/20 transition-all duration-300"></div>
            
            {/* 아이콘 */}
            <ChevronDown 
              className={`w-4 h-4 relative z-10 transition-all duration-300 ${
                isDropdownOpen ? 'rotate-180' : ''
              }`}
              style={{ color: '#ffffff' }}
            />
          </div>

          {/* 버튼 글로우 효과 */}
          <div className={getGlowStyles(state)}></div>
        </Button>

        {/* 드롭다운 메뉴 - Button 외부로 이동 */}
        {isDropdownOpen && (
          <div className="absolute top-full right-0 mt-2 z-50 overflow-hidden rounded-lg border border-white/20 bg-slate-900/95 backdrop-blur-sm shadow-xl min-w-[160px]">
            {FILE_OPTIONS.map((option) => (
              <button
                key={option.value}
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  handleFileSelect(option.value);
                }}
                className={`
                  w-full px-4 py-3 text-left
                  transition-all duration-200
                  ${
                    option.value === selectedFile
                      ? 'bg-purple-600/30 text-white'
                      : 'text-white/80 hover:bg-white/10 hover:text-white'
                  }
                `}
              >
                {option.label}
              </button>
            ))}
          </div>
        )}

        {/* 성공/에러 시 추가 효과 */}
        {state === "completed" && (
          <div className="absolute inset-0">
            <div className="absolute inset-0 bg-green-400/20 rounded-full animate-ping"></div>
          </div>
        )}

        {state === "error" && (
          <div className="absolute inset-0">
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
  selectedFile,
  onFileChange,
  onDownload,
}: {
  state: DownloadState;
  selectedFile: FileName;
  onFileChange: (file: FileName) => void;
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

      {/* 다운로드 버튼 (드롭다운 포함) */}
      <DownloadButton 
        state={state} 
        selectedFile={selectedFile}
        onFileChange={onFileChange}
        onDownload={onDownload} 
      />

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
  const [selectedFile, setSelectedFile] = useState<FileName>("cyberstart.exe");

  const startDownload = async () => {
    setState("downloading");

    try {
      await downloadFile(selectedFile);
      setState("completed");
      setTimeout(() => setState("idle"), 2000);
    } catch (error) {
      setState("error");
      setTimeout(() => setState("idle"), 3000);
    }
  };

  return { state, selectedFile, setSelectedFile, startDownload };
};

// 메인 컴포넌트
export default function App() {
  const { state, selectedFile, setSelectedFile, startDownload } = useDownload();

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 flex items-center justify-center p-4 relative overflow-hidden">
      <BackgroundDecorations />

      <div className="relative z-10 text-center mx-auto">
        <Header />
        <DownloadCard
          state={state}
          selectedFile={selectedFile}
          onFileChange={setSelectedFile}
          onDownload={startDownload}
        />
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
async function downloadFile(fileName: FileName): Promise<void> {
  await new Promise((resolve) => setTimeout(resolve, 600)); // 600ms 대기

  const downloadUrl = getDownloadUrl(fileName);
  const response = await fetch(downloadUrl, {
    method: "GET",
    headers: {
      "Cache-Control": "no-cache", // 캐시 무효화
      Pragma: "no-cache", // 구형 브라우저용
      Expires: "0",
    },
  });

  // @ts-ignore
  if (window.navigator && window.navigator.msSaveOrOpenBlob) {
    const blob = await response.blob();
    // @ts-ignore
    window.navigator.msSaveOrOpenBlob(blob, fileName);

    return;
  }

  if (!response.ok) {
    throw new Error("네트워크 오류.");
  }

  const blob = await response.blob();
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement("a");

  a.href = url;
  a.download = fileName;
  document.body.appendChild(a);
  a.click();
  a.remove();

  window.URL.revokeObjectURL(url);
}
