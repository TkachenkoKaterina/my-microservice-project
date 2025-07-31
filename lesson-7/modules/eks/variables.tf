variable "cluster_name" {
  description = "Назва EKS кластера"
  type        = string
}

variable "subnet_ids" {
  description = "Список приватних підмереж"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID VPC"
  type        = string
}

variable "node_group_size" {
  description = "Кількість воркерів у кластері"
  type        = number
  default     = 2
}
