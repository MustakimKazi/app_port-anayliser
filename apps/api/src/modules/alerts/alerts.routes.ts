import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import prisma from '../../db/prisma.js';

export async function alertsRoutes(fastify: FastifyInstance) {
  // GET /api/alerts/rules
  fastify.get('/alerts/rules', async (request: FastifyRequest, reply: FastifyReply) => {
    const rules = await prisma.alertRule.findMany({
      orderBy: { createdAt: 'asc' }
    });
    return reply.send(rules);
  });

  // POST /api/alerts/rules
  fastify.post('/alerts/rules', async (request: FastifyRequest, reply: FastifyReply) => {
    const body = request.body as any;
    const rule = await prisma.alertRule.create({
      data: {
        name: body.name,
        eventType: body.eventType,
        threshold: body.threshold ? parseInt(body.threshold) : null,
        channels: body.channels || ['log'],
        isEnabled: body.isEnabled !== undefined ? body.isEnabled : true
      }
    });
    return reply.status(201).send(rule);
  });

  // PATCH /api/alerts/rules/:id
  fastify.patch('/alerts/rules/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const body = request.body as any;
    const updated = await prisma.alertRule.update({
      where: { id },
      data: {
        name: body.name,
        threshold: body.threshold !== undefined ? parseInt(body.threshold) : undefined,
        channels: body.channels,
        isEnabled: body.isEnabled
      }
    });
    return reply.send(updated);
  });

  // DELETE /api/alerts/rules/:id
  fastify.delete('/alerts/rules/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    await prisma.alertRule.delete({ where: { id } });
    return reply.send({ success: true });
  });

  // POST /api/alerts/test - Simulate and trigger test notification across channels
  fastify.post('/alerts/test', async (request: FastifyRequest, reply: FastifyReply) => {
    const { channel = 'webhook', recipient } = request.body as any;

    const log = await prisma.alertLog.create({
      data: {
        title: 'PortWatch Test Notification',
        message: `This is a test notification from PortWatch server to channel: ${channel}. Everything is operational!`,
        channel,
        status: 'simulated'
      }
    });

    return reply.send({
      success: true,
      message: `Test alert dispatched successfully to ${channel}`,
      log
    });
  });

  // GET /api/alerts/logs
  fastify.get('/alerts/logs', async (request: FastifyRequest, reply: FastifyReply) => {
    const logs = await prisma.alertLog.findMany({
      orderBy: { sentAt: 'desc' },
      take: 50,
      include: { rule: true }
    });
    return reply.send(logs);
  });

  // GET & PATCH /api/settings
  fastify.get('/settings', async (request: FastifyRequest, reply: FastifyReply) => {
    const setting = await prisma.setting.findUnique({
      where: { id: 'global' }
    });
    return reply.send(setting);
  });

  fastify.patch('/settings', async (request: FastifyRequest, reply: FastifyReply) => {
    const body = request.body as any;
    const updated = await prisma.setting.upsert({
      where: { id: 'global' },
      update: {
        scanIntervalSec: body.scanIntervalSec !== undefined ? parseInt(body.scanIntervalSec) : undefined,
        tcpTimeoutMs: body.tcpTimeoutMs !== undefined ? parseInt(body.tcpTimeoutMs) : undefined,
        slowThresholdMs: body.slowThresholdMs !== undefined ? parseInt(body.slowThresholdMs) : undefined,
        concurrencyLimit: body.concurrencyLimit !== undefined ? parseInt(body.concurrencyLimit) : undefined,
        retentionDays: body.retentionDays !== undefined ? parseInt(body.retentionDays) : undefined,
        slackDiscordWebhook: body.slackDiscordWebhook !== undefined ? body.slackDiscordWebhook : undefined,
        genericWebhook: body.genericWebhook !== undefined ? body.genericWebhook : undefined,
        telegramConfig: body.telegramConfig !== undefined ? body.telegramConfig : undefined,
        smtpConfig: body.smtpConfig !== undefined ? body.smtpConfig : undefined
      },
      create: {
        id: 'global',
        scanIntervalSec: body.scanIntervalSec ? parseInt(body.scanIntervalSec) : 30,
        tcpTimeoutMs: body.tcpTimeoutMs ? parseInt(body.tcpTimeoutMs) : 3000,
        slowThresholdMs: body.slowThresholdMs ? parseInt(body.slowThresholdMs) : 1500,
        concurrencyLimit: body.concurrencyLimit ? parseInt(body.concurrencyLimit) : 20,
        retentionDays: body.retentionDays ? parseInt(body.retentionDays) : 90
      }
    });
    return reply.send(updated);
  });
}
  return clone;
}

  // GET & PATCH /api/settings
  fastify.get('/settings', async (request: FastifyRequest, reply: FastifyReply) => {
    const setting = await prisma.setting.findUnique({
      where: { id: 'global' }
    });
    return reply.send(maskSetting(setting));
  });

  fastify.patch('/settings', async (request: FastifyRequest, reply: FastifyReply) => {
    const body = request.body as any;
    const current = await prisma.setting.findUnique({ where: { id: 'global' } });

    let slackDiscordWebhook = undefined;
    if (body.slackDiscordWebhook !== undefined) {
      if (body.slackDiscordWebhook === null || body.slackDiscordWebhook === '') {
        slackDiscordWebhook = null;
      } else if (isMaskedValue(body.slackDiscordWebhook)) {
        slackDiscordWebhook = current?.slackDiscordWebhook || null;
      } else {
        slackDiscordWebhook = body.slackDiscordWebhook;
      }
    }

    let genericWebhook = undefined;
    if (body.genericWebhook !== undefined) {
      if (body.genericWebhook === null || body.genericWebhook === '') {
        genericWebhook = null;
      } else if (isMaskedValue(body.genericWebhook)) {
        genericWebhook = current?.genericWebhook || null;
      } else {
        genericWebhook = body.genericWebhook;
      }
    }

    let telegramConfig = undefined;
    if (body.telegramConfig !== undefined) {
      if (body.telegramConfig === null || body.telegramConfig === '') {
        telegramConfig = null;
      } else if (typeof body.telegramConfig === 'object') {
        const existingTg = (current?.telegramConfig as any) || {};
        const botToken = isMaskedValue(body.telegramConfig.botToken)
          ? existingTg.botToken
          : body.telegramConfig.botToken;
        telegramConfig = { ...body.telegramConfig, botToken };
      } else {
        telegramConfig = body.telegramConfig;
      }
    }

    let smtpConfig = undefined;
    if (body.smtpConfig !== undefined) {
      if (body.smtpConfig === null || body.smtpConfig === '') {
        smtpConfig = null;
      } else if (typeof body.smtpConfig === 'object') {
        const existingSmtp = (current?.smtpConfig as any) || {};
        const password = isMaskedValue(body.smtpConfig.password)
          ? existingSmtp.password
          : body.smtpConfig.password;
        smtpConfig = { ...body.smtpConfig, password };
      } else {
        smtpConfig = body.smtpConfig;
      }
    }

    const updated = await prisma.setting.upsert({
      where: { id: 'global' },
      update: {
        scanIntervalSec: body.scanIntervalSec !== undefined ? parseInt(body.scanIntervalSec) : undefined,
        tcpTimeoutMs: body.tcpTimeoutMs !== undefined ? parseInt(body.tcpTimeoutMs) : undefined,
        slowThresholdMs: body.slowThresholdMs !== undefined ? parseInt(body.slowThresholdMs) : undefined,
        concurrencyLimit: body.concurrencyLimit !== undefined ? parseInt(body.concurrencyLimit) : undefined,
        retentionDays: body.retentionDays !== undefined ? parseInt(body.retentionDays) : undefined,
        slackDiscordWebhook,
        genericWebhook,
        telegramConfig,
        smtpConfig
      },
      create: {
        id: 'global',
        scanIntervalSec: body.scanIntervalSec ? parseInt(body.scanIntervalSec) : 30,
        tcpTimeoutMs: body.tcpTimeoutMs ? parseInt(body.tcpTimeoutMs) : 3000,
        slowThresholdMs: body.slowThresholdMs ? parseInt(body.slowThresholdMs) : 1500,
        concurrencyLimit: body.concurrencyLimit ? parseInt(body.concurrencyLimit) : 20,
        retentionDays: body.retentionDays ? parseInt(body.retentionDays) : 90,
        slackDiscordWebhook: slackDiscordWebhook || null,
        genericWebhook: genericWebhook || null,
        telegramConfig: telegramConfig || null,
        smtpConfig: smtpConfig || null
      }
    });

    // Notify scanner to dynamically apply updated parameters (BUG-030)
    if (opts?.scanner) {
      await opts.scanner.reloadSettings().catch((err) => {
        request.log.error({ err }, 'Failed to reload scanner settings');
      });
    }

    return reply.send(maskSetting(updated));
  });
}
