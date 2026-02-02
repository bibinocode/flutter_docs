<template>
  <a :href="link" class="widget-card" :class="{ 'no-link': !link }">
    <div class="card-header">
      <span class="icon" v-if="icon">{{ icon }}</span>
      <span class="name">{{ name }}</span>
      <span class="badge" v-if="badge" :class="badgeType">{{ badge }}</span>
    </div>
    <p class="description" v-if="description">{{ description }}</p>
    <div class="tags" v-if="tags && tags.length">
      <span class="tag" v-for="tag in tags" :key="tag">{{ tag }}</span>
    </div>
    <div class="preview" v-if="$slots.preview">
      <slot name="preview"></slot>
    </div>
  </a>
</template>

<script setup lang="ts">
interface Props {
  // Widget 名称
  name: string
  // 图标
  icon?: string
  // 描述
  description?: string
  // 链接
  link?: string
  // 标签
  tags?: string[]
  // 徽章文字
  badge?: string
  // 徽章类型
  badgeType?: 'new' | 'updated' | 'deprecated' | 'material' | 'cupertino'
}

const props = withDefaults(defineProps<Props>(), {
  badgeType: 'new'
})
</script>

<style scoped>
.widget-card {
  display: block;
  border-radius: 12px;
  padding: 1.25rem;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  transition: all 0.3s ease;
  text-decoration: none;
  color: inherit;
}

.widget-card:not(.no-link) {
  cursor: pointer;
}

.widget-card:not(.no-link):hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
  border-color: var(--vp-c-brand-soft);
}

.dark .widget-card:not(.no-link):hover {
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
}

.card-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.icon {
  font-size: 1.3rem;
}

.name {
  font-weight: 600;
  font-size: 1.1rem;
  color: var(--vp-c-brand-1);
}

.badge {
  font-size: 0.7rem;
  padding: 0.15rem 0.4rem;
  border-radius: 4px;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.badge.new {
  background: rgba(34, 197, 94, 0.15);
  color: #22c55e;
}

.badge.updated {
  background: rgba(59, 130, 246, 0.15);
  color: #3b82f6;
}

.badge.deprecated {
  background: rgba(239, 68, 68, 0.15);
  color: #ef4444;
}

.badge.material {
  background: rgba(5, 83, 177, 0.15);
  color: var(--vp-c-brand-1);
}

.badge.cupertino {
  background: rgba(0, 122, 255, 0.15);
  color: #007aff;
}

.description {
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  line-height: 1.6;
  margin: 0 0 0.75rem;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.tag {
  font-size: 0.75rem;
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  background: var(--vp-c-bg-mute);
  color: var(--vp-c-text-2);
  border: 1px solid var(--vp-c-border);
}

.preview {
  margin-top: 1rem;
  padding: 1rem;
  background: var(--vp-c-bg);
  border-radius: 8px;
  border: 1px solid var(--vp-c-border);
}
</style>
