import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { initDatabase } from '../database/DatabaseHelper';

const DOMAIN: number = 0x0001;

export default class EntryAbility extends UIAbility {
  private mainWindow: window.Window | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      // 跟随系统深色模式
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);

      const currentIsDark = this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      AppStorage.setOrCreate('isDark', currentIsDark);

      initDatabase(this.context).catch((err: Error) => {
        hilog.error(DOMAIN, 'KIPPU', `DB init failed: ${err.message}`);
      });
    } catch (err) {
      hilog.error(DOMAIN, 'KIPPU', `Init failed: ${JSON.stringify(err)}`);
    }
    hilog.info(DOMAIN, 'KIPPU', 'EntryAbility onCreate');
  }

  onConfigurationUpdate(newConfig: object): void {
    const cfg = newConfig as Record<string, Object>;
    const colorMode = cfg['colorMode'] as number;
    const newIsDark = colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    AppStorage.setOrCreate('isDark', newIsDark);
    this.applyBarStyle(newIsDark);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'KIPPU', 'EntryAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'KIPPU', 'EntryAbility onWindowStageCreate');

    windowStage.getMainWindow().then((win: window.Window) => {
      this.mainWindow = win;
      const isDark = this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;

      // 官方方案：全屏布局 + 读取安全区尺寸
      win.setWindowLayoutFullScreen(true).then(() => {
        // 获取状态栏 / 导航栏实际像素高度
        const avoidArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        const topVp = px2vp(avoidArea.topRect.height);
        const bottomVp = px2vp(avoidArea.bottomRect.height);
        AppStorage.setOrCreate('statusBarH', topVp);
        AppStorage.setOrCreate('navBarH', bottomVp);
        hilog.info(DOMAIN, 'KIPPU', `AvoidArea top=${topVp}vp bottom=${bottomVp}vp`);

        // 监听安全区变化（分屏/折叠/旋转）
        win.on('avoidAreaChange', (data: object) => {
          const payload = data as Record<string, Object>;
          const newArea = payload['area'] as Record<string, Object>;
          const topR = newArea['topRect'] as Record<string, number>;
          const bottomR = newArea['bottomRect'] as Record<string, number>;
          AppStorage.setOrCreate('statusBarH', px2vp(topR['height']));
          AppStorage.setOrCreate('navBarH', px2vp(bottomR['height']));
        });

        this.applyBarStyle(isDark);
      }).catch((err: Error) => {
        hilog.error(DOMAIN, 'KIPPU', `setWindowLayoutFullScreen failed: ${err.message}`);
      });
    }).catch((err: Error) => {
      hilog.error(DOMAIN, 'KIPPU', `getMainWindow failed: ${err.message}`);
    });

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'KIPPU', `Failed to load content: ${JSON.stringify(err)}`);
        return;
      }
      hilog.info(DOMAIN, 'KIPPU', 'Content loaded.');
    });
  }

  private applyBarStyle(isDark: boolean): void {
    if (this.mainWindow === null) {
      return;
    }
    this.mainWindow.setWindowSystemBarProperties({
      statusBarColor: '#00ffffff',
      navigationBarColor: isDark ? '#0f0f1a' : '#f5f5f7',
      statusBarContentColor: isDark ? '#ffffff' : '#000000',
      navigationBarContentColor: isDark ? '#ffffff' : '#000000',
    }).catch((err: Error) => {
      hilog.error(DOMAIN, 'KIPPU', `applyBarStyle failed: ${err.message}`);
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'KIPPU', 'EntryAbility onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'KIPPU', 'EntryAbility onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'KIPPU', 'EntryAbility onBackground');
  }
}
