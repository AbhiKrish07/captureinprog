interface RecentItemProps {
  icon: string;
  type: 'image' | 'video' | 'file' | 'link' | 'other';
  title: string;
  time: string;
  onClick: () => void;
}

export function createRecentItem({ icon, type, title, time, onClick }: RecentItemProps): HTMLElement {
  const container = document.createElement('div');
  container.className = 'recent-item';
  container.style.cssText = `
    display: flex;
    align-items: center;
    padding: 12px;
    background-color: var(--surface);
    border-radius: 16px;
    box-shadow: var(--shadow-small);
    margin-bottom: 12px;
    cursor: pointer;
    transition: background-color 0.2s ease;
  `;

  const typeClass = `type-${type}`;
  
  container.innerHTML = `
    <div style="width: 44px; height: 44px; min-width: 44px; border-radius: 12px; background-color: var(--${typeClass}-bg); display: flex; align-items: center; justify-content: center;">
      <span class="material-symbols-rounded" style="color: var(--${typeClass}-fg); font-size: 24px;">${icon}</span>
    </div>
    <div style="margin-left: 16px; flex: 1; min-width: 0;">
      <div style="color: var(--text-primary); font-size: 14px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">${title}</div>
      <div style="display: flex; align-items: center; margin-top: 4px;">
        <span style="color: var(--text-tertiary); font-size: 12px; font-weight: 500; text-transform: capitalize;">${type}</span>
        <div style="width: 3px; height: 3px; border-radius: 50%; background-color: var(--border); margin: 0 6px;"></div>
        <span style="color: var(--text-tertiary); font-size: 12px; font-weight: 500;">${time}</span>
      </div>
    </div>
    <div style="padding: 8px;">
      <span class="material-symbols-rounded" style="color: var(--border); font-size: 24px;">more_horiz</span>
    </div>
  `;

  container.addEventListener('click', onClick);
  
  container.addEventListener('mouseenter', () => container.style.backgroundColor = 'var(--card-hover)');
  container.addEventListener('mouseleave', () => container.style.backgroundColor = 'var(--surface)');

  return container;
}
