import { useState, useEffect, useRef } from "react";
import { ChevronDown } from "lucide-react";
import { Button } from "@/components/ui/button";
import type { DownloadButtonProps, FileName } from "@/types";
import { FILE_OPTIONS, COLORS } from "@/constants";
import { getButtonStyles, getGlowStyles, getInlineStyles } from "@/utils/download";
import { getButtonContent } from "./ButtonContent";

export const DownloadButton = ({
  state,
  selectedFile,
  onFileChange,
  onDownload,
}: DownloadButtonProps) => {
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

  const handleFileSelect = (file: FileName) => {
    onFileChange(file);
    setIsDropdownOpen(false);
    onDownload(file);
  };

  return (
    <div className="flex justify-center">
      <div className="relative" ref={dropdownRef}>
        <Button
          onClick={() => onDownload()}
          disabled={state === "downloading"}
          className={`${getButtonStyles(state)} group`}
          style={getInlineStyles(state)}
        >
          {/* 버튼 배경 효과 */}
          <div className="absolute inset-0 rounded-full bg-gradient-to-r from-white/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>

          {/* 버튼 내용 */}
          <div className="relative flex items-center gap-3 font-light ml-1" style={{ color: COLORS.white }}>
            <div className="transition-all duration-300 ease-in-out">
              {icon}
            </div>
            <span className="transition-all duration-300 ease-in-out">
              {text}
            </span>
          </div>

          {/* 드롭다운 버튼 */}
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
              style={{ color: COLORS.white }}
            />
          </div>

          {/* 버튼 글로우 효과 */}
          <div className={getGlowStyles(state)}></div>
        </Button>

        {/* 드롭다운 메뉴 */}
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
