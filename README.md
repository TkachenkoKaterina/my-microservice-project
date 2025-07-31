<a id="top"></a>

# Розгортання Django-застосунку в Kubernetes на AWS

Цей проєкт налаштовує кластер Kubernetes (EKS) у вже створеній мережі (VPC) за допомогою Terraform, створює репозиторій Elastic Container Registry (ECR) для зберігання образів Docker і розгортає Django-застосунок за допомогою Helm-чарту з конфігурацією сервісу, autoscaling (HPA) та ConfigMap для змінних середовища.

<a href="#1"><img src="https://img.shields.io/badge/Структура проекту-512BD4?style=for-the-badge"/></a> <a href="#2"><img src="https://img.shields.io/badge/Пояснення модулів-ECD53F?style=for-the-badge"/></a> <a href="#3"><img src="https://img.shields.io/badge/Як розгорнути-007054?style=for-the-badge"/></a>

<a id="1"></a>

<img src="https://img.shields.io/badge/1. Структура проекту-512BD4?style=for-the-badge"/>

```
lesson-7/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               # Загальні виводи ресурсів
│
├── modules/                 # Каталог з усіма модулями
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf            # Створення S3-бакета
│   │   ├── dynamodb.tf      # Створення DynamoDB
│   │   ├── variables.tf     # Змінні для S3
│   │   └── outputs.tf       # Виведення інформації про S3 та DynamoDB
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf           # Створення VPC, підмереж, Internet Gateway
│   │   ├── routes.tf        # Налаштування маршрутизації
│   │   ├── variables.tf     # Змінні для VPC
│   │   └── outputs.tf       # Виведення інформації про VPC
│   │
│   ├── ecr/                 # Модуль для ECR
│   │   ├── ecr.tf           # Створення ECR репозиторію
│   │   ├── variables.tf     # Змінні для ECR
│   │   └── outputs.tf       # Виведення URL репозиторію
│   │
│   ├── eks/                 # Модуль для Kubernetes кластера
│   │   ├── eks.tf           # Створення EKS кластера та вузлів
│   │   ├── variables.tf     # Змінні для EKS
│   │   └── outputs.tf       # Виведення інформації про кластер
│
├── charts/
│   └── django-app/          # Helm-чарт для Django
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       ├── Chart.yaml
│       └── values.yaml
│
└── README.md                # Документація проєкту
```

[Top :arrow_double_up:](#top)

<a id="2"></a>

<img src="https://img.shields.io/badge/2. Пояснення модулів-ECD53F?style=for-the-badge"/>

### Модуль `s3-backend`

- **S3-бакет:** для зберігання стейт-файлів Terraform (версіонування + шифрування AES256).
- **DynamoDB:** для блокування стану (щоб уникнути конфліктів при одночасному застосуванні змін).

### Модуль `vpc`

- **VPC:** мережа 10.0.0.0/16 із трьома публічними та трьома приватними підмережами.
- **Internet Gateway:** для публічних підмереж.
- **NAT Gateway:** для вихідного доступу приватних підмереж.
- **Маршрутні таблиці:** публічні — через IGW, приватні — через NAT.

### Модуль `ecr`

- **Репозиторій ECR:** з автоматичним скануванням образів.
- **Політика доступу:** дозволяє push/pull для облікового запису AWS.

### Модуль `eks`

- **EKS кластер:** створює кластер Kubernetes із вузлами EC2 у приватних підмережах.
- **IAM ролі:** для взаємодії вузлів із ресурсами AWS.

### Helm-чарт `django-app`

- **Deployment:** деплой Django-контейнера з ECR.
- **Service:** типу LoadBalancer для доступу ззовні.
- **HPA:** автоскейлінг від 2 до 6 реплік при навантаженні > 70% CPU.
- **ConfigMap:** зберігає змінні середовища (DEBUG, SECRET_KEY, ALLOWED_HOSTS).

**Приклад `values.yaml`:**

```yaml
image:
  repository: 847362591482.dkr.ecr.eu-central-1.amazonaws.com/django-app
  tag: "latest"
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer
  port: 80

hpa:
  enabled: true
  minReplicas: 2
  maxReplicas: 6
  targetCPUUtilizationPercentage: 70

env:
  DEBUG: "False"
  SECRET_KEY: "my-very-strong-secret-key"
  ALLOWED_HOSTS: "*"
```

[Top :arrow_double_up:](#top)

<a id="3"></a>

<img src="https://img.shields.io/badge/3. Як розгорнути-007054?style=for-the-badge"/>

### 1. Перейдіть у каталог проєкту

```bash
cd lesson-7
```

### 2. Ініціалізуйте Terraform

```bash
terraform init
```

### 3. Перевірте план змін

```bash
terraform plan
```

### 4. Застосуйте зміни

```bash
terraform apply
```

Введіть `yes`, щоб підтвердити створення ресурсів.

### 5. Налаштуйте доступ до кластера

```bash
aws eks update-kubeconfig --name lesson-7-eks --region eu-central-1
```

### 6. Зберіть і завантажте образ Django в ECR

```bash
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 847362591482.dkr.ecr.eu-central-1.amazonaws.com
docker build -t django-app .
docker tag django-app:latest 847362591482.dkr.ecr.eu-central-1.amazonaws.com/django-app:latest
docker push 847362591482.dkr.ecr.eu-central-1.amazonaws.com/django-app:latest
```

### 7. Деплой Django у кластер через Helm

```bash
helm install django-app ./charts/django-app
```

### 8. Перевірте стан

```bash
kubectl get pods
kubectl get svc
```

### 9. Видалення інфраструктури (за потреби)

```bash
terraform destroy
```

[Top :arrow_double_up:](#top)
