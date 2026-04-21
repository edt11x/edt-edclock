import { useState, useEffect } from 'react';

const getDiskUsage = (): string => {
  try {
    const { execSync } = (window as any).require('child_process');
    const output = execSync('df -h ~', { shell: true }).toString().trim();
    const lines = output.split('\n');
    if (lines.length < 2) return '';
    const parts = lines[1].trim().split(/\s+/);
    // df -h columns: Filesystem  Size  Used  Avail  Use%  Mounted
    const avail = parts[3];
    const size = parts[1];
    const usePct = parts[4];
    return `~ ${avail} free of ${size} (${usePct} used)`;
  } catch {
    return '';
  }
};

const DiskUsage = () => {
  const [usage, setUsage] = useState('');

  useEffect(() => {
    setUsage(getDiskUsage());
    const interval = setInterval(() => setUsage(getDiskUsage()), 30000);
    return () => clearInterval(interval);
  }, []);

  if (!usage) return null;

  return <div className="disk-usage">{usage}</div>;
};

export default DiskUsage;
