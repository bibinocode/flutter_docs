<template>
  <div class="dartpad-container">
    <div class="dartpad-header">
      <span class="title">
        <span class="icon">🎯</span>
        {{ title || 'DartPad 在线运行' }}
      </span>
      <div class="actions">
        <button @click="openInDartPad" class="action-btn" title="在 DartPad 中打开">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path>
            <polyline points="15 3 21 3 21 9"></polyline>
            <line x1="10" y1="14" x2="21" y2="3"></line>
          </svg>
        </button>
        <button @click="reload" class="action-btn" title="重新加载">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="23 4 23 10 17 10"></polyline>
            <polyline points="1 20 1 14 7 14"></polyline>
            <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path>
          </svg>
        </button>
      </div>
    </div>
    <div class="dartpad-body">
      <iframe
        ref="iframeRef"
        :src="iframeSrc"
        :style="{ height: height + 'px' }"
        loading="lazy"
        allow="clipboard-write"
      ></iframe>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

interface Props {
  // DartPad Gist ID
  id?: string
  // 直接传入代码
  code?: string
  // 标题
  title?: string
  // 高度
  height?: number
  // 模式: dart | flutter
  mode?: 'dart' | 'flutter'
  // 主题: light | dark
  theme?: 'light' | 'dark'
  // 是否显示运行按钮
  run?: boolean
  // 是否分屏显示
  split?: number
}

const props = withDefaults(defineProps<Props>(), {
  height: 400,
  mode: 'flutter',
  theme: 'dark',
  run: true,
  split: 50
})

const iframeRef = ref<HTMLIFrameElement | null>(null)
const key = ref(0)

// 构建 DartPad URL
const iframeSrc = computed(() => {
  const baseUrl = props.mode === 'flutter' 
    ? 'https://dartpad.dev/embed-flutter.html'
    : 'https://dartpad.dev/embed-dart.html'
  
  const params = new URLSearchParams()
  
  // Gist ID 模式
  if (props.id) {
    params.set('id', props.id)
  }
  
  // 直接代码模式
  if (props.code) {
    params.set('code', encodeURIComponent(props.code))
  }
  
  // 主题
  params.set('theme', props.theme)
  
  // 运行按钮
  params.set('run', props.run ? 'true' : 'false')
  
  // 分屏比例
  params.set('split', props.split.toString())
  
  // 空安全
  params.set('null_safety', 'true')
  
  return `${baseUrl}?${params.toString()}&_=${key.value}`
})

// 在 DartPad 中打开
const openInDartPad = () => {
  const url = props.id 
    ? `https://dartpad.dev/?id=${props.id}`
    : 'https://dartpad.dev/'
  window.open(url, '_blank')
}

// 重新加载
const reload = () => {
  key.value++
}

onMounted(() => {
  // 监听系统主题变化
  if (typeof window !== 'undefined') {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    mediaQuery.addEventListener('change', () => {
      // 可以根据需要自动切换主题
    })
  }
})
</script>

<style scoped>
.dartpad-container {
  border-radius: 12px;
  overflow: hidden;
  margin: 1.5rem 0;
  border: 1px solid var(--vp-c-border);
  background: var(--vp-c-bg-soft);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.dark .dartpad-container {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.dartpad-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.75rem 1rem;
  background: var(--vp-c-bg-mute);
  border-bottom: 1px solid var(--vp-c-border);
}

.dartpad-header .title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--vp-c-brand-1);
}

.dartpad-header .icon {
  font-size: 1.1rem;
}

.dartpad-header .actions {
  display: flex;
  gap: 0.5rem;
}

.action-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border: none;
  border-radius: 6px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-2);
  cursor: pointer;
  transition: all 0.2s ease;
}

.action-btn:hover {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
}

.dartpad-body {
  position: relative;
}

.dartpad-body iframe {
  width: 100%;
  border: none;
  background: #1e1e1e;
}

/* 加载动画 */
.dartpad-body::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 40px;
  height: 40px;
  border: 3px solid var(--vp-c-border);
  border-top-color: var(--vp-c-brand-1);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  z-index: 1;
}

.dartpad-body iframe:not([src=""]) + ::before {
  display: none;
}

@keyframes spin {
  to {
    transform: translate(-50%, -50%) rotate(360deg);
  }
}

/* 响应式 */
@media (max-width: 768px) {
  .dartpad-container {
    margin: 1rem 0;
    border-radius: 8px;
  }
  
  .dartpad-header {
    padding: 0.5rem 0.75rem;
  }
  
  .dartpad-header .title {
    font-size: 0.85rem;
  }
}
</style>
