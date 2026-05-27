/**
 * KIPPU_Trace - 数据库初始化
 * 使用 @ohos.data.relationalStore (RDB)
 */

import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;
const TAG: string = 'KIPPU_DB';

const DB_NAME: string = 'trace_database.db';

const SQL_CREATE_TABLE: string = `
  CREATE TABLE IF NOT EXISTS date_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    targetDate INTEGER NOT NULL,
    isFuture INTEGER NOT NULL DEFAULT 0,
    isLunar INTEGER NOT NULL DEFAULT 0,
    mode INTEGER NOT NULL DEFAULT 0,
    backgroundUri TEXT DEFAULT '',
    isPinned INTEGER NOT NULL DEFAULT 0,
    maskOpacity REAL NOT NULL DEFAULT 0.3,
    position INTEGER NOT NULL DEFAULT 0
  )
`;

let rdbStore: relationalStore.RdbStore | null = null;

/**
 * 初始化数据库（需要在 ability 的 onCreate 中调用，传入 context）
 */
export async function initDatabase(context: Context): Promise<relationalStore.RdbStore> {
  if (rdbStore !== null) {
    return rdbStore;
  }

  const STORE_CONFIG: relationalStore.StoreConfig = {
    name: DB_NAME,
    securityLevel: relationalStore.SecurityLevel.S2,
  };

  try {
    const store = await relationalStore.getRdbStore(context, STORE_CONFIG);
    await store.executeSql(SQL_CREATE_TABLE);
    rdbStore = store;
    hilog.info(DOMAIN, TAG, 'RDB initialized successfully');
    return store;
  } catch (err) {
    const error = err as BusinessError;
    hilog.error(DOMAIN, TAG, `RDB init failed: ${error.code}, ${error.message}`);
    throw new Error(`Database init failed: ${error.message}`);
  }
}

/**
 * 获取已初始化的数据库实例
 */
export function getDatabase(): relationalStore.RdbStore | null {
  return rdbStore;
}
