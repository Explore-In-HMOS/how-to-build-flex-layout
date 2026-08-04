import { LengthMetrics } from '@kit.ArkUI';
import { HealthStore, Metric } from '../model/HealthData';
import { Theme } from '../model/Theme';
import { accentFor, metricValue, progressBar, pageCrumbs } from './MetricCommon';

// AXIS page - a dashboard with one big "hero" metric on top and smaller
// support metrics under it. Shows the main axis stuff:
//  - flexGrow: hero gets a big grow, support tiles share the rest.
//  - flexBasis(0): so the grow ratios come out exact.
//  - FlexDirection: the mirror button flips row direction (Row/RowReverse).
// Tap a support tile to make it the hero (it swaps with the top one).

// @Builder params must be passed as a single object literal ($$ form) so that
// state changes actually re-run the builder body. Passing by value does not
// register a dependency and leaves the tile content stale after a swap.
interface HeroParams {
  metric: Metric;
}

interface TileParams {
  metric: Metric;
  grow: number;
}

@Component
export struct AxisPage {
  // hero + 5 support tiles
  private static readonly SLOT_COUNT: number = 6;
  // the metrics in display order. items[0] is the hero, rest are support.
  @State private items: Metric[] = HealthStore.tiles().slice(0, AxisPage.SLOT_COUNT);
  @State private mirrored: boolean = false;

  private rowDirection(): FlexDirection {
    return this.mirrored ? FlexDirection.RowReverse : FlexDirection.Row;
  }

  // tap a support tile -> swap it with the hero at index 0.
  // build a new array instead of mutating in place: one state update, no
  // intermediate frame where the same metric appears twice.
  private makeHero(key: string) {
    const idx: number = this.items.findIndex((m: Metric) => m.key === key);
    if (idx <= 0) {
      return;
    }
    const next: Metric[] = this.items.slice();
    next[0] = this.items[idx];
    next[idx] = this.items[0];

    this.getUIContext().animateTo({ duration: 220, curve: Curve.EaseInOut }, () => {
      this.items = next;
    });
  }

  // the big hero tile
  @Builder
  heroTile($$: HeroParams) {
    Column() {
      metricValue({ metric: $$.metric })
      progressBar({ metric: $$.metric })
    }
    .height(46)
    .flexGrow(1)
    .flexBasis(0)
    .borderRadius(Theme.cardRadius)
    .backgroundColor(Theme.cardHi)
    .border({ width: 2, color: accentFor($$.metric.key) })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // a smaller support tile, tap to promote to hero
  @Builder
  supportTile($$: TileParams) {
    Column() {
      metricValue({ metric: $$.metric })
    }
    .height(30)
    .flexGrow($$.grow)
    .flexBasis(0)
    .borderRadius(Theme.cardRadius)
    .backgroundColor(Theme.card)
    .border({ width: 1, color: Theme.stroke })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    // make sure the whole tile is one tap target and children don't eat it
    .hitTestBehavior(HitTestMode.Block)
    .onClick(() => {
      this.makeHero($$.metric.key);
    })
  }

  build() {
    Column() {
      pageCrumbs(3, 0)

      Flex({
        direction: this.rowDirection(),
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Center,
        space: { main: LengthMetrics.vp(12) }
      }) {
        Text('AXIS')
          .fontSize(7)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.textDim)
          .letterSpacing(0.6)
        Text('⇄')
          .fontSize(10)
          .fontColor(this.mirrored ? Theme.text : Theme.textDim)
          .onClick(() => {
            this.getUIContext().animateTo({ duration: 220, curve: Curve.EaseInOut }, () => {
              this.mirrored = !this.mirrored;
            });
          })
      }
      .margin({ bottom: 3 })

      if (this.items.length >= AxisPage.SLOT_COUNT) {
        Column({ space: 6 }) {
          // hero row - one big tile filling the whole width
          Flex({ direction: this.rowDirection(), alignItems: ItemAlign.Center }) {
            this.heroTile({ metric: this.items[0] })
          }.width('100%')

          // support row 1 - two tiles, left one wider (grow 2 : 1)
          Flex({
            direction: this.rowDirection(),
            alignItems: ItemAlign.Center,
            space: { main: LengthMetrics.vp(6) }
          }) {
            this.supportTile({ metric: this.items[1], grow: 2 })
            this.supportTile({ metric: this.items[2], grow: 1 })
          }.width('100%')

          // support row 2 - three equal tiles (grow 1 : 1 : 1)
          Flex({
            direction: this.rowDirection(),
            alignItems: ItemAlign.Center,
            space: { main: LengthMetrics.vp(6) }
          }) {
            this.supportTile({ metric: this.items[3], grow: 1 })
            this.supportTile({ metric: this.items[4], grow: 1 })
            this.supportTile({ metric: this.items[5], grow: 1 })
          }.width('100%')
        }
        .width('82%')
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}