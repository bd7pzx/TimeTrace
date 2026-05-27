/**
 * KIPPU_Trace - 时间工具函数
 */

/**
 * 计算两个日期的相差天数（忽略时分秒）
 */
export function daysBetween(date1: number, date2: number): number {
  const d1 = new Date(date1);
  const d2 = new Date(date2);

  // 规整到当天 0 点
  const d1Midnight = Date.UTC(d1.getFullYear(), d1.getMonth(), d1.getDate());
  const d2Midnight = Date.UTC(d2.getFullYear(), d2.getMonth(), d2.getDate());

  return Math.floor((d2Midnight - d1Midnight) / (1000 * 60 * 60 * 24));
}

/**
 * 判断日期是否为未来
 */
export function isDateInFuture(targetMs: number): boolean {
  const now = Date.now();
  const today = new Date(now);
  const target = new Date(targetMs);
  const todayMidnight = Date.UTC(today.getFullYear(), today.getMonth(), today.getDate());
  const targetMidnight = Date.UTC(target.getFullYear(), target.getMonth(), target.getDate());
  return targetMidnight > todayMidnight;
}

/**
 * 格式化日期为 YYYY-MM-DD
 */
export function formatDate(timestampMs: number): string {
  const d = new Date(timestampMs);
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

/**
 * 格式化日期为中文（如 2026年5月28日）
 */
export function formatDateCN(timestampMs: number): string {
  const d = new Date(timestampMs);
  return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`;
}
