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
# The dependency tree's evidence -- package.json + the real generated
# lockfile -- lives outside the nginx docroot (not publicly served) but
# still in the shipped image: trivy's npm scanner reads the lockfile
# directly, no node_modules needed. Without this, the final image (nginx
# + one static HTML file) carries no npm manifest at all and the
# vulnerability scanner has nothing to see -- found live while verifying
# ticket 11, fixed here rather than left as a silent gap.
COPY --from=deps /app/package.json /app/package-lock.json /opt/app-deps/
EXPOSE 80
