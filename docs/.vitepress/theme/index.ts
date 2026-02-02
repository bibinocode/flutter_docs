// https://vitepress.dev/guide/custom-theme
import { h } from 'vue'
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import './styles/custom.css'

// 自定义组件
import DartPad from '../components/DartPad.vue'
import FlutterPreview from '../components/FlutterPreview.vue'
import WidgetCard from '../components/WidgetCard.vue'
import FeatureCard from '../components/FeatureCard.vue'

export default {
  extends: DefaultTheme,
  Layout: () => {
    return h(DefaultTheme.Layout, null, {
      // 可以在这里添加自定义插槽
    })
  },
  enhanceApp({ app, router, siteData }) {
    // 注册全局组件
    app.component('DartPad', DartPad)
    app.component('FlutterPreview', FlutterPreview)
    app.component('WidgetCard', WidgetCard)
    app.component('FeatureCard', FeatureCard)
  }
} satisfies Theme
