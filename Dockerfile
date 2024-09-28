FROM node:20-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM base AS build
WORKDIR /app
COPY .npmrc ./
COPY pnpm-lock.yaml ./
RUN pnpm fetch
COPY . /app
RUN pnpm install -r --offline --frozen-lockfile
RUN pnpm build

FROM base AS prod
WORKDIR /app
COPY .npmrc ./
COPY pnpm-lock.yaml ./
RUN pnpm fetch --prod
RUN pnpm install -r --offline --prod --frozen-lockfile
COPY nest-cli.json package.json pnpm-lock.yaml .npmrc ./
COPY --from=build /app/dist ./dist

EXPOSE 3000
CMD ["pnpm", "start:prod"]
