// PM2 process definitions for PortWatch (replaces the former docker-compose stack).
// Usage:
//   pm2 start ecosystem.config.cjs      # start API + web
//   pm2 save                            # persist process list
//   pm2 startup                         # enable boot persistence (systemd user unit)
module.exports = {
  apps: [
    {
      name: 'portwatch-api',
      script: './apps/api/dist/server.js',
      cwd: __dirname,
      instances: 1,
      autorestart: true,
      max_memory_restart: '512M',
      kill_timeout: 5000,
      env: {
        NODE_ENV: 'production',
        PORT: 3100,
        HOST: '0.0.0.0'
      }
    },
    {
      name: 'portwatch-web',
      script: 'npm',
      args: 'run preview --workspace=@portwatch/web',
      cwd: __dirname,
      instances: 1,
      autorestart: true,
      max_memory_restart: '300M',
      env: {
        NODE_ENV: 'production'
      }
    }
  ]
};
