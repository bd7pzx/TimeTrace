/**
 * KIPPU_Trace - 新建日程底部弹出 Sheet
 * @Link 双向绑定 + animateTo 滑入动画 + 沉浸适配
 */

import { DateEvent, DisplayMode } from '../model/DateEvent';
import { insertEvent } from '../database/EventRepository';
import { isDateInFuture } from '../utils/TimeUtils';
import { picker } from '@kit.CoreFileKit';
import { promptAction } from '@kit.ArkUI';

@Component
export struct EditorSheet {
  @Link @Watch('onShowChange') show: boolean;
  @StorageLink('isDark') isDark: boolean = false;
  @StorageProp('statusBarH') statusBarH: number = 0;
  @State backdropOpacity: number = 0;
  @State sheetTranslateY: number = 100;
  @State titleValue: string = '';
  @State selectedDate: number = Date.now();
  @State isPinned: boolean = false;
  @State maskOpacity: number = 0.4;
  @State backgroundUri: string = '';
  onSaved: () => void = () => {};

  aboutToAppear(): void {
    this.resetForm();
  }

  onShowChange(): void {
    if (this.show) {
      this.resetForm();
      animateTo({ duration: 280, curve: Curve.FastOutSlowIn }, () => {
        this.backdropOpacity = 1;
        this.sheetTranslateY = 0;
      });
    } else {
      animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
        this.backdropOpacity = 0;
        this.sheetTranslateY = 100;
      });
    }
  }

  resetForm(): void {
    this.titleValue = '';
    this.selectedDate = Date.now();
    this.isPinned = false;
    this.maskOpacity = 0.4;
    this.backgroundUri = '';
  }

  close(): void {
    this.show = false;
  }

  async pickImage(): Promise<void> {
    try {
      const documentPicker = new picker.PhotoViewPicker();
      const result = await documentPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1,
      });
      if (result.photoUris.length > 0) {
        this.backgroundUri = result.photoUris[0];
      }
    } catch (e) {
      promptAction.showToast({ message: '选择图片失败', duration: 1500 });
    }
  }

  async handleSave(): Promise<void> {
    if (this.titleValue.trim().length === 0) {
      promptAction.showToast({ message: '请输入事件标题', duration: 1500 });
      return;
    }

    const future = isDateInFuture(this.selectedDate);
    const event: DateEvent = {
      id: 0, title: this.titleValue.trim(),
      targetDate: this.selectedDate,
      isFuture: future,
      isLunar: false,
      mode: future ? DisplayMode.COUNT_DOWN : DisplayMode.ACCUMULATE,
      backgroundUri: this.backgroundUri,
      isPinned: this.isPinned, maskOpacity: this.maskOpacity,
      position: 0,
    };

    try {
      await insertEvent(event);
      promptAction.showToast({ message: '已创建', duration: 1500 });
      this.close();
      this.onSaved();
    } catch (e) {
      promptAction.showToast({ message: '保存失败', duration: 1500 });
    }
  }

  build() {
    Stack() {
      // 顶部安全区（点击关闭）
      Column()
        .width('100%')
        .height(this.statusBarH > 0 ? this.statusBarH : 44)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.close());

      // 蒙层区域（状态栏与Sheet之间）
      Column()
        .width('100%')
        .backgroundColor(this.isDark
          ? `rgba(0,0,0,${0.45 * this.backdropOpacity})`
          : `rgba(0,0,0,${0.3 * this.backdropOpacity})`)
        .onClick(() => this.close())
        .layoutWeight(1);

      // Sheet 主体
      Column() {
        // 标题栏
        Row() {
          Button('取消')
            .fontColor(this.isDark ? '#8e8ea0' : '#6b7280')
            .backgroundColor(Color.Transparent).fontSize(15)
            .onClick(() => this.close());

          Blank();

          Text('新建日程')
            .fontSize(17).fontWeight(FontWeight.Bold)
            .fontColor(this.isDark ? '#e5e5ec' : '#1a1a2e');

          Blank();

          Button('保存')
            .fontColor('#667eea').fontWeight(FontWeight.Bold).fontSize(15)
            .backgroundColor(Color.Transparent)
            .onClick(() => this.handleSave());
        }
        .width('100%').padding({ left: 20, right: 20, top: 14, bottom: 10 });

        Divider()
          .color(this.isDark ? 'rgba(255,255,255,0.08)' : '#e5e7eb')
          .strokeWidth(0.5);

        // 表单
        Scroll() {
          Column({ space: 20 }) {
            Column({ space: 8 }) {
              Text('事件名称').fontSize(13).fontColor('#9ca3af')
                .fontWeight(FontWeight.Medium).alignSelf(ItemAlign.Start);
              TextInput({ text: this.titleValue, placeholder: '输入事件名称...' })
                .fontSize(18).fontWeight(FontWeight.Medium)
                .backgroundColor(this.isDark ? '#1e1e30' : '#f9fafb')
                .fontColor(this.isDark ? '#e5e5ec' : '#1a1a2e')
                .borderRadius(14).padding(16)
                .onChange((value: string) => { this.titleValue = value; });
            }.alignItems(HorizontalAlign.Start);

            Column({ space: 8 }) {
              Text('目标日期').fontSize(13).fontColor('#9ca3af')
                .fontWeight(FontWeight.Medium).alignSelf(ItemAlign.Start);
              DatePicker({
                start: new Date('2000-1-1'), end: new Date('2100-1-1'),
                selected: new Date(this.selectedDate),
              })
                .onDateChange((value: Date) => { this.selectedDate = value.getTime(); })
                .borderRadius(14)
                .backgroundColor(this.isDark ? '#1e1e30' : '#f9fafb')
                .textStyle({ color: this.isDark ? '#e5e5ec' : '#1a1a2e', font: { size: '18fp', weight: FontWeight.Normal } })
                .selectedTextStyle({ color: '#667eea', font: { size: '26fp', weight: FontWeight.Regular } })
                .disappearTextStyle({ color: this.isDark ? '#4a4a60' : '#9ca3af', font: { size: '16fp', weight: FontWeight.Normal } });
            }.alignItems(HorizontalAlign.Start);

            Column({ space: 8 }) {
              Text('背景图片（可选）').fontSize(13).fontColor('#9ca3af')
                .fontWeight(FontWeight.Medium).alignSelf(ItemAlign.Start);
              Row() {
                if (this.backgroundUri.length > 0) {
                  Image(this.backgroundUri).width(80).height(80)
                    .borderRadius(12).objectFit(ImageFit.Cover);
                } else {
                  Column() {
                    Image($r('sys.media.ohos_ic_public_add')).width(28).height(28)
                      .fillColor(this.isDark ? '#6b6b80' : '#9ca3af');
                  }.width(80).height(80).borderRadius(12)
                    .backgroundColor(this.isDark ? '#1a1a30' : '#f3f4f6')
                    .justifyContent(FlexAlign.Center)
                    .border({ width: 1.5, color: this.isDark ? '#2a2a40' : '#e5e7eb', style: BorderStyle.Dashed });
                }
              }.onClick(() => this.pickImage());
            }.alignItems(HorizontalAlign.Start);

            Row() {
              Column({ space: 4 }) {
                Text('置顶显示').fontSize(15)
                  .fontColor(this.isDark ? '#e5e5ec' : '#1a1a2e');
                Text('置顶事件将展示在列表顶部').fontSize(12)
                  .fontColor(this.isDark ? '#8e8ea0' : '#9ca3af');
              }.alignItems(HorizontalAlign.Start).layoutWeight(1);
              Toggle({ type: ToggleType.Switch, isOn: this.isPinned })
                .onChange((value: boolean) => { this.isPinned = value; })
                .selectedColor('#667eea');
            }
            .width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .backgroundColor(this.isDark ? '#1e1e30' : '#f9fafb').borderRadius(14);

            // 遮罩效果即时预览
            if (this.backgroundUri.length > 0) {
              Column({ space: 8 }) {
                Text('效果预览').fontSize(13).fontColor('#9ca3af')
                  .fontWeight(FontWeight.Medium).alignSelf(ItemAlign.Start);

                Stack() {
                  Image(this.backgroundUri)
                    .width('100%').height(120)
                    .borderRadius(12).objectFit(ImageFit.Cover);
                  Column()
                    .width('100%').height(120).borderRadius(12)
                    .backgroundColor(`rgba(0,0,0,${this.maskOpacity})`)
                    .justifyContent(FlexAlign.Center);
                  Text('预览文字效果')
                    .fontSize(16).fontColor('rgba(255,255,255,0.9)')
                    .fontWeight(FontWeight.Bold);
                }
                .width('100%').height(120).borderRadius(12).clip(true);
              }
              .alignItems(HorizontalAlign.Start);
            }

            if (this.backgroundUri.length > 0) {
              Column({ space: 8 }) {
                Text('遮罩透明度').fontSize(13).fontColor('#9ca3af')
                  .alignSelf(ItemAlign.Start);
                Row({ space: 12 }) {
                  Text('透').fontSize(12).fontColor('#9ca3af');
                  Slider({ value: this.maskOpacity, min: 0, max: 0.8, step: 0.05 })
                    .layoutWeight(1).blockColor('#667eea')
                    .trackColor('#e5e7eb').selectedColor('#667eea')
                    .onChange((value: number) => { this.maskOpacity = value; });
                  Text('暗').fontSize(12).fontColor('#9ca3af');
                }.width('100%');
              }.alignItems(HorizontalAlign.Start);
            }
          }
          .padding({ left: 20, right: 20, top: 16, bottom: 30 });
        }
        .layoutWeight(1).scrollBar(BarState.Off);
      }
      .width('100%')
      .position({ x: 0, y: '18%' })
      .translate({ y: `${this.sheetTranslateY}%` })
      .borderRadius({ topLeft: 20, topRight: 20 })
      .backgroundColor(this.isDark ? '#141428' : '#ffffff')
      // 背景延伸到底部导航栏之后，消除割裂感
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .hitTestBehavior(this.backdropOpacity > 0.01 ? HitTestMode.Default : HitTestMode.None)
    .zIndex(this.backdropOpacity > 0.01 ? 100 : -1);
  }
}
