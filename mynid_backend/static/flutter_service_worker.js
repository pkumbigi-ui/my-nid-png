'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "e767c00b8f5cfae5a3b898151f93ce0b",
"assets/AssetManifest.bin.json": "4b1860e5982f279a4d9435c3d94bc8ff",
"assets/AssetManifest.json": "571809104bfa8e7a2011d1dd4b00414e",
"assets/assets/images/2019%2520PNGCIR%2520REPORT.png": "6407c70fafe06c15fb2deeb0f92443cd",
"assets/assets/images/admin_bg.png": "c2061aa2d3635d1813aa95a66ba4acdb",
"assets/assets/images/admin_bg2.png": "ee7f7ea5dd9fc7bfa2f1a7b571937089",
"assets/assets/images/admin_bg3.png": "5978448afe1fc8e1df22d24cfcfff652",
"assets/assets/images/coastal_areas.png": "a71d87dc3ea1bb06b9f4ed59396fcb4f",
"assets/assets/images/happy_user.png": "d535907a46d0218015b709ac7495c969",
"assets/assets/images/highlands_area.png": "b8d530b6fdfbeef49168070520ebb702",
"assets/assets/images/mynid_bg.png": "11c9f2d0fbeeb8b2d7fea9e067192a51",
"assets/assets/images/national_emblem.png": "f8ef9fdfa73aeb1689191e8e0748ef59",
"assets/assets/images/news_postcourier1.png": "13d6e785e83b4ea3a84f6e994bbef05d",
"assets/assets/images/news_postcourier2.png": "bda4106d4d1a771d2a3bcc5f9915b1d4",
"assets/assets/images/news_postcourier3.png": "2bdaeefa831eb0ce38b6a1b72a8ccd17",
"assets/assets/images/news_postcourier4.png": "9db6c99cddc4dcdc3bfde4063815d11d",
"assets/assets/images/news_postcourier5.png": "05985d0eac81f14378215b57e72ee19d",
"assets/assets/images/NID%2520PROJECT%2520Rollout.png": "c7a42833a4eb4b45afdb498f7e1925c8",
"assets/assets/images/nid_card_sample.png": "c2061aa2d3635d1813aa95a66ba4acdb",
"assets/assets/images/nid_logo.png": "5fd3c5d4009103a8b913f13e1adc7559",
"assets/assets/images/nid_office.png": "8a5876c3871fdc75ab944c3e94f3699e",
"assets/assets/images/Our%2520Vision%2520for%2520the%2520Project.png": "cb5d8f0ed91d1d72fccef815dc959993",
"assets/assets/images/Partnership%2520for%2520Rollout%2520in%2520Private%2520Sector.png": "ea2622f48cfd776b0f5109ea12846406",
"assets/assets/images/png_map.png": "4b966b01fa0f2cd485fcb5a79cd115b2",
"assets/assets/images/png_map2.png": "f8a47417d8f553bef837a9edd82d09a6",
"assets/assets/images/welcome_bg.png": "3afc4c06b5040b27a9bfc03866d9e2f9",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "0bcb4fd44d6eb8028bbfe7266d38cbcd",
"assets/NOTICES": "0384d8ae364f548a45b68b17a48927d1",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "0cd37a8360cd74a0645e00740a624c0f",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "b8a3348e03a22b66749af7ac94aa5684",
"icons/Icon-192.png": "2471effff73325a7dd6078dd1ddb6e2f",
"icons/Icon-512.png": "c332e3574c1c5e4741bc6aa96804d983",
"icons/Icon-maskable-192.png": "2471effff73325a7dd6078dd1ddb6e2f",
"icons/Icon-maskable-512.png": "c332e3574c1c5e4741bc6aa96804d983",
"index.html": "0fa2dc9bd464651e3f2df94c53b808c8",
"/": "0fa2dc9bd464651e3f2df94c53b808c8",
"main.dart.js": "2422b80876c4d3f310e2da0e68f05686",
"manifest.json": "ef2db001ae9d528de4680347cb1cd3ad",
"version.json": "2f3066f8d88922bbb2aea9c13194bd55"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
