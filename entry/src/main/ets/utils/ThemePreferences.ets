/**
 * KIPPU_Trace - 主题偏好
 */

import { preferences } from '@kit.ArkData';

export enum ThemeMode {
  SYSTEM = 0,
  LIGHT = 1,
  DARK = 2,
}

const STORE_NAME = 'kippu_preferences';
const KEY_THEME = 'theme_mode';

let prefsInstance: preferences.Preferences | null = null;

async function getPrefs(context: Context): Promise<preferences.Preferences> {
  if (prefsInstance === null) {
    prefsInstance = await preferences.getPreferences(context, STORE_NAME);
  }
  return prefsInstance;
}

export async function getThemeMode(context: Context): Promise<ThemeMode> {
  const prefs = await getPrefs(context);
  const value = prefs.getSync(KEY_THEME, ThemeMode.SYSTEM) as number;
  return value as ThemeMode;
}

export async function setThemeMode(context: Context, mode: ThemeMode): Promise<void> {
  const prefs = await getPrefs(context);
  await prefs.put(KEY_THEME, mode);
  await prefs.flush();
}
