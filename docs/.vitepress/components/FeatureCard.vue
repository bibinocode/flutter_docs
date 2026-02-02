<template>
  <div class="feature-card" :class="{ clickable: link }" @click="handleClick">
    <div class="card-icon" :style="iconStyle">
      <span>{{ icon }}</span>
    </div>
    <div class="card-content">
      <h3 class="card-title">{{ title }}</h3>
      <p class="card-description">{{ description }}</p>
      <div class="card-meta" v-if="chapters || status">
        <span class="chapters" v-if="chapters">{{ chapters }} 章节</span>
        <span class="status" :class="statusClass" v-if="status">{{ statusText }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  // 图标
  icon: string
  // 标题
  title: string
  // 描述
  description: string
  // 链接
  link?: string
  // 章节数
  chapters?: number
  // 状态: done | progress | todo
  status?: 'done' | 'progress' | 'todo'
  // 图标背景色
  iconColor?: string
}

const props = withDefaults(defineProps<Props>(), {
  iconColor: 'var(--vp-c-brand-soft)'
})

// 图标样式
const iconStyle = computed(() => ({
  backgroundColor: props.iconColor
}))

// 状态样式类
const statusClass = computed(() => ({
  done: props.status === 'done',
  progress: props.status === 'progress',
  todo: props.status === 'todo'
}))

// 状态文字
const statusText = computed(() => {
  switch (props.status) {
    case 'done':
      return '✅ 已完成'
    case 'progress':
      return '🔄 更新中'
    case 'todo':
      return '📝 规划中'
    default:
      return ''
  }
})

// 点击处理
const handleClick = () => {
  if (props.link) {
    window.location.href = props.link
  }
}
</script>

<style scoped>
.feature-card {
  display: flex;
  gap: 1rem;
  padding: 1.25rem;
  border-radius: 12px;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  transition: all 0.3s ease;
}

.feature-card.clickable {
  cursor: pointer;
}

.feature-card.clickable:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
  border-color: var(--vp-c-brand-soft);
}

.dark .feature-card.clickable:hover {
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
}

.card-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  border-radius: 12px;
  font-size: 1.5rem;
  flex-shrink: 0;
}

.card-content {
  flex: 1;
  min-width: 0;
}

.card-title {
  margin: 0 0 0.5rem;
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.card-description {
  margin: 0 0 0.75rem;
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  line-height: 1.5;
}

.card-meta {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 0.8rem;
}

.chapters {
  color: var(--vp-c-text-3);
}

.status {
  padding: 0.15rem 0.5rem;
  border-radius: 4px;
  font-weight: 500;
}

.status.done {
  background: rgba(34, 197, 94, 0.15);
  color: #22c55e;
}

.status.progress {
  background: rgba(59, 130, 246, 0.15);
  color: #3b82f6;
}

.status.todo {
  background: rgba(156, 163, 175, 0.15);
  color: #9ca3af;
}

@media (max-width: 768px) {
  .feature-card {
    flex-direction: column;
    align-items: center;
    text-align: center;
  }
  
  .card-meta {
    justify-content: center;
  }
}
</style>
