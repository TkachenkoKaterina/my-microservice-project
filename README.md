# my-microservice-project

## Мій власний мікросервісний проєкт - CI/CD з Jenkins + Helm + Terraform + Argo CD

Це репозиторій для навчального проєкту в межах курсу "DevOps CI/CD".

Проєкт показує повний шлях: збірка Docker-образу Django → пуш в ECR → оновлення Helm values → автосинхронізація в кластері через Argo CD.

## Компоненти

- **Terraform**: модулі для S3/DynamoDB бекенду, VPC, ECR, EKS, Jenkins (через Helm), Argo CD (через Helm).
- **Jenkinsfile**: pipeline з Kaniko (build/push), автозаміна тега в `charts/django-app/values.yaml`, пуш у main.
- **Helm**: чарт `charts/django-app` (Deployment, Service, HPA, ConfigMap).
- **Argo CD**: app-of-apps, що слідкує за Helm-чартом у цьому ж репо.

## Передумови

- Region: `eu-central-1`
- AWS Account ID: `8715-4293-0117`
- ECR: `871542930117.dkr.ecr.eu-central-1.amazonaws.com/django-app`
- Kubernetes: EKS через Terraform
- Jenkins: встановлюється Helm Release в namespace `ci`
- Argo CD: встановлюється Helm Release в namespace `argocd`

## Як користуватись (навчально)

1. Клонувати репо.
2. Переглянути `Jenkinsfile` — він покаже етапи pipeline.
3. `charts/django-app/values.yaml` — тут тег образу оновлюється pipeline’ом.
4. Argo CD app-of-apps в `modules/argo_cd/charts/apps` “нібито” синхронізує чарт.
