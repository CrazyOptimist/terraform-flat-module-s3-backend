# Terraform Flat Module POC with AWS S3 Backend

![image](https://user-images.githubusercontent.com/55074937/147535173-76bebe21-696e-4f4a-927c-0ff0c68d6bd6.png)
<p align="center"><b>Detailed architecture diagram showing the four distinct components that make up this module</b></p>

## Usage
Deploy your terraform backend infra securely to AWS S3 bucket

```terraform
provider "aws" {
  region = "us-west-2"
}

module "s3backend" {
  source = "git::github.com/crazyoptimist/terraform-flat-module-s3-backend"
  namespace = "crazy-team"
}

output "s3backend_cofig" {
  value = "module.s3backend.config"
}
```

After that, use the result infra as your terraform backend like so:

```terraform
terraform {
  backend "s3" {
    bucket = BUCKET_NAME
    key = SUB_FOLDER_NAME_YOU_LIKE
    region = BUCKET_REGION
    encrypt = true
    role_arn = ROLE_ARN
    dynamodb_table = TABLE_NAME
  }
  
  required_version = ">= 1.1.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70"
    }
  }
}
```

## Credits
All the contents used in the repo are from "Terraform in Action" by Winkler S.
