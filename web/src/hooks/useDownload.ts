import { useState } from "react";
import type { DownloadState, FileName } from "@/types";
import { TIMINGS } from "@/constants";
import { downloadFile } from "@/utils/download";

export const useDownload = () => {
  const [state, setState] = useState<DownloadState>("idle");
  const [selectedFile, setSelectedFile] = useState<FileName>("cyberstart.exe");

  const startDownload = async (file?: FileName) => {
    setState("downloading");
    
    const targetFile = file ?? selectedFile;

    try {
      await downloadFile(targetFile);
      setState("completed");
      setTimeout(() => setState("idle"), TIMINGS.COMPLETED_RESET);
    } catch (error) {
      setState("error");
      setTimeout(() => setState("idle"), TIMINGS.ERROR_RESET);
    }
  };

  return { 
    state, 
    selectedFile, 
    setSelectedFile, 
    startDownload
  };
};
