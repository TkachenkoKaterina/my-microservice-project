<a id="top"></a>

# Інфраструктура AWS за допомогою Terraform

Цей проєкт налаштовує основну інфраструктуру AWS за допомогою Terraform, включаючи **S3** та **DynamoDB** для керування станом, **Virtual Private Cloud (VPC)** з публічними та приватними підмережами, а також **Elastic Container Registry (ECR)** для образів Docker.

<a href="#1"><img src="https://img.shields.io/badge/Структура проекту-512BD4?style=for-the-badge"/></a> <a href="#2"><img src="https://img.shields.io/badge/Пояснення модулів-ECD53F?style=for-the-badge"/></a> <a href="#3"><img src="https://img.shields.io/badge/Як розгорнути-007054?style=for-the-badge"/></a>

---

<a id="1"></a>

<img src="https://img.shields.io/badge/1. Структура проекту-512BD4?style=for-the-badge"/>

```
lesson-5/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               # Загальне виведення ресурсів
│
├── modules/                 # Каталог з усіма модулями
│   │
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf            # Створення S3-бакету
│   │   ├── dynamodb.tf      # Створення DynamoDB
│   │   ├── variables.tf     # Змінні для S3
│   │   └── outputs.tf       # Виведення інформації про S3 та DynamoDB
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf           # Створення VPC, підмереж, Internet Gateway, NAT Gateway
│   │   ├── routes.tf        # Налаштування маршрутизації
│   │   ├── variables.tf     # Змінні для VPC
│   │   └── outputs.tf       # Виведення інформації про VPC
│   │
│   └── ecr/                 # Модуль для ECR
│       ├── ecr.tf           # Створення ECR репозиторію
│       ├── variables.tf     # Змінні для ECR
│       └── outputs.tf       # Виведення URL репозиторію ECR
│
└── README.md                # Документація проєкту
```

[Top :arrow_double_up:](#top)

---

<a id="2"></a>

<img src="https://img.shields.io/badge/2. Пояснення модулів-ECD53F?style=for-the-badge"/>

### **Модуль `s3-backend`**

Налаштовує бекенд для Terraform:

- **S3-бакет** — для зберігання стану (`terraform.tfstate`), з увімкненим версіонуванням і шифруванням (AES-256).
- **DynamoDB** — таблиця для блокування стану (щоб уникнути одночасних змін від різних користувачів).

**Приклад виведених значень після застосування:**

```
s3_bucket_name: my-bucket
dynamodb_table_name: terraform-locks
```

---

### **Модуль `vpc`**

Створює мережеву інфраструктуру:

- **VPC** — 10.0.0.0/16
- **3 публічні підмережі** — для веб-сервісів.
- **3 приватні підмережі** — для баз даних та бекендів.
- **Internet Gateway** — доступ в інтернет із публічних підмереж.
- **NAT Gateways** — доступ із приватних підмереж назовні.
- **Route Tables** — маршрутизація для публічних і приватних сегментів.

**Приклад виведених значень:**

```
vpc_id: vpc-0f123abc456de7890
public_subnet_ids: [subnet-0a12345b6c7de8901, subnet-0b23456c7d8ef9012, subnet-0c34567d8e9fa0123]
private_subnet_ids: [subnet-0d45678e9f0ab1234, subnet-0e56789f0a1bc2345, subnet-0f67890a1b2cd3456]
```

---

### **Модуль `ecr`**

Налаштовує репозиторій Docker образів:

- **ECR репозиторій** — для зберігання контейнерів.
- **Сканування образів** — автоматична перевірка на вразливості.

**Приклад виведених значень:**

```
ecr_repository_url: 123456789012.dkr.ecr.eu-central-1.amazonaws.com/lesson-5-ecr
```

[Top :arrow_double_up:](#top)

---

<a id="3"></a>

<img src="https://img.shields.io/badge/3. Як розгорнути-007054?style=for-the-badge"/>

<a><img src="https://img.shields.io/badge/1-18AEFF?style=for-the-badge"/></a> **Перейдіть до каталогу:**

```bash
cd lesson-5
```

<a><img src="https://img.shields.io/badge/2-18AAAA?style=for-the-badge"/></a> **Ініціалізуйте Terraform:**

```bash
terraform init
```

<a><img src="https://img.shields.io/badge/3-18A222?style=for-the-badge"/></a> **Сплануйте розгортання:**

```bash
terraform plan
```

<a><img src="https://img.shields.io/badge/4-18D222?style=for-the-badge"/></a> **Застосуйте зміни:**

```bash
terraform apply
```

**Приклад результату:**

```
Apply complete! Resources: 31 added, 0 changed, 0 destroyed.

Outputs:
s3_bucket_name       = "my-bucket"
dynamodb_table_name  = "terraform-locks"
vpc_id               = "vpc-0f123abc456de7890"
public_subnet_ids    = ["subnet-0a12345b6c7de8901", "subnet-0b23456c7d8ef9012", "subnet-0c34567d8e9fa0123"]
private_subnet_ids   = ["subnet-0d45678e9f0ab1234", "subnet-0e56789f0a1bc2345", "subnet-0f67890a1b2cd3456"]
ecr_repository_url   = "123456789012.dkr.ecr.eu-central-1.amazonaws.com/lesson-5-ecr"
```

<a><img src="https://img.shields.io/badge/5-A9225C?style=for-the-badge"/></a> **Знищення інфраструктури (за потреби):**

```bash
terraform destroy
```

[Top :arrow_double_up:](#top)
