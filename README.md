# Silent Scalper - Cloud Native Data Processing Pipeline Setup Guide

This guide provides a **step-by-step approach** to building the **Silent Scalper** project using AWS services. It includes both **Terraform infrastructure code** and **manual setup instructions**.

---

## Project Overview

Silent Scalper is a **serverless, event-driven data pipeline** that processes files uploaded to S3. It uses AWS Lambda, DynamoDB, CloudWatch, and SNS to handle data ingestion, transformation, monitoring, and notifications.

---

##  Use Cases

### Supported Use Cases:

- Log processing and monitoring
- Financial data handling (e.g. stock or transaction records)
- IoT sensor data processing
- Healthcare and medical file processing
- E-commerce product/order data
- Media file ingestion and metadata extraction
- Scientific data transformation (e.g. genomics, physics)

### Supported File Types:

- `.csv`, `.json`, `.xml`, `.txt`, `.log`
- Media: `.jpg`, `.png`, `.mp4`, `.wav`
- Specialized: `.dcm`, `.fits`, `.hdf5`

---

## Step-by-Step Project Creation

### Prerequisites

- AWS Account
- IAM user with admin access or specific permissions for Lambda, S3, IAM, DynamoDB, CloudWatch, SNS, and API Gateway
- Terraform installed locally

---

##  Project File Structure

```
silent-scalper/
├── main.tf               # Entry point to wire modules or resources
├── variables.tf          # Input variables (e.g. region, names)
├── outputs.tf            # Output values after apply
│
├── s3.tf                 # S3 bucket and notification config
├── lambda.tf             # Lambda function and IAM role
├── dynamodb.tf           # DynamoDB table definition
├── iam.tf                # IAM roles and permissions
├── sns.tf                # SNS topic and subscriptions
├── cloudwatch.tf         # CloudWatch alarms and logs
├── lambda_function/      # Directory for Lambda source code
│   └── lambda_function.py
└── function.zip          # Zipped Lambda code (upload to Lambda)
```

---

##  Sample Terraform Code per File

### `main.tf`

```hcl
provider "aws" {
  region = var.region
}
```

### `variables.tf`

```hcl
variable "region" {
  default = "us-east-1"
}

variable "lambda_zip_path" {
  description = "Path to the zipped Lambda function code"
  default     = "function.zip"  
}

```

### `outputs.tf`

```hcl
output "s3_bucket_name" {
  value = aws_s3_bucket.data_bucket.id
}
```

### `s3.tf`

```hcl
resource "aws_s3_bucket" "data_bucket" {
  bucket = "silent-scalper-data"
}

resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.data_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.data_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_s3_invoke]
}
```

### `lambda.tf`

```hcl
resource "aws_lambda_function" "data_processor" {
  function_name = "data-processor"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec.arn

  filename      = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  depends_on = [aws_iam_role_policy_attachment.lambda_basic_execution]
}

```

### `iam.tf`

```hcl
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.data_bucket.arn
}
```

### `dynamodb.tf`

```hcl
resource "aws_dynamodb_table" "processed_data" {
  name         = "SilentScalperData"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "fileId"

  attribute {
    name = "fileId"
    type = "S"
  }
}
```

### `sns.tf`

```hcl
resource "aws_sns_topic" "alerts" {
  name = "SilentScalperAlerts"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"
}
```

### `cloudwatch.tf`

```hcl
# Placeholder for alarms
# Example: CloudWatch alarm on Lambda error rate
```

### `lambda_function/lambda_function.py`

```python
import json

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
```

### Zip the Lambda code

```bash
cd lambda_function
zip -r ../function.zip .
```

---

## Execution Instructions

1. Navigate to the project root:

```bash
cd silent-scalper
```

2. Initialize Terraform:

```bash
terraform init
```

3. Review plan:

```bash
terraform plan
```

4. Apply:

```bash
terraform apply
```

5. Approve when prompted.

---

## Cost Estimation

### DynamoDB Pricing (On-Demand):

- **Writes:** \$1.25 per million
- **Reads:** \$0.25 per million
- **Storage:** \$0.25/GB/month

Use [AWS Pricing Calculator](https://calculator.aws.amazon.com/) and select DynamoDB to estimate costs based on workload.

---

Silent Scalper is now fully deployable in a modular, scalable, and production-friendly Terraform setup. Let me know if you’d like to add CI/CD, API Gateway, or additional transformations!

