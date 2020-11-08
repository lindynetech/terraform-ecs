terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.13.0"
    }
  }
}

provider aws {}

terraform {
  backend "s3" {
    bucket = "lindyne-tfbackends"
    key    = "ecr.tfstate"
    region = "us-east-1"
  }
}