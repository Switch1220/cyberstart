import type { FileOption } from "@/types";

export const FILE_OPTIONS: FileOption[] = [
  { value: "cyberstart.exe", label: "기본" },
  { value: "kollus.exe", label: "Kollus Agent 포함" },
];

export const COLORS = {
  yellow: '#facc15',
  white: '#ffffff',
} as const;

export const TIMINGS = {
  DOWNLOAD_DELAY: 600,
  COMPLETED_RESET: 2000,
  ERROR_RESET: 3000,
} as const;
