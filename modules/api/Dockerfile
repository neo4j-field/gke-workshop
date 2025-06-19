# 1) Build the frontend
FROM node:18-alpine AS ui-builder
WORKDIR /app/ui

# Copy only metadata first for caching
COPY ui/package.json ui/yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy the rest and build
COPY ui/ ./
RUN yarn build

# 2) Build the API and assemble the final image
FROM python:3.11-slim AS api

WORKDIR /app
ENV FLASK_ENV=production  FLASK_DEBUG=0

# Copy your pyproject for pip-based install
COPY pyproject.toml ./

# Copy application source
COPY app/ ./app/

# Install your package (PEP517 from pyproject) + Gunicorn
RUN pip install --upgrade pip setuptools wheel \
 && pip install . \
 && pip install gunicorn

# Copy in only the static UI artifacts
COPY --from=ui-builder /app/ui/dist ./ui/dist

CMD ["gunicorn", "app.main:app", "-b", "0.0.0.0:443", "--workers", "4", "--keyfile=/certs/tls.key", "--certfile=/certs/tls.crt", "--timeout", "0"]

