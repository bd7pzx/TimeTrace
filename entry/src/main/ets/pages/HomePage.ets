/**
 * KIPPU_Trace - 首页
 * 事件卡片列表 + 滑动删除 + 添加按钮
 */

import { DateEvent } from '../model/DateEvent';
import { EventCard } from '../components/EventCards';
import { getAllEvents, deleteEvent } from '../database/EventRepository';
import { promptAction, router } from '@kit.ArkUI';

@Entry
@Component
export struct HomePage {
  @State events: DateEvent[] = [];
  @State isLoading: boolean = true;
  @State deleteTarget: DateEvent | null = null;
  @StorageLink('isDark') isDark: boolean = false;
  @Prop @Watch('onRefreshNeeded') refreshKey: number = 0;

  aboutToAppear(): void {
    this.loadEvents();
  }

  onRefreshNeeded(): void {
    // 父组件 Index 的 onPageShow 触发 refreshKey 变化 → 重新加载
    if (!this.isLoading) {
      this.loadEvents();
    }
  }

  async loadEvents(): Promise<void> {
    try {
      const result = await getAllEvents();
      this.events = result;
    } catch (e) {
      promptAction.showToast({ message: '加载事件失败', duration: 2000 });
    }
    this.isLoading = false;
  }

  handleDelete(): void {
    if (this.deleteTarget !== null) {
      const targetId = this.deleteTarget.id;
      deleteEvent(targetId).then(() => {
        this.events = this.events.filter(e => e.id !== targetId);
        this.deleteTarget = null;
        promptAction.showToast({ message: '已删除', duration: 1500 });
      }).catch(() => {
        promptAction.showToast({ message: '删除失败', duration: 1500 });
      });
    }
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.isDark ? '#0f0f1a' : '#f5f5f7');

      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#667eea');
      } else if (this.events.length === 0) {
        Column({ space: 16 }) {
          Text('📅')
            .fontSize(64)
            .opacity(0.4);
          Text('还没有事件')
            .fontSize(18)
            .fontColor('#9ca3af')
            .fontWeight(FontWeight.Medium);
          Text('点击下方按钮创建你的第一个倒数日')
            .fontSize(14)
            .fontColor('#c4c4c4');
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center);
      } else {
        List({ space: 12 }) {
          ForEach(this.events, (event: DateEvent, index: number) => {
            ListItem() {
              EventCard({
                event: event,
                onCardClick: () => {
                  router.pushUrl({
                    url: 'pages/DetailPage',
                    params: { eventId: event.id },
                  });
                },
              });
            }
            .swipeAction({
              end: {
                builder: () => {
                  this.deleteBuilder(event);
                },
              },
            });
          }, (event: DateEvent) => event.id.toString());
        }
        .width('100%')
        .height('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 100 })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring);
      }

    }
    .width('100%')
    .height('100%');
  }

  @Builder
  deleteBuilder(event: DateEvent) {
    Column() {
      Text('🗑')
        .fontSize(20)
        .fontColor(Color.White);
      Text('删除')
        .fontSize(11)
        .fontColor('rgba(255,255,255,0.85)')
        .margin({ top: 2 });
    }
    .width(130)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#ef4444')
    .borderRadius(20)
    .margin({ left: 10 })
    .onClick(() => {
      this.deleteTarget = event;
      this.handleDelete();
    });
  }
}
