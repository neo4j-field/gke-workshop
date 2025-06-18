FROM python:3.11-slim

WORKDIR /app

# 1) Copy project metadata
COPY pyproject.toml ./

# 2) Copy your package code
COPY app/ ./app/

ENV FLASK_ENV=production
ENV FLASK_DEBUG=0

# 3) Install your package and its dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install . && \
    pip install gunicorn

EXPOSE 5000
CMD ["gunicorn", "main:app", "-b", "0.0.0.0:5000", "--workers", "4"]
