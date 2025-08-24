output "timestream_database_arn" {
  description = "ARN do banco de dados Timestream"
  value       = aws_timestreamwrite_database.this.arn
}

output "timestream_table_arn" {
  description = "ARN da tabela Timestream"
  value       = aws_timestreamwrite_table.this.arn
}