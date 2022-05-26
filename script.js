async function handleRequest(request) {
  const { pathname } = new URL(request.url);
  return new Response(`Welcome to the ${pathname} path`);
}

addEventListener("fetch", (event) => {
  return event.respondWith(handleRequest(event.request));
});
