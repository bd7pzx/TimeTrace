/**
 * KIPPU_Trace - 主框架
 * 全屏布局 + 安全区避让 + 悬浮药丸栏 + 深色模式跟随
 */

import { HomePage } from './HomePage';
import { SettingsPage } from './SettingsPage';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State currentTab: number = 0;
  @State refreshKey: number = 0;
  @StorageLink('isDark') isDark: boolean = false;
  @StorageProp('statusBarH') statusBarH: number = 0;
  @StorageProp('navBarH') navBarH: number = 0;
  private tabsController: TabsController = new TabsController();

  aboutToAppear(): void {}

  onPageShow(): void {
    this.refreshKey = Date.now();
  }

  build() {
    Stack() {
      Column() {
        // 状态栏安全区占位
        Row()
          .width('100%')
          .height(this.statusBarH > 0 ? this.statusBarH : 40)
          .backgroundColor(this.isDark ? '#0f0f1a' : '#f5f5f7');

        // 主内容
        Tabs({
          barPosition: BarPosition.End,
          controller: this.tabsController,
        }) {
          TabContent() {
            HomePage({ refreshKey: this.refreshKey });
          }
          TabContent() {
            SettingsPage();
          }
        }
        .barHeight(0)
        .onChange((index: number) => {
          this.currentTab = index;
        })
        .animationDuration(220)
        .layoutWeight(1);

        // 导航栏安全区占位
        Row()
          .width('100%')
          .height(this.navBarH > 0 ? this.navBarH : 24)
          .backgroundColor(this.isDark ? '#0f0f1a' : '#f5f5f7');
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.isDark ? '#0f0f1a' : '#f5f5f7');

      // 底部悬浮药丸（含新建按钮）
      Column() {
        Row({ space: 0 }) {
          // 首页 tab
          Column({ space: 2 }) {
            Text('🏠')
              .fontSize(this.currentTab === 0 ? 20 : 18)
              .fontColor(this.currentTab === 0 ? Color.White : (this.isDark ? '#7b7b95' : '#9ca3af'));
            Text('首页')
              .fontSize(9)
              .fontColor(this.currentTab === 0 ? Color.White : (this.isDark ? '#5b5b75' : '#9ca3af'))
              .fontWeight(this.currentTab === 0 ? FontWeight.Bold : FontWeight.Normal);
          }
          .layoutWeight(1).height(52).borderRadius(26)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.currentTab === 0 ? '#667eea' : Color.Transparent)
          .onClick(() => { this.currentTab = 0; this.tabsController.changeIndex(0); })
          .animation({ duration: 220, curve: Curve.EaseInOut });

          // + 新建按钮（居中独立）
          Button() {
            Text('+')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White);
          }
          .width(44).height(44)
          .borderRadius(22)
          .backgroundColor('#667eea')
          .shadow({ radius: 8, color: 'rgba(102,126,234,0.45)', offsetX: 0, offsetY: 4 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/EditorPage' });
          })
          .margin({ left: 4, right: 4 });

          // 设置 tab
          Column({ space: 2 }) {
            Text('⚙️')
              .fontSize(this.currentTab === 1 ? 20 : 18)
              .fontColor(this.currentTab === 1 ? Color.White : (this.isDark ? '#7b7b95' : '#9ca3af'));
            Text('设置')
              .fontSize(9)
              .fontColor(this.currentTab === 1 ? Color.White : (this.isDark ? '#5b5b75' : '#9ca3af'))
              .fontWeight(this.currentTab === 1 ? FontWeight.Bold : FontWeight.Normal);
          }
          .layoutWeight(1).height(52).borderRadius(26)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.currentTab === 1 ? '#667eea' : Color.Transparent)
          .onClick(() => { this.currentTab = 1; this.tabsController.changeIndex(1); })
          .animation({ duration: 220, curve: Curve.EaseInOut });
        }
        .width(230).height(58).borderRadius(29).padding({ left: 3, right: 3 })
        .backgroundColor(this.isDark ? 'rgba(22,22,40,0.92)' : 'rgba(255,255,255,0.92)')
        .backdropBlur(16)
        .shadow({ radius: 20, color: this.isDark ? 'rgba(0,0,0,0.35)' : 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 });
      }
      .width('100%')
      .position({ x: 0, y: '100%' })
      .translate({ y: -(this.navBarH + 72) })
      .alignItems(HorizontalAlign.Center);
    }
    .width('100%').height('100%')
    .backgroundColor(this.isDark ? '#0f0f1a' : '#f5f5f7');
  }
}
