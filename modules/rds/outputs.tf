output "rds_db_endpoint" {
    value = aws_db_instance.db_instance.endpoint
}