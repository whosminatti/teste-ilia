output "athena_database_name" {
  description = "Nome do database Athena"
  value       = aws_glue_catalog_database.athena_db.name
}

output "athena_table_name" {
  description = "Nome da tabela Athena"
  value       = aws_glue_catalog_table.athena_table.name
}

output "athena_s3_bucket" {
  description = "Bucket S3 para dados Athena"
  value       = aws_s3_bucket.athena_data.bucket
}