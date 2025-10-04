import { Sparkles } from "lucide-react";
import { COLORS } from "@/constants";
import ChromeIcon from "@/assets/chrome.svg";
import VscodeIcon from "@/assets/vscode.svg";

export const Header = () => (
  <div className="mb-2">
    <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 backdrop-blur-sm border border-white/20">
      <Sparkles 
        className="w-4 h-4" 
        style={{ color: COLORS.yellow }}
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
