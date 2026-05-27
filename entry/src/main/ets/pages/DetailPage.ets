/**
 * KIPPU_Trace - 详情页
 * 全屏倒计时 / 累计展示 + 背景图
 */

import { DateEvent } from '../model/DateEvent';
import { getEventById } from '../database/EventRepository';
import { daysBetween, formatDateCN, isDateInFuture } from '../utils/TimeUtils';
import { router, window } from '@kit.ArkUI';

@Entry
@Component
export struct DetailPage {
  @State event: DateEvent | null = null;
  @State days: number = 0;
  @StorageLink('isDark') isDark: boolean = false;
  eventId: number = -1;

  aboutToAppear(): void {
    // 全屏沉浸：隐藏状态栏和导航栏
    window.getLastWindow(getContext(this)).then((win: window.Window) => {
      win.setSpecificSystemBarEnabled('status', false);
      win.setSpecificSystemBarEnabled('navigation', false);
    });

    const params: Record<string, Object> = router.getParams() as Record<string, Object>;
    if (params && params['eventId']) {
      this.eventId = params['eventId'] as number;
      this.loadEvent();
    }
  }

  aboutToDisappear(): void {
    // 退出时恢复系统栏
    window.getLastWindow(getContext(this)).then((win: window.Window) => {
      win.setSpecificSystemBarEnabled('status', true);
      win.setSpecificSystemBarEnabled('navigation', true);
    });
  }

  async loadEvent(): Promise<void> {
    try {
      const evt = await getEventById(this.eventId);
      if (evt !== null) {
        this.event = evt;
        this.days = Math.abs(daysBetween(Date.now(), evt.targetDate));
      }
    } catch (e) {
      // handle silently
    }
  }

  build() {
    Stack() {
      if (this.event === null) {
        // 加载中/无数据
        Column()
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#1a1a2e');
        Text('加载中...')
          .fontColor('rgba(255,255,255,0.5)')
          .fontSize(16);
      } else {
        // 背景图层
        if (this.event!.backgroundUri && this.event!.backgroundUri.length > 0) {
          Image(this.event!.backgroundUri)
            .objectFit(ImageFit.Cover)
            .width('100%')
            .height('100%');
          // 遮罩层（比卡片稍深，保证文字可读）
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(`rgba(0,0,0,${0.65 + this.event!.maskOpacity * 0.25})`);
        } else {
          // 无背景图：深色渐变
          Column()
            .width('100%')
            .height('100%')
            .linearGradient({
              angle: 180,
              colors: [
                ['#1a1a2e', 0],
                ['#16213e', 0.5],
                ['#0f0f1a', 1],
              ],
            });
        }

        // 内容层
        Column() {
          // 顶部导航
          Row() {
            Button() {
              Text('←')
                .fontSize(22)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold);
            }
            .backgroundColor('rgba(255,255,255,0.15)')
            .borderRadius(20)
            .width(40)
            .height(40)
            .onClick(() => router.back());

            Blank();

            Button() {
              Text('✏️')
                .fontSize(18);
            }
            .backgroundColor('rgba(255,255,255,0.15)')
            .borderRadius(20)
            .width(40)
            .height(40)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/EditorPage',
                params: { eventId: this.event!.id, eventData: this.event },
              });
            });
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 56 });

          Blank();

          // 中央倒计时
          Column({ space: 0 }) {
            Text(this.event!.title)
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .fontColor('rgba(255,255,255,0.85)')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .textAlign(TextAlign.Center)
              .margin({ bottom: 24 });

            Text(this.days.toString())
              .fontSize(96)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .fontFamily('HarmonyHeiTi-Bold')
              .shadow({ radius: 20, color: 'rgba(102,126,234,0.4)', offsetX: 0, offsetY: 4 });

            Text(isDateInFuture(this.event!.targetDate) ? '天后' : '天前')
              .fontSize(18)
              .fontColor('rgba(255,255,255,0.7)')
              .margin({ top: 8 });

            Divider()
              .width(80)
              .height(1)
              .color('rgba(255,255,255,0.25)')
              .margin({ top: 32, bottom: 16 });

            Text(formatDateCN(this.event!.targetDate))
              .fontSize(15)
              .fontColor('rgba(255,255,255,0.6)');

            Text(isDateInFuture(this.event!.targetDate) ? '距离目标日' : '自目标日以来')
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.4)')
              .margin({ top: 8 });
          }
          .alignItems(HorizontalAlign.Center);

          Blank();
        }
        .width('100%')
        .height('100%')
        .padding({ left: 20, right: 20, bottom: 60 });
      }
    }
    .width('100%')
    .height('100%');
  }
}
