import { Download, CheckCircle, AlertCircle } from "lucide-react";
import type { DownloadState } from "@/types";

interface ButtonContent {
  icon: React.ReactElement;
  text: string;
}

export const getButtonContent = (state: DownloadState): ButtonContent => {
  const contentMap: Record<DownloadState, ButtonContent> = {
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
