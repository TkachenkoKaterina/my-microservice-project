variable "bucket_name" {
  description = "Имя S3 бакета для хранения стейтов"
  type        = string
}

variable "table_name" {
  description = "Имя DynamoDB таблицы для блокировок"
  type        = string
}

variable "region" {
  description = "Регион AWS"
  type        = string
  default     = "us-west-2"
}
