import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import prisma from '../../db/prisma.js';

const LoginSchema = z.object({
  username: z.string().min(1),
  password: z.string().min(1),
});

export async function authRoutes(fastify: FastifyInstance) {
  // In-memory brute-force protection: max 10 failed logins per username+IP
  // per 15-minute window, then HTTP 429 (no extra dependency needed)
  const loginAttempts = new Map<string, { count: number; resetAt: number }>();
  const LOGIN_WINDOW_MS = 15 * 60 * 1000;
  const LOGIN_MAX_ATTEMPTS = 10;

  function isRateLimited(key: string): boolean {
    const now = Date.now();
    const entry = loginAttempts.get(key);
    if (!entry || entry.resetAt < now) {
      loginAttempts.set(key, { count: 1, resetAt: now + LOGIN_WINDOW_MS });
      return false;
    }
    entry.count += 1;
    return entry.count > LOGIN_MAX_ATTEMPTS;
  }

  fastify.post('/login', async (request: FastifyRequest, reply: FastifyReply) => {
    const parse = LoginSchema.safeParse(request.body);
    if (!parse.success) {
      return reply.status(400).send({ error: 'Invalid username or password' });
    }

    const rateKey = `${request.ip || 'unknown'}:${parse.data.username}`;
    if (isRateLimited(rateKey)) {
      return reply
        .status(429)
        .send({ error: 'Too many login attempts. Try again in 15 minutes.' });
    }

    const { username, password } = parse.data;
    const user = await prisma.user.findUnique({
      where: { username }
    });

    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      return reply.status(401).send({ error: 'Invalid credentials' });
    }

    loginAttempts.delete(rateKey);

    const token = fastify.jwt.sign(
      {
        id: user.id,
        username: user.username,
        role: user.role
      },
      { expiresIn: '8h' } // tokens must expire (spec: tokens expire in 8h)
    );

    reply.setCookie('access_token', token, {
      path: '/',
      httpOnly: true,
      secure: false, // development / internal
      sameSite: 'lax',
      maxAge: 8 * 60 * 60 // match JWT lifetime
    });

    // Record audit log
    await prisma.auditLog.create({
      data: {
        userId: user.id,
        username: user.username,
        action: 'login',
        entity: 'auth'
      }
    });

    return reply.send({
      id: user.id,
      username: user.username,
      role: user.role,
      email: user.email
    });
  });

  fastify.post('/logout', async (request: FastifyRequest, reply: FastifyReply) => {
    reply.clearCookie('access_token', { path: '/' });
    return reply.send({ success: true });
  });

  fastify.get('/me', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      const decoded = await request.jwtVerify() as { id: string; username: string; role: string };
      const user = await prisma.user.findUnique({
        where: { id: decoded.id },
        select: { id: true, username: true, role: true, email: true }
      });
      if (!user) return reply.status(401).send({ error: 'User not found' });
      return reply.send(user);
    } catch (e) {
      return reply.status(401).send({ error: 'Not authenticated' });
    }
  });
}
