import { LengthMetrics } from '@kit.ArkUI';
import { Metric } from '../model/HealthData';
import { Theme } from '../model/Theme';


export interface MetricParams {
  metric: Metric;
}

export function accentFor(key: string): string {
  switch (key) {
    case 'hr':
      return Theme.hr;
    case 'steps':
      return Theme.steps;
    case 'kcal':
      return Theme.cal;
    case 'spo2':
      return Theme.o2;
    default:
      return Theme.text;
  }
}

export function progressFor(key: string): number {
  switch (key) {
    case 'hr':
      return 68;
    case 'steps':
      return 82;
    case 'kcal':
      return 45;
    case 'spo2':
      return 97;
    default:
      return 55;
  }
}

@Builder
export function metricValue($$: MetricParams) {
  Text(`${$$.metric.value}`)
    .fontSize(12)
    .fontWeight(FontWeight.Bold)
    .fontColor(accentFor($$.metric.key))
    .maxLines(1)
  Text($$.metric.label.toUpperCase())
    .fontSize(5)
    .fontColor(Theme.textDim)
    .letterSpacing(0.5)
    .maxLines(1)
    .margin({ top: 1 })
}

@Builder
export function progressBar($$: MetricParams) {
  Flex({ direction: FlexDirection.Row }) {
    Row()
      .flexGrow(progressFor($$.metric.key))
      .flexBasis(0)
      .height(2)
      .borderRadius(1)
      .backgroundColor(accentFor($$.metric.key))
    Row()
      .flexGrow(100 - progressFor($$.metric.key))
      .flexBasis(0)
      .height(2)
  }
  .width('72%')
  .height(2)
  .borderRadius(1)
  .backgroundColor(Theme.stroke)
  .margin({ top: 3 })
}

const CRUMB_IDS: number[] = [0, 1, 2, 3, 4];

@Builder
export function pageCrumbs(count: number, active: number) {
  Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center, space: { main: LengthMetrics.vp(4) } }) {
    ForEach(
      CRUMB_IDS.slice(0, count),
      (id: number, index: number) => {
        Circle({ width: 3, height: 3 }).fill(index === active ? Theme.text : Theme.stroke)
      },
      (id: number, index: number) => index === active ? `${id}-on` : `${id}-off`
    )
  }
  .margin({ bottom: 3 })
}