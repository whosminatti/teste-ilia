resource "aws_s3_bucket" "athena_data" {
  bucket = "${var.project_name}-athena-data"
  force_destroy = true
  tags = {
    Name = var.project_name
  }
}

resource "aws_s3_bucket_policy" "athena_data_policy" {
  bucket = aws_s3_bucket.athena_data.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::184488529047:role/eks-grafana-sa"
        }
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.athena_data.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.athena_data.bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_glue_catalog_database" "athena_db" {
  name = var.database_name
}

resource "aws_glue_catalog_table" "athena_table" {
  name          = var.table_name
  database_name = aws_glue_catalog_database.athena_db.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "parquet" # ou "json", "csv", etc
    "compressionType" = "none"
    "typeOfData" = "file"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.athena_data.bucket}/data/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "parquet"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "event_time"
      type = "timestamp"
    }
    columns {
      name = "device_id"
      type = "string"
    }
    columns {
      name = "temperature"
      type = "double"
    }
    # Adicione mais colunas conforme seu schema
  }
}