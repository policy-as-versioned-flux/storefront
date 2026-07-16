# Ticket 07 (real-estate): a real, resolvable, deliberately old npm
# dependency tree (Angular 9, early 2020) -- this stage genuinely installs
# it, proving the tree is real and not just a fixture Renovate/the
# vulnerability scanner would never actually see resolve. The served
# content itself is a hand-written static page (no `ng build` -- the point
# of this app is the dependency staleness signal, not a compiled Angular
# bundle) so the deploy stays fast and small.
FROM node:18-alpine AS deps
WORKDIR /app
COPY package.json ./
RUN npm install --legacy-peer-deps --no-audit --no-fund

FROM nginx:1.27-alpine
COPY public/index.html /usr/share/nginx/html/index.html
# Prove the dependency tree actually resolved, for anyone inspecting the
# image -- not consumed at runtime, just evidence the deps stage was real.
COPY --from=deps /app/package.json /usr/share/nginx/html/_package.json
EXPOSE 80
