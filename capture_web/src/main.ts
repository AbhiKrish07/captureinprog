import './style.css'
import { renderHomeScreen } from './screens/HomeScreen'

const app = document.querySelector<HTMLDivElement>('#app')!

// Simple router
function navigate(path: string) {
  app.innerHTML = ''; // clear current
  if (path === '/' || path === '/home') {
    app.appendChild(renderHomeScreen());
  } else {
    app.innerHTML = `
      <div class="container" style="padding-top: 40px; text-align: center;">
        <h1 class="text-headline-large">404 - Not Found</h1>
        <p class="text-body-medium">Route: ${path}</p>
        <button onclick="window.location.hash = '/'" style="margin-top: 20px; padding: 10px 20px; border-radius: 8px; border: none; background: var(--orange); color: white; font-weight: bold; cursor: pointer;">Go Home</button>
      </div>
    `;
  }
}

// Listen to hash changes
window.addEventListener('hashchange', () => {
  const path = window.location.hash.replace('#', '') || '/';
  navigate(path);
});

// Initial load
window.dispatchEvent(new Event('hashchange'));
