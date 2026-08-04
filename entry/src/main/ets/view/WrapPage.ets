import { LengthMetrics } from '@kit.ArkUI';
import { Theme } from '../model/Theme';
import { pageCrumbs } from './MetricCommon';

interface ActivityChip {
  key: string;
  label: string;
  color: string;
}

// $$ reference passing — required so the builder body re-runs on state change.
interface ChipParams {
  chip: ActivityChip;
}

interface CountParams {
  sign: string;
  enabled: boolean;
}

@Component
export struct WrapPage {
  @State private compact: boolean = false;
  @State private doneKeys: string[] = ['run'];
  // How many chips are shown right now. + and - change this.
  @State private shownCount: number = 4;
  // All the chips live here. Only shownCount of them get displayed.
  private pool: ActivityChip[] = [
    { key: 'run', label: 'Run 5km', color: Theme.steps },
    { key: 'hiit', label: 'HIIT', color: Theme.cal },
    { key: 'swim', label: 'Swim', color: Theme.o2 },
    { key: 'sleep', label: 'Sleep 7h', color: Theme.hr },
    { key: 'water', label: 'Water', color: Theme.o2 },
    { key: 'stretch', label: 'Stretch 10min', color: Theme.steps },
    { key: 'walk', label: 'Walk', color: Theme.cal },
    { key: 'yoga', label: 'Yoga', color: Theme.hr },
    { key: 'cycle', label: 'Cycle 12km', color: Theme.cal }
  ];

  private shownChips(): ActivityChip[] {
    return this.pool.slice(0, this.shownCount);
  }

  // Add one chip (if the pool isn't used up). animateTo so the wrap reflow
  // is a transition rather than a jump.
  private addChip() {
    if (this.shownCount >= this.pool.length) {
      return;
    }
    this.getUIContext().animateTo({ duration: 180, curve: Curve.EaseInOut }, () => {
      this.shownCount = this.shownCount + 1;
    });
  }

  // Remove one chip, never below 1.
  private removeChip() {
    if (this.shownCount <= 1) {
      return;
    }
    this.getUIContext().animateTo({ duration: 180, curve: Curve.EaseInOut }, () => {
      this.shownCount = this.shownCount - 1;
    });
  }

  private gap(): LengthMetrics {
    return LengthMetrics.vp(this.compact ? 3 : 6);
  }

  private isDone(key: string): boolean {
    return this.doneKeys.includes(key);
  }

  // Toggle a chip's done state when tapped.
  private toggleDone(key: string) {
    if (this.isDone(key)) {
      this.doneKeys = this.doneKeys.filter((k: string) => k !== key);
    } else {
      this.doneKeys = this.doneKeys.concat([key]);
    }
  }

  // Only count done chips that are currently visible. Walk the visible list
  // once instead of re-slicing the pool per done key.
  private doneCount(): number {
    return this.shownChips().filter((c: ActivityChip) => this.doneKeys.includes(c.key)).length;
  }

  @Builder
  chip($$: ChipParams) {
    Row() {
      Circle()
        .width(5)
        .height(5)
        .fill(this.isDone($$.chip.key) ? Theme.card : $$.chip.color)
        .margin({ right: 4 })
      Text($$.chip.label)
        .fontSize(8)
        .fontColor(this.isDone($$.chip.key) ? Theme.card : Theme.text)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .padding({
      left: 9,
      right: 9,
      top: 5,
      bottom: 5
    })
    .borderRadius(11)
    .backgroundColor(this.isDone($$.chip.key) ? $$.chip.color : Theme.card)
    .border({ width: 1, color: this.isDone($$.chip.key) ? $$.chip.color : Theme.stroke })
    .hitTestBehavior(HitTestMode.Block)
    .animation({ duration: 180, curve: Curve.EaseInOut })
    // Chips fade + scale in and out as shownCount changes.
    .transition(TransitionEffect.OPACITY
      .combine(TransitionEffect.scale({ x: 0.85, y: 0.85 }))
      .animation({ duration: 180, curve: Curve.EaseInOut }))
    .onClick(() => {
      this.toggleDone($$.chip.key);
    })
  }

  // The + and - buttons, standalone row pinned to the bottom.
  @Builder
  countButton($$: CountParams) {
    Row() {
      Text($$.sign)
        .fontSize(10)
        .fontWeight(FontWeight.Bold)
        .fontColor($$.enabled ? Theme.text : Theme.textDim)
    }
    .width(30)
    .justifyContent(FlexAlign.Center)
    .padding({ top: 5, bottom: 5 })
    .borderRadius(10)
    .backgroundColor(Theme.card)
    .border({ width: 1, color: Theme.stroke })
    .opacity($$.enabled ? 1 : 0.4)
    .hitTestBehavior(HitTestMode.Block)
    .animation({ duration: 150, curve: Curve.EaseInOut })
    .onClick(() => {
      if (!$$.enabled) {
        return;
      }
      if ($$.sign === '+') {
        this.addChip();
      } else {
        this.removeChip();
      }
    })
  }

  // Small summary ring in the middle: done chips / total chips.
  // stroke/strokeWidth, not border — border would draw a square around the
  // circle's bounding box.
  @Builder
  summaryRing() {
    Stack() {
      Circle()
        .width(26)
        .height(26)
        .fill(Theme.card)
        .stroke(Theme.stroke)
        .strokeWidth(2)
      Column() {
        Text(`${this.doneCount()}`)
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.text)
        Text(`/${this.shownCount}`)
          .fontSize(5)
          .fontColor(Theme.textDim)
      }
    }
    .width(26)
    .height(26)
  }

  build() {
    Column() {
      pageCrumbs(3, 2)

      // Top part: summary ring, title, and the compact/loose button.
      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Center,
        space: { main: LengthMetrics.vp(8) }
      }) {
        this.summaryRing()
        Text('Activities')
          .fontSize(8)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.text)
          .letterSpacing(0.8)
        Text(this.compact ? '▪▪' : '▪ ▪')
          .fontSize(9)
          .letterSpacing(0.8)
          .fontColor(this.compact ? Theme.text : Theme.textDim)
          .padding(6)
          .hitTestBehavior(HitTestMode.Block)
          .onClick(() => {
            this.getUIContext().animateTo({ duration: 180, curve: Curve.EaseInOut }, () => {
              this.compact = !this.compact;
            });
          })
      }
      .width('82%')
      .margin({ bottom: 6 })

      Flex({
        wrap: FlexWrap.Wrap,
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Center,
        alignContent: FlexAlign.SpaceEvenly,
        space: { main: this.gap(), cross: this.gap() }
      }) {
        ForEach(this.shownChips(), (c: ActivityChip) => {
          this.chip({ chip: c })
        }, (c: ActivityChip) => c.key)
      }
      .width('82%')
      .layoutWeight(1)

      // Buttons, fixed at the bottom regardless of chip count.
      Row({ space: 8 }) {
        this.countButton({ sign: '−', enabled: this.shownCount > 1 })
        this.countButton({ sign: '+', enabled: this.shownCount < this.pool.length })
      }
      .width('82%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding({ top: 18, bottom: 12 })
  }
}