export type FileName = "cyberstart.exe" | "kollus.exe";

export type DownloadState = "idle" | "downloading" | "completed" | "error";

export interface FileOption {
  value: FileName;
  label: string;
}

export interface DownloadButtonProps {
  state: DownloadState;
  selectedFile: FileName;
  onFileChange: (file: FileName) => void;
  onDownload: (file?: FileName) => void;
}

export interface DownloadCardProps {
  state: DownloadState;
  selectedFile: FileName;
  onFileChange: (file: FileName) => void;
  onDownload: (file?: FileName) => void;
}
