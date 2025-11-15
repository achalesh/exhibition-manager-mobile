// Minimal service worker - cache shell on install
const CACHE_NAME = 'exhibitmgr-shell-v1';
const OFFLINE_URL = '/offline.html';
self.addEventListener('install', event => {
event.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(['/','/index.html', '/manifest.json'])));
self.skipWaiting();
});
self.addEventListener('fetch', event => {
if (event.request.method !== 'GET') return;
event.respondWith(caches.match(event.request).then(r => r || fetch(event.request)));
});