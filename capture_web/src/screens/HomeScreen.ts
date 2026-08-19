import { toggleTheme } from '../utils/theme';
import { createShortcutCard } from '../components/ShortcutCard';
import { createRecentItem } from '../components/RecentItem';

export function renderHomeScreen(): HTMLElement {
  const wrapper = document.createElement('div');
  wrapper.style.cssText = `
    display: flex;
    flex-direction: column;
    padding-bottom: 32px;
  `;

  // --- Header ---
  const header = document.createElement('div');
  header.className = 'container';
  header.style.cssText = `
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 12px;
    padding-bottom: 12px;
  `;
  header.innerHTML = `
    <div style="display: flex; align-items: center; gap: 8px;">
      <span class="material-symbols-rounded" style="color: var(--orange); font-size: 28px;">auto_awesome_mosaic</span>
      <span style="color: var(--text-primary); font-size: 20px; font-weight: 700; letter-spacing: -0.5px;">Capture</span>
    </div>
    <div style="display: flex; align-items: center; gap: 8px;">
      <button id="theme-toggle" style="background: none; border: none; cursor: pointer; padding: 8px; display: flex; align-items: center; justify-content: center;">
        <span class="material-symbols-rounded" style="color: var(--text-primary); font-size: 24px;">dark_mode</span>
      </button>
      <div style="width: 36px; height: 36px; border-radius: 50%; border: 1.5px solid var(--border); overflow: hidden; cursor: pointer; background-image: url('https://i.pravatar.cc/150?img=11'); background-size: cover;">
      </div>
    </div>
  `;
  wrapper.appendChild(header);

  // Theme toggle listener
  const themeToggle = header.querySelector('#theme-toggle') as HTMLButtonElement;
  themeToggle.addEventListener('click', () => {
    toggleTheme();
    const icon = themeToggle.querySelector('span');
    if (icon) {
      const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
      icon.textContent = isDark ? 'light_mode' : 'dark_mode';
    }
  });

  // --- Greeting ---
  const greeting = document.createElement('div');
  greeting.className = 'container';
  greeting.style.cssText = 'margin-top: 24px; margin-bottom: 32px; animation: slideUpFade 0.5s ease;';
  
  const hour = new Date().getHours();
  let timeGreeting = 'Good morning';
  if (hour >= 12 && hour < 17) timeGreeting = 'Good afternoon';
  else if (hour >= 17) timeGreeting = 'Good evening';
  
  greeting.innerHTML = `
    <h1 style="color: var(--text-primary); font-size: 36px; font-weight: 800; line-height: 1.1; letter-spacing: -1px; margin: 0 0 12px 0;">
      ${timeGreeting} Boss,<br/>what are we <span style="color: var(--orange);">capturing?</span>
    </h1>
    <p style="color: var(--text-secondary); font-size: 14px; font-weight: 500; margin: 0;">
      Drop anything. We'll handle the rest.
    </p>
  `;
  wrapper.appendChild(greeting);

  // --- Shortcuts ---
  const shortcutsContainer = document.createElement('div');
  shortcutsContainer.style.cssText = `
    display: flex;
    overflow-x: auto;
    padding: 0 20px 10px 20px;
    margin-bottom: 32px;
    -webkit-overflow-scrolling: touch;
    scrollbar-width: none; /* Firefox */
  `;
  
  const shortcuts = [
    { icon: 'edit_document', color: 'var(--blue)', label: 'Note' },
    { icon: 'camera_alt', color: 'var(--green)', label: 'Photo' },
    { icon: 'mic', color: 'var(--yellow)', label: 'Voice' },
    { icon: 'check_box', color: 'var(--violet)', label: 'Task' },
    { icon: 'link', color: 'var(--orange)', label: 'Link' }
  ];

  shortcuts.forEach(s => {
    const card = createShortcutCard({
      icon: s.icon,
      color: s.color,
      label: s.label,
      onClick: () => window.location.hash = '/capture'
    });
    shortcutsContainer.appendChild(card);
  });
  wrapper.appendChild(shortcutsContainer);

  // --- Search Bar ---
  const searchContainer = document.createElement('div');
  searchContainer.className = 'container';
  searchContainer.style.cssText = 'margin-bottom: 32px;';
  searchContainer.innerHTML = `
    <div style="background-color: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 12px 16px; display: flex; align-items: center; cursor: pointer; transition: border-color 0.2s ease;">
      <span class="material-symbols-rounded" style="color: var(--text-secondary); font-size: 20px;">search</span>
      <span style="color: var(--text-secondary); font-size: 15px; margin-left: 12px; flex: 1;">Search captures, spaces...</span>
      <span class="material-symbols-rounded" style="color: var(--text-secondary); font-size: 20px; cursor: pointer;">mic</span>
    </div>
  `;
  const searchBox = searchContainer.firstElementChild as HTMLElement;
  searchBox.addEventListener('mouseenter', () => searchBox.style.borderColor = 'var(--border-focused)');
  searchBox.addEventListener('mouseleave', () => searchBox.style.borderColor = 'var(--border)');
  searchBox.addEventListener('click', () => window.location.hash = '/search');
  wrapper.appendChild(searchContainer);

  // --- Recents Section ---
  const recentsSection = document.createElement('div');
  recentsSection.className = 'container';
  recentsSection.innerHTML = `
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
      <div style="display: flex; align-items: center; gap: 4px;">
        <span style="color: var(--text-primary); font-size: 18px; font-weight: 700;">Recent</span>
        <span class="material-symbols-rounded" style="color: var(--text-primary); font-size: 20px;">keyboard_arrow_down</span>
      </div>
      <div style="display: flex; align-items: center; gap: 2px; cursor: pointer;" onclick="window.location.hash = '/recents'">
        <span style="color: var(--text-secondary); font-size: 13px; font-weight: 500;">View all</span>
        <span class="material-symbols-rounded" style="color: var(--text-secondary); font-size: 16px;">chevron_right</span>
      </div>
    </div>
  `;
  
  const recentsList = document.createElement('div');
  const recentsData = [
    { type: 'image' as const, icon: 'image', title: 'Design mockup for landing page', time: '2m ago' },
    { type: 'video' as const, icon: 'play_arrow', title: 'Product Demo Recording', time: '1h ago' },
    { type: 'file' as const, icon: 'insert_drive_file', title: 'Q3 Financial Report.pdf', time: '2d ago' },
    { type: 'link' as const, icon: 'link', title: 'https://example.com/inspiration', time: '5d ago' },
  ];

  recentsData.forEach(r => {
    const item = createRecentItem({
      icon: r.icon,
      type: r.type,
      title: r.title,
      time: r.time,
      onClick: () => window.location.hash = `/capture/${r.type}`
    });
    recentsList.appendChild(item);
  });
  
  recentsSection.appendChild(recentsList);
  wrapper.appendChild(recentsSection);

  // Add keyframes for animation
  if (!document.getElementById('home-styles')) {
    const style = document.createElement('style');
    style.id = 'home-styles';
    style.textContent = `
      @keyframes slideUpFade {
        from { opacity: 0; transform: translateY(20%); }
        to { opacity: 1; transform: translateY(0); }
      }
    `;
    document.head.appendChild(style);
  }

  return wrapper;
}
