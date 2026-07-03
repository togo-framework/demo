# Deploying demo.to-go.dev

The demo is a single container (nginx serves the built dashboard + proxies the API
to the Go binary; SQLite embedded).

## Build + run (anywhere)
```bash
docker build -t ghcr.io/togo-framework/demo:latest .
docker run -d --name demo -p 80:80 -v demo_data:/data ghcr.io/togo-framework/demo:latest
```

## Go live at demo.to-go.dev (same box as to-go.dev — LXC 201)
1. **DNS:** add `demo.to-go.dev` → the to-go.dev edge (same target as the apex / `*.to-go.dev`).
2. **Run the container** on the box (via CI or `pct exec 201`):
   ```bash
   docker run -d --name demo --network npm_default --restart unless-stopped \
     -v demo_data:/data ghcr.io/togo-framework/demo:latest
   ```
3. **NPM proxy host:** `demo.to-go.dev` → forward to `demo:80` (websockets on, TLS via Let's Encrypt).

CI: a `deploy.yml` mirroring to-go.dev's can build + ship this image; it needs the
`DEPLOY_HOST` / `DEPLOY_SSH_KEY` secrets on this repo (currently only on to-go.dev).
