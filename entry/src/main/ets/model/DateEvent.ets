/**
 * KIPPU_Trace - 数据模型
 * HarmonyOS 6 移植版
 */

export enum DisplayMode {
  COUNT_DOWN = 0,  // 倒数
  ACCUMULATE = 1   // 累计
}

export interface DateEvent {
  id: number;
  title: string;
  targetDate: number;      // 毫秒时间戳
  isFuture: boolean;
  isLunar: boolean;
  mode: DisplayMode;
  backgroundUri: string;   // 背景图路径（本地 file:// URI）
  isPinned: boolean;
  maskOpacity: number;     // 遮罩透明度 0.0 ~ 1.0
  position: number;        // 排序位置
}

/**
 * 从数据库行转换为 DateEvent
 */
export function rowToEvent(row: Record<string, Object | null>): DateEvent {
  return {
    id: row['id'] as number,
    title: (row['title'] as string) || '',
    targetDate: (row['targetDate'] as number) || 0,
    isFuture: (row['isFuture'] as number) === 1,
    isLunar: (row['isLunar'] as number) === 1,
    mode: ((row['mode'] as number) || 0) as DisplayMode,
    backgroundUri: (row['backgroundUri'] as string) || '',
    isPinned: (row['isPinned'] as number) === 1,
    maskOpacity: (row['maskOpacity'] as number) || 0.3,
    position: (row['position'] as number) || 0,
  };
}

/**
 * DateEvent 转为数据库存储用的 ValuesBucket
 */
export function eventToBucket(event: DateEvent): Record<string, Object> {
  return {
    'id': event.id,
    'title': event.title,
    'targetDate': event.targetDate,
    'isFuture': event.isFuture ? 1 : 0,
    'isLunar': event.isLunar ? 1 : 0,
    'mode': event.mode,
    'backgroundUri': event.backgroundUri,
    'isPinned': event.isPinned ? 1 : 0,
    'maskOpacity': event.maskOpacity,
    'position': event.position,
  } as Record<string, Object>;
}
