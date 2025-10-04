import GithubIcon from "@/assets/github.svg";

export const Footer = () => (
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
);
