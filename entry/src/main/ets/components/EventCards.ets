/**
 * KIPPU_Trace - 事件卡片组件
 * 统一卡片：背景图 / 渐变 + 内容层
 */

import { DateEvent } from '../model/DateEvent';
import { daysBetween, formatDate, isDateInFuture } from '../utils/TimeUtils';

/**
 * 计算倒计时/累计天数文本
 */
function calcDayText(event: DateEvent): string {
  const now = Date.now();
  const days = daysBetween(now, event.targetDate);
  return Math.abs(days).toString();
}

/**
 * 获取单位标签（动态判断未来/过去，倒数日到期自动切累计）
 */
function calcUnitLabel(event: DateEvent): string {
  if (isDateInFuture(event.targetDate)) {
    return '天后';
  }
  return '天前';
}

/**
 * 判断是否为倒数日（动态）
 */
function isCountdown(event: DateEvent): boolean {
  return isDateInFuture(event.targetDate);
}

/**
 * 统一事件卡片
 */
@Component
export struct EventCard {
  @Prop event: DateEvent;
  @StorageLink('isDark') isDark: boolean = false;
  onCardClick: () => void = () => {};

  build() {
    Stack() {
      // 背景图层
      if (this.event.backgroundUri && this.event.backgroundUri.length > 0) {
        Image(this.event.backgroundUri)
          .objectFit(ImageFit.Cover)
          .width('100%')
          .height('100%')
          .borderRadius(20)
          .clip(true);
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .borderRadius(20)
          .backgroundColor(`rgba(0,0,0,${this.event.maskOpacity})`);
      } else {
        // 无背景图时使用渐变
        Column()
          .width('100%')
          .height('100%')
          .borderRadius(20)
          .linearGradient({
            angle: 135,
            colors: [
              ['#667eea', 0],
              ['#764ba2', 0.5],
              ['#5b47d6', 1],
            ],
          });
      }

      // 内容层
      Column() {
        // 置顶标签（仅置顶显示）
        if (this.event.isPinned) {
          Row() {
            Text('📌 置顶')
              .fontSize(12)
              .fontColor(Color.White)
              .textShadow({ radius: 3, color: 'rgba(0,0,0,0.3)', offsetX: 0, offsetY: 1 })
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor('rgba(255,255,255,0.2)')
              .borderRadius(12);
          }
          .width('100%')
          .margin({ bottom: 12 });
        }

        Text(this.event.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .textShadow({ radius: 4, color: 'rgba(0,0,0,0.35)', offsetX: 0, offsetY: 1 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 });

        Row() {
          Text(calcDayText(this.event))
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .textShadow({ radius: 6, color: 'rgba(0,0,0,0.3)', offsetX: 0, offsetY: 2 })
            .fontFamily('HarmonyHeiTi-Bold');

          Text(calcUnitLabel(this.event))
            .fontSize(16)
            .fontColor('rgba(255,255,255,0.8)')
            .textShadow({ radius: 3, color: 'rgba(0,0,0,0.25)', offsetX: 0, offsetY: 1 })
            .margin({ left: 6, top: 24 });
        }
        .alignItems(VerticalAlign.Bottom);

        Blank();

        Row({ space: 8 }) {
          Text(formatDate(this.event.targetDate))
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.7)')
            .textShadow({ radius: 2, color: 'rgba(0,0,0,0.25)', offsetX: 0, offsetY: 1 });

          Text(isCountdown(this.event) ? '倒数' : '累计')
            .fontSize(10)
            .fontColor(Color.White)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor('rgba(255,255,255,0.25)')
            .borderRadius(8);
        }
      }
      .width('100%')
      .height('100%')
      .padding(20)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start);
    }
    .width('100%')
    .height(200)
    .borderRadius(20)
    .clip(true)
    .shadow({
      radius: 12,
      color: this.isDark ? 'rgba(0,0,0,0.4)' : 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 4,
    })
    .onClick(() => this.onCardClick());
  }
}
