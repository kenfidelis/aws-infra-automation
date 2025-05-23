variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the RDS instance"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the RDS instance"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.small"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "database_name" {
  description = "Name of the database"
  type        = string
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
}

variable "master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

resource "aws_rds_cluster_parameter_group" "main" {
  name        = "${var.environment}-cluster-parameter-group"
  family      = "${var.engine}${replace(var.engine_version, "/\\.\\d+$/", "")}"
  description = "Parameter group for ${var.environment} RDS cluster"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_rds_cluster" "main" {
  cluster_identifier              = "${var.environment}-db-cluster"
  engine                          = var.engine
  engine_version                  = var.engine_version
  database_name                   = var.database_name
  master_username                 = var.master_username
  master_password                 = var.master_password
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [var.security_group_id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = "03:00-05:00"
  preferred_maintenance_window    = "sun:05:00-sun:07:00"
  skip_final_snapshot             = var.environment != "production"
  final_snapshot_identifier       = "${var.environment}-db-final-snapshot"
  deletion_protection             = var.environment == "production"
  storage_encrypted               = true

  tags = {
    Name        = "${var.environment}-db-cluster"
    Environment = var.environment
  }
}

resource "aws_rds_cluster_instance" "instances" {
  count                = var.multi_az ? 2 : 1
  identifier           = "${var.environment}-db-instance-${count.index + 1}"
  cluster_identifier   = aws_rds_cluster.main.id
  instance_class       = var.instance_class
  engine               = aws_rds_cluster.main.engine
  engine_version       = aws_rds_cluster.main.engine_version
  db_subnet_group_name = aws_db_subnet_group.main.name

  tags = {
    Name        = "${var.environment}-db-instance-${count.index + 1}"
    Environment = var.environment
  }
}

output "cluster_endpoint" {
  value = aws_rds_cluster.main.endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.main.reader_endpoint
}

output "database_name" {
  value = aws_rds_cluster.main.database_name
}