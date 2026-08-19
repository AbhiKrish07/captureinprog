interface ShortcutProps {
  icon: string;
  color: string;
  label: string;
  onClick: () => void;
}

export function createShortcutCard({ icon, color, label, onClick }: ShortcutProps): HTMLElement {
  const card = document.createElement('div');
  card.className = 'shortcut-card';
  card.style.cssText = `
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    width: 80px;
    height: 90px;
    min-width: 80px;
    background-color: var(--surface);
    border-radius: 20px;
    box-shadow: var(--shadow-elevated);
    margin: 0 4px;
    cursor: pointer;
    transition: transform 0.2s ease, background-color 0.2s ease;
  `;
  
  card.innerHTML = `
    <span class="material-symbols-rounded" style="font-size: 28px; color: ${color};">${icon}</span>
    <span style="margin-top: 12px; color: var(--text-primary); font-size: 12px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 90%; text-align: center;">${label}</span>
  `;

  card.addEventListener('click', onClick);
  
  // Hover effect
  card.addEventListener('mouseenter', () => {
    card.style.backgroundColor = 'var(--card-hover)';
    card.style.transform = 'translateY(-2px)';
  });
  card.addEventListener('mouseleave', () => {
    card.style.backgroundColor = 'var(--surface)';
    card.style.transform = 'translateY(0)';
  });

  return card;
}
