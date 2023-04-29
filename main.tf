# Define the provider
provider "aws" {
  region = "ap-south-1"
}

# Create the IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the basic Lambda execution policy to the role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Create the Lambda function
resource "aws_lambda_function" "dummy_data_api" {
  filename      = "dummy_data_api.zip"
  function_name = "dummy_data_api"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  timeout       = 10
  memory_size   = 128

  environment {
    variables = {
      NODE_ENV = "production"
    }
  }
}

# Create the API Gateway
resource "aws_api_gateway_rest_api" "dummy_data_api" {
  name = "dummy_data_api"
}

# Create the API Gateway resource
resource "aws_api_gateway_resource" "dummy_data_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.dummy_data_api.id
  parent_id   = aws_api_gateway_rest_api.dummy_data_api.root_resource_id
  path_part   = "generate-data"
}

# Create the API Gateway method
resource "aws_api_gateway_method" "dummy_data_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.dummy_data_api.id
  resource_id   = aws_api_gateway_resource.dummy_data_api_resource.id
  http_method   = "GET"
  authorization = "AWS_IAM"
}

# Create the API Gateway integration
resource "aws_api_gateway_integration" "dummy_data_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.dummy_data_api.id
  resource_id             = aws_api_gateway_resource.dummy_data_api_resource.id
  http_method             = aws_api_gateway_method.dummy_data_api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.dummy_data_api.invoke_arn
}

# Create the API Gateway deployment
resource "aws_api_gateway_deployment" "dummy_data_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.dummy_data_api.id
  stage_name  = "prod"
}

# Create the API Gateway usage plan
resource "aws_api_gateway_usage_plan" "dummy_data_api_usage_plan" {
  name = "dummy_data_api_usage_plan"
}

# Create the API Gateway API key
resource "aws_api_gateway_api_key" "dummy_data_api_key" {
  name = "dummy_data_api_key"
}

# Create the API Gateway usage plan key
resource "aws_api_gateway_usage_plan_key" "dummy_data_api_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.dummy_data_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.dummy_data_api_usage_plan.id
}

# Create the API Gateway usage plan throttle
resource "aws_api_gateway_usage_plan" "dummy_data_api_usage_plan_throttle" {
  api_stages = [
    {
      api_id      = aws_api_gateway_rest_api.dummy_data_api.id
      stage       = aws_api_gateway_deployment.dummy_data_api_deployment.stage_name
      throttle    = {
        burst_limit = 10
        rate_limit  = 100
      }
    }
  ]
}