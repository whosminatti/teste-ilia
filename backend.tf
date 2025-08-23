terraform {
  backend "s3" {
    bucket         = "teste-ilia-deploy-k8s"
    key            = "teste-ilia.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}