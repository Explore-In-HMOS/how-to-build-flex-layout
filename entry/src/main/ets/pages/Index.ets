import { AxisPage } from '../view/AxisPage';
import { AdaptPage } from '../view/AdaptPage';
import { WrapPage } from '../view/WrapPage';
import { Theme } from '../model/Theme';

@Entry
@Component
struct Index {
  build() {
    Swiper() {
      AxisPage()
      AdaptPage()
      WrapPage()
    }
    .loop(false)
    .indicator(false)
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg)
    .padding({ top: 16, bottom: 12 })
  }
}