"use client"

import { useState } from "react"
import { Download, CheckCircle, Sparkles } from "lucide-react"
import { Button } from "@/components/ui/button"

import ChromeIcon from './assets/chrome.svg';
import VscodeIcon from './assets/vscode.svg';

export default function App() {
  const [isDownloading, setIsDownloading] = useState(false)
  const [isComplete, setIsComplete] = useState(false)

  const handleDownload = async () => {
    setIsDownloading(true)

    await new Promise((resolve) => setTimeout(resolve, 500))

    setIsDownloading(false)
    setIsComplete(true)

    setTimeout(() => setIsComplete(false), 2000)
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 flex items-center justify-center p-4 relative overflow-hidden">
      {/* 배경 장식 요소들 */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-purple-500 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-pulse"></div>
        <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-pink-500 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-pulse delay-1000"></div>
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-blue-500 rounded-full mix-blend-multiply filter blur-xl opacity-10 animate-pulse delay-500"></div>
      </div>

      {/* 메인 컨텐츠 */}
      <div className="relative z-10 text-center mx-auto">
        {/* 제목 */}
        <div className="mb-2">
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 backdrop-blur-sm border border-white/20 ">
            <Sparkles className="w-4 h-4 text-yellow-400" />
            <span className="text-sm font-medium text-white/90">.exe로 문제없이</span>
          </div>

          <h1 className="text-5xl md:text-7xl font-medium bg-gradient-to-r from-white via-purple-200 to-pink-200 bg-clip-text text-transparent mb-6 leading-tight">
            원클릭으로
          </h1>

          <div className="flex flex-row justify-center items-center text-xl md:text-2xl text-white/70 font-light">
          <img src={ChromeIcon} alt="" className="w-6 ml-2 mr-1" />
          <span>
            Chrome과
          </span>
          <img src={VscodeIcon} alt="" className="w-6 ml-2 mr-1" />
          <span>
            Vscode를 빠르게 설치하고싶다면.
          </span>
          </div>
        </div>

        {/* 다운로드 카드 */}
        <div className="bg-white/10 backdrop-blur-lg rounded-3xl border border-white/20 p-8 md:p-12 shadow-2xl">
          {/* 설명 텍스트 */}
          <div className="mb-8">
            <p className="text-white/80 text-lg mb-2">사지방에서 매번 설치하기 귀찮아</p>
            <p className="text-white/60 text-sm">ㅇㅈ?</p>
          </div>

          {/* 다운로드 버튼 */}
          <Button
            onClick={handleDownload}
            disabled={isDownloading}
            className={`
              relative overflow-hidden group
              h-16 px-12 text-lg font-semibold
              bg-gradient-to-r from-purple-600 to-pink-600 
              hover:from-purple-700 hover:to-pink-700
              border-0 rounded-full
              transform transition-all duration-300
              hover:scale-105 hover:shadow-2xl hover:shadow-purple-500/25
              disabled:opacity-70 disabled:cursor-not-allowed disabled:transform-none
              ${isComplete ? "bg-gradient-to-r from-green-600 to-emerald-600" : ""}
            `}
          >
            {/* 버튼 배경 효과 */}
            <div className="absolute inset-0 bg-gradient-to-r from-white/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>

            {/* 버튼 내용 */}
            <div className="relative flex items-center gap-3 font-light">
              {isDownloading ? (
                <>
                  <div className="w-6 h-6 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                  <span>Downloading...</span>
                </>
              ) : isComplete ? (
                <>
                  <CheckCircle className="w-6 h-6" />
                  <span>Download Complete!</span>
                </>
              ) : (
                <>
                  <Download className="w-6 h-6 group-hover:animate-bounce" />
                  <span>Download</span>
                </>
              )}
            </div>

            {/* 버튼 글로우 효과 */}
            <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-purple-600 to-pink-600 blur-lg opacity-50 group-hover:opacity-75 transition-opacity duration-300 -z-10"></div>
          </Button>
        </div>

        {/* 하단 텍스트 */}
        <p className="mt-8 text-white/40 text-sm">
          By 일병 한믿음
        </p>
      </div>
    </div>
  )
}
