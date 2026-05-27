/**
 * KIPPU_Trace - 事件仓库
 * 封装所有 CRUD 操作
 */

import { relationalStore } from '@kit.ArkData';
import { getDatabase } from './DatabaseHelper';
import { DateEvent, DisplayMode } from '../model/DateEvent';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0002;
const TAG: string = 'KIPPU_REPO';

function requireStore(): relationalStore.RdbStore {
  const store = getDatabase();
  if (store === null) {
    throw new Error('Database not initialized');
  }
  return store;
}

function readRow(resultSet: relationalStore.ResultSet): DateEvent {
  return {
    id: resultSet.getLong(resultSet.getColumnIndex('id')),
    title: resultSet.getString(resultSet.getColumnIndex('title')),
    targetDate: resultSet.getLong(resultSet.getColumnIndex('targetDate')),
    isFuture: resultSet.getLong(resultSet.getColumnIndex('isFuture')) === 1,
    isLunar: resultSet.getLong(resultSet.getColumnIndex('isLunar')) === 1,
    mode: resultSet.getLong(resultSet.getColumnIndex('mode')) as DisplayMode,
    backgroundUri: resultSet.getString(resultSet.getColumnIndex('backgroundUri')),
    isPinned: resultSet.getLong(resultSet.getColumnIndex('isPinned')) === 1,
    maskOpacity: resultSet.getDouble(resultSet.getColumnIndex('maskOpacity')),
    position: resultSet.getLong(resultSet.getColumnIndex('position')),
  } as DateEvent;
}

function eventToBucket(event: DateEvent): relationalStore.ValuesBucket {
  return {
    'title': event.title,
    'targetDate': event.targetDate,
    'isFuture': event.isFuture ? 1 : 0,
    'isLunar': event.isLunar ? 1 : 0,
    'mode': event.mode,
    'backgroundUri': event.backgroundUri || '',
    'isPinned': event.isPinned ? 1 : 0,
    'maskOpacity': event.maskOpacity,
    'position': event.position,
  };
}

export async function getAllEvents(): Promise<DateEvent[]> {
  const store = requireStore();
  const predicates = new relationalStore.RdbPredicates('date_events');
  predicates.orderByDesc('isPinned');
  predicates.orderByAsc('position');
  predicates.orderByDesc('id');

  return new Promise<DateEvent[]>((resolve, reject) => {
    store.query(predicates, (err, resultSet) => {
      if (err) {
        hilog.error(DOMAIN, TAG, `Query failed: ${JSON.stringify(err)}`);
        reject(err);
        return;
      }
      const events: DateEvent[] = [];
      const count: number = resultSet.rowCount;
      for (let i = 0; i < count; i++) {
        resultSet.goToRow(i);
        try {
          events.push(readRow(resultSet));
        } catch (e) {
          hilog.warn(DOMAIN, TAG, `Row parse failed at index ${i}`);
        }
      }
      resultSet.close();
      resolve(events);
    });
  });
}

export async function insertEvent(event: DateEvent): Promise<number> {
  const store = requireStore();
  const bucket = eventToBucket(event);

  return new Promise<number>((resolve, reject) => {
    store.insert('date_events', bucket, (err, rowId) => {
      if (err) {
        hilog.error(DOMAIN, TAG, `Insert failed: ${JSON.stringify(err)}`);
        reject(err);
        return;
      }
      resolve(rowId);
    });
  });
}

export async function updateEvent(event: DateEvent): Promise<void> {
  const store = requireStore();
  const bucket = eventToBucket(event);
  const predicates = new relationalStore.RdbPredicates('date_events');
  predicates.equalTo('id', event.id);

  return new Promise<void>((resolve, reject) => {
    store.update(bucket, predicates, (err) => {
      if (err) {
        hilog.error(DOMAIN, TAG, `Update failed: ${JSON.stringify(err)}`);
        reject(err);
        return;
      }
      resolve();
    });
  });
}

export async function deleteEvent(eventId: number): Promise<void> {
  const store = requireStore();
  const predicates = new relationalStore.RdbPredicates('date_events');
  predicates.equalTo('id', eventId);

  return new Promise<void>((resolve, reject) => {
    store.delete(predicates, (err) => {
      if (err) {
        hilog.error(DOMAIN, TAG, `Delete failed: ${JSON.stringify(err)}`);
        reject(err);
        return;
      }
      resolve();
    });
  });
}

export async function getEventById(eventId: number): Promise<DateEvent | null> {
  const store = requireStore();
  const predicates = new relationalStore.RdbPredicates('date_events');
  predicates.equalTo('id', eventId);

  return new Promise<DateEvent | null>((resolve, reject) => {
    store.query(predicates, (err, resultSet) => {
      if (err) {
        reject(err);
        return;
      }
      if (resultSet.rowCount === 0) {
        resultSet.close();
        resolve(null);
        return;
      }
      resultSet.goToFirstRow();
      const event = readRow(resultSet);
      resultSet.close();
      resolve(event);
    });
  });
}

export async function replaceAllEvents(events: DateEvent[]): Promise<void> {
  const store = requireStore();

  return new Promise<void>((resolve, reject) => {
    store.executeSql('DELETE FROM date_events', (err) => {
      if (err) {
        reject(err);
        return;
      }
      if (events.length === 0) {
        resolve();
        return;
      }
      let inserted = 0;
      for (const event of events) {
        store.insert('date_events', eventToBucket(event), (err) => {
          if (err) {
            hilog.error(DOMAIN, TAG, `Replace insert failed: ${JSON.stringify(err)}`);
          }
          inserted++;
          if (inserted >= events.length) {
            resolve();
          }
        });
      }
    });
  });
}
