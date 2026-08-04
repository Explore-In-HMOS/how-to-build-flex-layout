import { LengthMetrics } from '@kit.ArkUI';
import { HealthStore, Metric } from '../model/HealthData';
import { Theme } from '../model/Theme';
import { accentFor, metricValue, pageCrumbs } from './MetricCommon';

interface TileParams {
  metric: Metric;
}

@Component
export struct AdaptPage {
  private static readonly SLOT_COUNT: number = 4;
  private static readonly BASIS: number = 54;
  private static readonly FLOOR: number = 30;
  private static readonly ROW_H: number = 44;
  private static readonly TILE_H: number = 32;
  private static readonly PIN_PRIORITY: number = 9;
  @State private items: Metric[] = HealthStore.tiles().slice(0, AdaptPage.SLOT_COUNT);
  @State private widthPct: number = 100;
  @State private pinnedKey: string = '';
  @State private justifyIdx: number = 0;

  private shrinkFor(key: string): number {
    switch (key) {
      case 'hr':
        return 0;
      case 'steps':
        return 1;
      case 'kcal':
        return 2;
      case 'spo2':
        return 3;
      default:
        return 1;
    }
  }

  private priorityFor(key: string): number {
    switch (key) {
      case 'hr':
        return 4;
      case 'steps':
        return 3;
      case 'kcal':
        return 2;
      case 'spo2':
        return 1;
      default:
        return 1;
    }
  }

  private justifyMode(): FlexAlign {
    switch (this.justifyIdx) {
      case 1:
        return FlexAlign.SpaceBetween;
      case 2:
        return FlexAlign.SpaceEvenly;
      default:
        return FlexAlign.Center;
    }
  }

  private justifyLabel(): string {
    switch (this.justifyIdx) {
      case 1:
        return 'BETWEEN';
      case 2:
        return 'EVENLY';
      default:
        return 'CENTER';
    }
  }

  private cycleJustify() {
    this.getUIContext().animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
      this.justifyIdx = (this.justifyIdx + 1) % 3;
    });
  }

  private togglePin(key: string) {
    this.getUIContext().animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
      this.pinnedKey = this.pinnedKey === key ? '' : key;
    });
  }

  @Builder
  adaptTile($$: TileParams) {
    Column() {
      metricValue({ metric: $$.metric })
    }
    .height(this.pinnedKey === $$.metric.key ? undefined : AdaptPage.TILE_H)
    .alignSelf(this.pinnedKey === $$.metric.key ? ItemAlign.Stretch : ItemAlign.Center)
    .flexBasis(AdaptPage.BASIS)
    .flexShrink(this.pinnedKey === $$.metric.key ? 0 : this.shrinkFor($$.metric.key))
    .displayPriority(this.pinnedKey === $$.metric.key
      ? AdaptPage.PIN_PRIORITY
      : this.priorityFor($$.metric.key))
    .constraintSize({ minWidth: AdaptPage.FLOOR })
    .borderRadius(Theme.cardRadius)
    .backgroundColor(this.pinnedKey === $$.metric.key ? Theme.cardHi : Theme.card)
    .border({
      width: this.pinnedKey === $$.metric.key ? 2 : 1,
      color: accentFor($$.metric.key)
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .hitTestBehavior(HitTestMode.Block)
    .animation({ duration: 200, curve: Curve.EaseInOut })
    .onClick(() => {
      this.togglePin($$.metric.key);
    })
  }

  build() {
    Column() {
      pageCrumbs(3, 1)

      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Center,
        space: { main: LengthMetrics.vp(10) }
      }) {
        Text('ADAPT')
          .fontSize(8)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.textDim)
          .letterSpacing(0.6)
        Text(`${this.widthPct}%`)
          .fontSize(8)
          .fontColor(Theme.text)
        Text(this.justifyLabel())
          .fontSize(5)
          .fontColor(Theme.text)
          .letterSpacing(0.4)
          .textAlign(TextAlign.Center)
          .width(46)
          .padding({ top: 4, bottom: 4 })
          .borderRadius(8)
          .backgroundColor(Theme.card)
          .border({ width: 1, color: Theme.stroke })
          .hitTestBehavior(HitTestMode.Block)
          .onClick(() => {
            this.cycleJustify();
          })
      }
      .margin({ bottom: 6 })

      Column() {
        Flex({
          direction: FlexDirection.Row,
          justifyContent: this.justifyMode(),
          alignItems: ItemAlign.Center,
          space: { main: LengthMetrics.vp(4) }
        }) {
          ForEach(this.items, (m: Metric) => {
            this.adaptTile({ metric: m })
          }, (m: Metric) => m.key)
        }
        .width('100%')
        .height(AdaptPage.ROW_H)
        .clip(true)
      }
      .width(`${this.widthPct}%`)
      .padding(4)
      .borderRadius(Theme.cardRadius)
      .border({ width: 1, color: Theme.stroke })
      .animation({ duration: 200, curve: Curve.EaseInOut })

      Text(this.pinnedKey === '' ? 'TAP A TILE TO PIN' : 'TAP AGAIN TO UNPIN')
        .fontSize(5)
        .fontColor(Theme.textDim)
        .letterSpacing(0.4)
        .margin({ top: 6 })

      Slider({
        value: this.widthPct,
        min: 40,
        max: 100,
        step: 2,
        style: SliderStyle.OutSet
      })
        .width('72%')
        .blockSize({ width: 10, height: 10 })
        .blockColor(Theme.text)
        .trackThickness(3)
        .trackColor(Theme.card)
        .selectedColor(Theme.steps)
        .margin({ top: 8 })
        .onChange((value: number, mode: SliderChangeMode) => {
          this.widthPct = Math.round(value);
        })
    }
    .width('82%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 18, bottom: 12 })
  }
}