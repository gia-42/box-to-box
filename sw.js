// Box to Box service worker: makes the game installable and playable offline.
// Change VERSION whenever you upload new files so every player gets them.
const VERSION = "b2b-v8";
const SHELL = [
  "./", "./index.html", "./config.js", "./privacy.html", "./manifest.webmanifest",
  "./data/wmap.js", "./icons/icon-192.png", "./icons/icon-512.png", "./icons/apple-touch-icon.png"
];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(VERSION).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});
self.addEventListener("activate", e => {
  e.waitUntil(caches.keys()
    .then(keys => Promise.all(keys.filter(k => k !== VERSION && k !== "b2b-photos").map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});
self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  // Never cache account or database traffic, or Google's sign-in.
  if (url.hostname.endsWith("supabase.co") || url.hostname === "accounts.google.com") return;

  // VAR photos never change: keep them once downloaded.
  if (url.origin === location.origin && url.pathname.includes("/img/")) {
    e.respondWith(caches.open("b2b-photos").then(c => c.match(req).then(hit => hit || fetch(req).then(res => { if (res.ok) c.put(req, res.clone()); return res; }))));
    return;
  }
  // The game's own files: network first so updates arrive, cache when offline.
  if (url.origin === location.origin) {
    e.respondWith(
      fetch(req.mode === "navigate" ? req.url : req, { cache: "no-cache" })
        .then(res => { if (res.ok) { const copy = res.clone(); caches.open(VERSION).then(c => c.put(req, copy)); } return res; })
        .catch(() => caches.match(req, { ignoreSearch: true }).then(r => r || caches.match("./index.html")))
    );
    return;
  }
  // Fonts and the login library: serve from cache, refresh in the background.
  if (/fonts\.(googleapis|gstatic)\.com$/.test(url.hostname) || url.hostname === "cdn.jsdelivr.net") {
    e.respondWith(caches.open(VERSION).then(c => c.match(req).then(hit => {
      const net = fetch(req).then(res => { if (res.ok || res.type === "opaque") c.put(req, res.clone()); return res; }).catch(() => hit);
      return hit || net;
    })));
  }
});
