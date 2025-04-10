resource "aws_lambda_function" "data_processor" {
  function_name = "data-processor"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec.arn

  filename      = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  depends_on = [aws_iam_role_policy_attachment.lambda_basic_execution]
}
