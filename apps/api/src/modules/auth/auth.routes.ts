import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import prisma from '../../db/prisma.js';

const LoginSchema = z.object({
  username: z.string().min(1),
  password: z.string().min(1),
});

export async function authRoutes(fastify: FastifyInstance) {
  fastify.post('/login', async (request: FastifyRequest, reply: FastifyReply) => {
    const parse = LoginSchema.safeParse(request.body);
    if (!parse.success) {
      return reply.status(400).send({ error: 'Invalid username or password' });
    }

    const { username, password } = parse.data;
    const user = await prisma.user.findUnique({
      where: { username }
    });

    if (!user || !bcrypt.compareSync(password, user.passwordHash)) {
      return reply.status(401).send({ error: 'Invalid credentials' });
    }

    const token = fastify.jwt.sign({
      id: user.id,
      username: user.username,
      role: user.role
    });

    reply.setCookie('access_token', token, {
      path: '/',
      httpOnly: true,
      secure: false, // development / internal
      sameSite: 'lax',
      maxAge: 86400 * 7 // 7 days
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
