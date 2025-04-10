variable "region" {
  default = "us-east-1"
}

variable "lambda_zip_path" {
  description = "Path to the zipped Lambda function code"
  default     = "function.zip"  # Placeholder, change this when the file is ready
}
