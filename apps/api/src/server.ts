import { buildApp } from './app.js';
import { config } from './config/env.js';

async function start() {
  const { app, scanner } = buildApp();

  try {
    const address = await app.listen({
      port: config.port,
      host: config.host
    });
    console.log(`🚀 PortWatch API server listening at ${address}`);
    console.log(`📖 Swagger API documentation available at ${address}/api/docs`);

    // Start background scanner
    scanner.start();

    // Graceful shutdown
    const signals: NodeJS.Signals[] = ['SIGINT', 'SIGTERM'];
    for (const signal of signals) {
      process.on(signal, async () => {
        console.log(`\nReceived ${signal}, gracefully shutting down PortWatch API...`);
        scanner.stop();
        await app.close();
        process.exit(0);
      });
    }
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

start();
