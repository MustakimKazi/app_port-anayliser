FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
COPY apps/api/package*.json ./apps/api/
RUN npm install
COPY apps/api ./apps/api
COPY scripts ./scripts
COPY nginx_documentation.xlsx ./
RUN cd apps/api && npx prisma generate && npm run build

FROM node:20-alpine
WORKDIR /app
RUN apk add --no-cache iproute2 net-tools
ENV NODE_ENV=production
COPY package*.json ./
COPY apps/api/package*.json ./apps/api/
RUN npm install --omit=dev
COPY --from=builder /app/apps/api/dist ./apps/api/dist
COPY --from=builder /app/apps/api/prisma ./apps/api/prisma
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/scripts ./scripts
COPY nginx_documentation.xlsx ./

EXPOSE 3100
CMD ["node", "apps/api/dist/server.js"]
