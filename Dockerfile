FROM python:3.12-alpine

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

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
