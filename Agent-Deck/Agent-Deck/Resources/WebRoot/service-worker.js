/**
 * Agent Deck Service Worker
 * Provides offline capability and caching for PWA
 *
 * Caching Strategy: Network-first with offline fallback
 * - Try network first for real-time data
 * - Fall back to cache if offline
 * - Cache UI shell for offline access
 */

const CACHE_NAME = 'agent-deck-v1';
const CACHE_VERSION = '1.0.0';

// Files to cache for offline access (UI shell)
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/app.js',
  '/styles.css',
  '/manifest.json',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
  '/favicon.ico'
];

// Install event - cache static assets
self.addEventListener('install', (event) => {
  console.log('[Service Worker] Installing service worker...', CACHE_VERSION);

  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[Service Worker] Caching UI shell');
        return cache.addAll(STATIC_ASSETS);
      })
      .then(() => {
        console.log('[Service Worker] UI shell cached successfully');
        return self.skipWaiting(); // Activate immediately
      })
      .catch((error) => {
        console.error('[Service Worker] Failed to cache UI shell:', error);
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  console.log('[Service Worker] Activating service worker...', CACHE_VERSION);

  event.waitUntil(
    caches.keys()
      .then((cacheNames) => {
        return Promise.all(
          cacheNames
            .filter((name) => name !== CACHE_NAME)
            .map((name) => {
              console.log('[Service Worker] Deleting old cache:', name);
              return caches.delete(name);
            })
        );
      })
      .then(() => {
        console.log('[Service Worker] Service worker activated');
        return self.clients.claim(); // Take control immediately
      })
  );
});

// Fetch event - network-first strategy with offline fallback
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip non-GET requests
  if (request.method !== 'GET') {
    return;
  }

  // Skip WebSocket connections (not cacheable)
  if (url.protocol === 'ws:' || url.protocol === 'wss:') {
    return;
  }

  // Network-first strategy
  event.respondWith(
    fetch(request)
      .then((response) => {
        // Clone response to cache it
        const responseToCache = response.clone();

        // Cache successful responses for static assets
        if (response.status === 200 && STATIC_ASSETS.some(asset => url.pathname.endsWith(asset))) {
          caches.open(CACHE_NAME)
            .then((cache) => {
              cache.put(request, responseToCache);
            });
        }

        return response;
      })
      .catch((error) => {
        console.log('[Service Worker] Network request failed, falling back to cache:', url.pathname);

        // Try to return cached response
        return caches.match(request)
          .then((cachedResponse) => {
            if (cachedResponse) {
              console.log('[Service Worker] Serving from cache:', url.pathname);
              return cachedResponse;
            }

            // If no cache available, return offline page for HTML requests
            if (request.headers.get('accept')?.includes('text/html')) {
              console.log('[Service Worker] No cache available, returning offline fallback');
              return caches.match('/index.html')
                .then((fallback) => {
                  return fallback || new Response(
                    createOfflineFallback(),
                    {
                      headers: { 'Content-Type': 'text/html' }
                    }
                  );
                });
            }

            // For other resources, return error
            return new Response('Offline - Resource not available', {
              status: 503,
              statusText: 'Service Unavailable',
              headers: { 'Content-Type': 'text/plain' }
            });
          });
      })
  );
});

/**
 * Create offline fallback HTML
 * Displayed when the app is offline and no cached version available
 */
function createOfflineFallback() {
  return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="theme-color" content="#1a1a1a">
    <title>Agent Deck - Offline</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: #1a1a1a;
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 2rem;
            text-align: center;
        }

        .offline-container {
            max-width: 400px;
        }

        .offline-icon {
            font-size: 4rem;
            margin-bottom: 1rem;
            opacity: 0.6;
        }

        h1 {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
            color: #ff9500;
        }

        p {
            font-size: 1rem;
            color: #999;
            line-height: 1.5;
            margin-bottom: 2rem;
        }

        .retry-btn {
            background: #007aff;
            color: white;
            border: none;
            padding: 0.75rem 2rem;
            border-radius: 8px;
            font-size: 1rem;
            cursor: pointer;
            transition: background 0.2s;
        }

        .retry-btn:active {
            background: #0051d5;
        }

        .status {
            margin-top: 1rem;
            font-size: 0.875rem;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="offline-container">
        <div class="offline-icon">📡</div>
        <h1>Offline - Waiting for connection</h1>
        <p>Agent Deck is currently offline. Please check your network connection and try again.</p>
        <button class="retry-btn" onclick="location.reload()">Retry Connection</button>
        <div class="status" id="status">Checking connection...</div>
    </div>

    <script>
        // Auto-retry connection every 5 seconds
        let retryCount = 0;
        const maxRetries = 12; // 1 minute (5s * 12)

        function checkConnection() {
            retryCount++;
            const statusEl = document.getElementById('status');

            if (retryCount > maxRetries) {
                statusEl.textContent = 'Connection timeout. Please reload manually.';
                return;
            }

            statusEl.textContent = \`Checking connection... (attempt \${retryCount}/\${maxRetries})\`;

            fetch('/')
                .then((response) => {
                    if (response.ok) {
                        statusEl.textContent = 'Connection restored! Reloading...';
                        setTimeout(() => location.reload(), 1000);
                    } else {
                        setTimeout(checkConnection, 5000);
                    }
                })
                .catch(() => {
                    setTimeout(checkConnection, 5000);
                });
        }

        // Start checking after 5 seconds
        setTimeout(checkConnection, 5000);
    </script>
</body>
</html>
  `.trim();
}

// Message handler for client communication
self.addEventListener('message', (event) => {
  console.log('[Service Worker] Received message:', event.data);

  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }

  if (event.data && event.data.type === 'GET_VERSION') {
    event.ports[0].postMessage({
      version: CACHE_VERSION
    });
  }

  if (event.data && event.data.type === 'CLEAR_CACHE') {
    caches.delete(CACHE_NAME)
      .then(() => {
        console.log('[Service Worker] Cache cleared');
        event.ports[0].postMessage({ success: true });
      })
      .catch((error) => {
        console.error('[Service Worker] Failed to clear cache:', error);
        event.ports[0].postMessage({ success: false, error });
      });
  }
});

console.log('[Service Worker] Service worker script loaded', CACHE_VERSION);
