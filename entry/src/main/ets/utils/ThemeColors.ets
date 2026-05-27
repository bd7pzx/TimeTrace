/**
 * KIPPU_Trace - 主题色配置
 * 支持深色模式自适应
 */

export class AppColors {
  /** 页面背景 */
  static bgPrimary(): string {
    return AppStorage.get<boolean>('isDark') ? '#0f0f1a' : '#f5f5f7';
  }

  /** 卡片背景 */
  static bgCard(): string {
    return AppStorage.get<boolean>('isDark') ? '#1a1a2e' : '#ffffff';
  }

  /** 文字主色 */
  static textPrimary(): string {
    return AppStorage.get<boolean>('isDark') ? '#e5e5ec' : '#1a1a2e';
  }

  /** 文字灰色 */
  static textSecondary(): string {
    return AppStorage.get<boolean>('isDark') ? '#8e8ea0' : '#9ca3af';
  }

  /** 文字浅灰 */
  static textMuted(): string {
    return AppStorage.get<boolean>('isDark') ? '#5e5e70' : '#c4c4c4';
  }

  /** 强调色 */
  static accent(): string {
    return '#667eea';
  }

  /** 分隔线 */
  static divider(): string {
    return AppStorage.get<boolean>('isDark') ? 'rgba(255,255,255,0.08)' : '#e5e7eb';
  }

  /** 表单背景 */
  static inputBg(): string {
    return AppStorage.get<boolean>('isDark') ? '#1e1e30' : '#f9fafb';
  }

  /** 浅底色 */
  static surfaceLight(): string {
    return AppStorage.get<boolean>('isDark') ? '#1e1e30' : '#f3f4f6';
  }

  /** 详情页渐变 */
  static detailGradient(): string[] {
    if (AppStorage.get<boolean>('isDark')) {
      return ['#0a0a1a', '#12122e', '#1a1a3e'];
    }
    return ['#1a1a2e', '#16213e', '#0f3460'];
  }
}

/**
 * 组件内获取主题安全的背景色（适配 @Prop/@State 不更新的场景）
 */
export function bgPrimaryStr(): string {
  return AppStorage.get<boolean>('isDark') ? '#0f0f1a' : '#f5f5f7';
}

export function bgCardStr(): string {
  return AppStorage.get<boolean>('isDark') ? '#1a1a2e' : '#ffffff';
}

export function textPrimaryStr(): string {
  return AppStorage.get<boolean>('isDark') ? '#e5e5ec' : '#1a1a2e';
}
