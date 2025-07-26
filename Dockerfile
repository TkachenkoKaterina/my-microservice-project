# Використовуємо офіційний Alpine-образ Python
FROM python:3.12-alpine

# Встановлюємо системні залежності (через apk)
RUN apk update && apk upgrade && \
    apk add --no-cache \
        gcc \
        musl-dev \
        libpq \
        postgresql-dev \
        python3-dev \
        zlib-dev \
        jpeg-dev \
        bash

# Додаємо робочу директорію
WORKDIR /app

# Копіюємо requirements і встановлюємо залежності Python
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Копіюємо увесь код
COPY . .

# Відкриваємо порт для Django
EXPOSE 8000

# Запускаємо сервер
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
