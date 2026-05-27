/**
 * KIPPU_Trace - 设置页
 */

import { ThemeMode, getThemeMode, setThemeMode } from '../utils/ThemePreferences';
import { common, ConfigurationConstant, Want } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
export struct SettingsPage {
  @State currentTheme: ThemeMode = ThemeMode.SYSTEM;
  @State versionName: string = '1.0.0';
  @StorageLink('isDark') isDark: boolean = false;
  private aboutDialogController?: CustomDialogController;

  aboutToAppear(): void {
    this.loadSettings();
    this.aboutDialogController = new CustomDialogController({
      builder: AboutDialog(),
      alignment: DialogAlignment.Center,
      customStyle: true,
      cornerRadius: 20,
      maskColor: 'rgba(0,0,0,0.45)',
      autoCancel: true,
    });
  }

  async loadSettings(): Promise<void> {
    const context = getContext(this);
    this.currentTheme = await getThemeMode(context);
  }

  async changeTheme(mode: ThemeMode): Promise<void> {
    const context = getContext(this);
    this.currentTheme = mode;
    await setThemeMode(context, mode);

    // 应用主题
    const appContext = context.getApplicationContext() as common.ApplicationContext;
    switch (mode) {
      case ThemeMode.LIGHT:
        appContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
        break;
      case ThemeMode.DARK:
        appContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
        break;
      default:
        appContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    }

    // 更新全局深色状态
    this.isDark = (mode === ThemeMode.DARK);
    AppStorage.setOrCreate('isDark', this.isDark);

    promptAction.showToast({
      message: mode === ThemeMode.LIGHT ? '已切换浅色' : mode === ThemeMode.DARK ? '已切换深色' : '已切换跟随系统',
      duration: 1500,
    });
  }

  build() {
    Column() {
      // 顶部栏
      Text('设置')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isDark ? '#e5e5ec' : '#1a1a2e')
        .width('100%')
        .padding({ left: 20, top: 16, bottom: 16 });

      Divider().color('#e5e7eb').strokeWidth(0.5);

      List({ space: 0 }) {
        // 主题设置
        ListItem() {
          Column() {
            Row() {
              Text('🎨')
                .fontSize(22)
                .margin({ right: 12 });
              Column({ space: 4 }) {
                Text('主题模式')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark ? '#e5e5ec' : '#1a1a2e');
                Text(
                  this.currentTheme === ThemeMode.SYSTEM ? '跟随系统' :
                    this.currentTheme === ThemeMode.LIGHT ? '浅色模式' : '深色模式'
                )
                  .fontSize(13)
                  .fontColor(this.isDark ? '#8e8ea0' : '#9ca3af');
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1);

              Image($r('sys.media.ohos_ic_public_arrow_right'))
                .width(20)
                .height(20)
                .fillColor('#9ca3af');
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 16, bottom: 16 });

            // 主题选项
            Row({ space: 8 }) {
              this.themeButton(ThemeMode.SYSTEM, '跟随系统');
              this.themeButton(ThemeMode.LIGHT, '浅色');
              this.themeButton(ThemeMode.DARK, '深色');
            }
            .width('100%')
            .padding({ left: 20, right: 20, bottom: 16 });
          }
        };

        // 分隔
        ListItem() {
          Divider().color(this.isDark ? '#12122a' : '#f3f4f6').strokeWidth(8);
        };

        // 备份（占位，后续实现）
        ListItem() {
          Row() {
            Text('💾')
              .fontSize(22)
              .margin({ right: 12 });
            Text('备份与恢复')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isDark ? '#e5e5ec' : '#1a1a2e')
              .layoutWeight(1);
            Image($r('sys.media.ohos_ic_public_arrow_right'))
              .width(20)
              .height(20)
              .fillColor('#9ca3af');
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 16 })
          .onClick(() => {
            promptAction.showToast({ message: '功能开发中', duration: 1500 });
          });
        };

        // 关于
        ListItem() {
          Row() {
            Text('ℹ️')
              .fontSize(22)
              .margin({ right: 12 });
            Text('关于')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isDark ? '#e5e5ec' : '#1a1a2e')
              .layoutWeight(1);
            Text('v' + this.versionName)
              .fontSize(14)
              .fontColor('#9ca3af');
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 16 })
          .onClick(() => {
            this.aboutDialogController?.open();
          });
        };
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDark ? '#0f0f1a' : '#f5f5f7');
  }

  @Builder
  themeButton(mode: ThemeMode, label: string) {
    Button(label)
      .fontSize(13)
      .fontWeight(this.currentTheme === mode ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(this.currentTheme === mode ? Color.White : (this.isDark ? '#8e8ea0' : '#6b7280'))
      .backgroundColor(this.currentTheme === mode ? '#667eea' : (this.isDark ? '#1e1e30' : '#f3f4f6'))
      .borderRadius(10)
      .height(36)
      .padding({ left: 16, right: 16 })
      .onClick(() => { this.changeTheme(mode); });
  }
}

// ─── 关于弹窗 ──────────────────────────────
@CustomDialog
struct AboutDialog {
  @StorageLink('isDark') isDark: boolean = false;
  controller?: CustomDialogController;

  build() {
    Column() {
      // 图标
      Image($r('app.media.startIcon'))
        .width(64).height(64).borderRadius(14)
        .margin({ top: 24, bottom: 12 });

      // 标题
      Text('TimeTrace')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isDark ? '#e5e5ec' : '#1a1a2e');

      Text('v1.0.0')
        .fontSize(13)
        .fontColor('#9ca3af')
        .margin({ bottom: 20 });

      Divider().color(this.isDark ? '#2a2a40' : '#e5e7eb').height(1).width('80%').margin({ bottom: 16 });

      // 项目地址
      this.infoRow('🔗', '项目地址', 'github.com/bd7pzx/TimeTrace', () => {
        this.openUrl('https://github.com/bd7pzx/TimeTrace');
      });
      Divider().color(this.isDark ? '#2a2a40' : '#f0f0f5').height(1).margin({ left: 52, right: 20 });

      // 许可证
      this.infoRow('📜', '许可证', 'GPL V3', undefined);
      Divider().color(this.isDark ? '#2a2a40' : '#f0f0f5').height(1).margin({ left: 52, right: 20 });

      // 邮箱
      this.infoRow('📧', '联系邮箱', 'me@dgtea.site', () => {
        this.openUrl('mailto:me@dgtea.site');
      });

      // 关闭按钮
      Button('关闭')
        .fontSize(15)
        .fontColor(Color.White)
        .backgroundColor('#667eea')
        .borderRadius(12)
        .width('80%')
        .height(42)
        .margin({ top: 20, bottom: 20 })
        .onClick(() => {
          this.controller?.close();
        });
    }
    .width(300)
    .borderRadius(20)
    .backgroundColor(this.isDark ? '#1a1a2e' : '#ffffff')
    .padding({ left: 0, right: 0 });
  }

  @Builder
  infoRow(icon: string, label: string, value: string, onClick?: () => void) {
    Row() {
      Text(icon).fontSize(20).margin({ right: 12 });
      Column({ space: 2 }) {
        Text(label)
          .fontSize(14)
          .fontColor(this.isDark ? '#9e9eb0' : '#9ca3af');
        Text(value)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isDark ? '#e5e5ec' : '#1a1a2e');
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);

      if (onClick !== undefined) {
        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(16).height(16)
          .fillColor('#9ca3af');
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 14, bottom: 14 })
    .onClick(() => {
      if (onClick) onClick();
    });
  }

  openUrl(url: string): void {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      context.startAbility({
        action: 'ohos.want.action.viewData',
        entities: url.startsWith('mailto') ? [] : ['entity.system.browsable'],
        uri: url,
      } as Want);
    } catch (e) {
      const err = e as BusinessError;
      promptAction.showToast({ message: '无法打开: ' + err.message, duration: 2000 });
    }
  }
}
