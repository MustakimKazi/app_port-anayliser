import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import prisma from '../../db/prisma.js';

const CustomFieldCreateSchema = z.object({
  entityType: z.enum(['port', 'route', 'backend', 'server']),
  name: z.string().min(1),
  key: z.string().min(1),
  fieldType: z.enum(['text', 'number', 'select', 'multi-select', 'boolean', 'date', 'url']),
  options: z.array(z.string()).optional(),
  required: z.boolean().default(false),
  defaultValue: z.string().optional()
});

export async function customFieldsRoutes(fastify: FastifyInstance) {
  // GET /api/custom-fields - List all registered custom fields
  fastify.get('/custom-fields', async (request: FastifyRequest, reply: FastifyReply) => {
    const fields = await prisma.customField.findMany({
      orderBy: { createdAt: 'asc' }
    });
    return reply.send(fields);
  });

  // POST /api/custom-fields - Add new custom field
  fastify.post('/custom-fields', async (request: FastifyRequest, reply: FastifyReply) => {
    const parse = CustomFieldCreateSchema.safeParse(request.body);
    if (!parse.success) return reply.status(400).send({ error: parse.error });

    const data = parse.data;

    const existing = await prisma.customField.findUnique({
      where: { key: data.key }
    });
    if (existing) {
      return reply.status(409).send({ error: `Field key '${data.key}' already exists` });
    }

    const created = await prisma.customField.create({
      data: {
        entityType: data.entityType,
        name: data.name,
        key: data.key,
        fieldType: data.fieldType,
        options: data.options || [],
        required: data.required,
        defaultValue: data.defaultValue || null
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'create',
        entity: 'custom_field',
        entityId: created.id,
        afterState: created
      }
    });

    return reply.status(201).send(created);
  });

  // PATCH /api/custom-fields/:id
  fastify.patch('/custom-fields/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const body = request.body as any;

    const existing = await prisma.customField.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Custom field not found' });

    const updated = await prisma.customField.update({
      where: { id },
      data: {
        name: body.name !== undefined ? body.name : existing.name,
        options: body.options !== undefined ? body.options : existing.options,
        required: body.required !== undefined ? body.required : existing.required,
        defaultValue: body.defaultValue !== undefined ? body.defaultValue : existing.defaultValue
      }
    });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'update',
        entity: 'custom_field',
        entityId: id,
        beforeState: existing,
        afterState: updated
      }
    });

    return reply.send(updated);
  });

  // DELETE /api/custom-fields/:id
  fastify.delete('/custom-fields/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    const { id } = request.params;
    const existing = await prisma.customField.findUnique({ where: { id } });
    if (!existing) return reply.status(404).send({ error: 'Custom field not found' });

    await prisma.customField.delete({ where: { id } });

    await prisma.auditLog.create({
      data: {
        username: (request as any).user?.username || 'admin',
        action: 'delete',
        entity: 'custom_field',
        entityId: id,
        beforeState: existing
      }
    });

    return reply.send({ success: true });
  });
}
