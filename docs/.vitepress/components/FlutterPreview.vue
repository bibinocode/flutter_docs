<template>
  <div class="flutter-preview-container">
    <div class="preview-header">
      <div class="header-left">
        <span class="icon">📱</span>
        <span class="title">{{ title || 'Flutter Web 预览' }}</span>
      </div>
      <div class="header-right">
        <div class="device-selector" v-if="showDeviceSelector">
          <button 
            v-for="device in devices" 
            :key="device.name"
            :class="['device-btn', { active: currentDevice.name === device.name }]"
            @click="selectDevice(device)"
            :title="device.name"
          >
            {{ device.icon }}
          </button>
        </div>
        <div class="actions">
          <button @click="reload" class="action-btn" title="重新加载">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="23 4 23 10 17 10"></polyline>
              <polyline points="1 20 1 14 7 14"></polyline>
              <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path>
            </svg>
          </button>
          <button @click="openInNewTab" class="action-btn" title="新窗口打开">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path>
              <polyline points="15 3 21 3 21 9"></polyline>
              <line x1="10" y1="14" x2="21" y2="3"></line>
            </svg>
          </button>
        </div>
      </div>
    </div>
    <div class="preview-body" :style="bodyStyle">
      <div class="device-frame" :style="frameStyle">
        <div class="device-screen">
          <iframe
            ref="iframeRef"
            :src="fullUrl"
            :style="iframeStyle"
            loading="lazy"
            allow="clipboard-write; camera; microphone"
          ></iframe>
        </div>
      </div>
    </div>
    <div class="preview-footer" v-if="showFooter">
      <span class="route">{{ route || '/' }}</span>
      <span class="device-info">{{ currentDevice.name }} · {{ currentDevice.width }}×{{ currentDevice.height }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'

interface Device {
  name: string
  icon: string
  width: number
  height: number
}

interface Props {
  // Demo 基础 URL
  baseUrl?: string
  // 路由路径
  route?: string
  // 标题
  title?: string
  // 是否显示设备选择器
  showDeviceSelector?: boolean
  // 是否显示底部栏
  showFooter?: boolean
  // 默认设备
  defaultDevice?: 'phone' | 'tablet' | 'desktop'
  // 自定义高度
  height?: number
}

const props = withDefaults(defineProps<Props>(), {
  baseUrl: 'https://demo.flutter.kmod.cn',
  route: '/',
  showDeviceSelector: true,
  showFooter: true,
  defaultDevice: 'phone',
  height: 600
})

const iframeRef = ref<HTMLIFrameElement | null>(null)
const key = ref(0)

// 设备配置
const devices: Device[] = [
  { name: 'iPhone 14', icon: '📱', width: 390, height: 844 },
  { name: 'iPad', icon: '📲', width: 768, height: 1024 },
  { name: 'Desktop', icon: '🖥️', width: 1280, height: 800 }
]

// 根据默认设备类型获取设备
const getDefaultDevice = () => {
  switch (props.defaultDevice) {
    case 'tablet':
      return devices[1]
    case 'desktop':
      return devices[2]
    default:
      return devices[0]
  }
}

const currentDevice = ref<Device>(getDefaultDevice())

// 完整 URL
const fullUrl = computed(() => {
  const base = props.baseUrl.replace(/\/$/, '')
  const route = props.route.startsWith('/') ? props.route : `/${props.route}`
  return `${base}/#${route}?_=${key.value}`
})

// 预览区域样式
const bodyStyle = computed(() => ({
  height: `${props.height}px`,
  padding: '1rem',
  display: 'flex',
  justifyContent: 'center',
  alignItems: 'flex-start',
  overflow: 'auto'
}))

// 设备框架样式
const frameStyle = computed(() => {
  const device = currentDevice.value
  const scale = Math.min(
    1,
    (props.height - 40) / device.height
  )
  
  return {
    width: `${device.width}px`,
    height: `${device.height}px`,
    transform: `scale(${scale})`,
    transformOrigin: 'top center'
  }
})

// iframe 样式
const iframeStyle = computed(() => ({
  width: '100%',
  height: '100%',
  border: 'none'
}))

// 选择设备
const selectDevice = (device: Device) => {
  currentDevice.value = device
}

// 重新加载
const reload = () => {
  key.value++
}

// 新窗口打开
const openInNewTab = () => {
  window.open(fullUrl.value.replace(`?_=${key.value}`, ''), '_blank')
}

// 监听路由变化
watch(() => props.route, () => {
  key.value++
})
</script>

<style scoped>
.flutter-preview-container {
  border-radius: 12px;
  overflow: hidden;
  margin: 1.5rem 0;
  border: 1px solid var(--vp-c-border);
  background: var(--vp-c-bg-soft);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.dark .flutter-preview-container {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

/* Header */
.preview-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.75rem 1rem;
  background: var(--vp-c-bg-mute);
  border-bottom: 1px solid var(--vp-c-border);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.header-left .icon {
  font-size: 1.2rem;
}

.header-left .title {
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--vp-c-brand-1);
}

.header-right {
  display: flex;
  align-items: center;
  gap: 1rem;
}

/* Device Selector */
.device-selector {
  display: flex;
  gap: 0.25rem;
  padding: 0.25rem;
  background: var(--vp-c-bg);
  border-radius: 8px;
}

.device-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 28px;
  border: none;
  border-radius: 6px;
  background: transparent;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.device-btn:hover {
  background: var(--vp-c-bg-soft);
}

.device-btn.active {
  background: var(--vp-c-brand-soft);
}

/* Actions */
.actions {
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

/* Body */
.preview-body {
  background: linear-gradient(135deg, #f5f5f5 0%, #e8e8e8 100%);
}

.dark .preview-body {
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
}

/* Device Frame */
.device-frame {
  background: #000;
  border-radius: 36px;
  padding: 12px;
  box-shadow: 
    0 0 0 2px #333,
    0 20px 40px rgba(0, 0, 0, 0.3);
}

.device-screen {
  width: 100%;
  height: 100%;
  border-radius: 24px;
  overflow: hidden;
  background: #fff;
}

.device-screen iframe {
  background: #fff;
}

/* Footer */
.preview-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.5rem 1rem;
  background: var(--vp-c-bg-mute);
  border-top: 1px solid var(--vp-c-border);
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
}

.preview-footer .route {
  font-family: 'JetBrains Mono', monospace;
  color: var(--vp-c-brand-1);
}

/* 响应式 */
@media (max-width: 768px) {
  .flutter-preview-container {
    margin: 1rem 0;
    border-radius: 8px;
  }
  
  .preview-header {
    flex-wrap: wrap;
    gap: 0.5rem;
  }
  
  .device-selector {
    display: none;
  }
  
  .preview-body {
    padding: 0.5rem !important;
  }
  
  .device-frame {
    border-radius: 20px;
    padding: 8px;
  }
  
  .device-screen {
    border-radius: 14px;
  }
}
</style>
