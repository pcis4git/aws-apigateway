terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
}

resource "aws_api_gateway_rest_api" "pcoi_api" {
  name        = "pcoi-api"
  description = "This is an terraform API Gateway"
  api_key_source = "AUTHORIZER"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "pcoi_authorizer" {
  name                   = "pcoi_authorizer"
  rest_api_id            = aws_api_gateway_rest_api.pcoi_api.id
  authorizer_uri         = data.aws_lambda_function.lambuda_authorizer.invoke_arn
  authorizer_credentials = data.aws_iam_role.authorizer_role_invoke_lambda.arn
  type                   = "TOKEN"
  identity_source        = "method.request.header.Authorization"
}

resource "aws_api_gateway_resource" "resource_consent" {
  rest_api_id = aws_api_gateway_rest_api.pcoi_api.id
  parent_id   = aws_api_gateway_rest_api.pcoi_api.root_resource_id
  path_part   = "Consent"
}

resource "aws_api_gateway_method" "method_consent_post" {
  rest_api_id   = aws_api_gateway_rest_api.pcoi_api.id
  resource_id   = aws_api_gateway_resource.resource_consent.id
  http_method   = "POST"
  api_key_required = true
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.pcoi_authorizer.id  
}

resource "aws_api_gateway_integration" "integration_consent_post" {
  rest_api_id             = aws_api_gateway_rest_api.pcoi_api.id
  resource_id             = aws_api_gateway_resource.resource_consent.id
  http_method             = aws_api_gateway_method.method_consent_post.http_method
  connection_type         = "VPC_LINK"
  connection_id           = data.aws_api_gateway_vpc_link.restapi_vpc_link.id
  type                    = "HTTP"
  integration_http_method = "POST"
  uri                     = var.backbone_url
  request_parameters = {
    "integration.request.header.x-oag-apiname" = "'pcoi'"
    "integration.request.header.x-oag-sign-token-enabled" = "'true'"
    "integration.request.header.x-oag-audit-enabled" = "'true'"
    "integration.request.header.x-oag-audit-ignore-failure" = "'true'"
    "integration.request.header.x-oag-scope" = "'system/Bundle.write'"
  }

  request_templates = { 
    "application/json" = file("${path.module}/integration-request-template.vtl")
  }
}

resource "aws_api_gateway_method_response" "consent_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.pcoi_api.id
  resource_id = aws_api_gateway_resource.resource_consent.id
  http_method = aws_api_gateway_method.method_consent_post.http_method
  status_code = "200"
  response_models = {
     "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.X-Global-Transaction-ID" = false,
    "method.response.header.lobtxid" = false
  }
}

resource "aws_api_gateway_method_response" "consent_post_response_400" {
  rest_api_id = aws_api_gateway_rest_api.pcoi_api.id
  resource_id = aws_api_gateway_resource.resource_consent.id
  http_method = aws_api_gateway_method.method_consent_post.http_method
  status_code = "400"
  response_models = {
     "application/json" = "Empty"
  }  

  response_parameters = {
    "method.response.header.X-Global-Transaction-ID" = false,
    "method.response.header.lobtxid" = false
  }
}

resource "aws_api_gateway_method_response" "consent_post_response_500" {
  rest_api_id = aws_api_gateway_rest_api.pcoi_api.id
  resource_id = aws_api_gateway_resource.resource_consent.id
  http_method = aws_api_gateway_method.method_consent_post.http_method
  status_code = "500"
  response_models = {
     "application/json" = "Empty"
  }  

  response_parameters = {
    "method.response.header.X-Global-Transaction-ID" = false,
    "method.response.header.lobtxid" = false
  }  

}

resource "aws_api_gateway_integration_response" "consent_post_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.pcoi_api.id
  resource_id = aws_api_gateway_resource.resource_consent.id
  http_method = aws_api_gateway_method.method_consent_post.http_method
  status_code = aws_api_gateway_method_response.consent_post_response_200.status_code
  selection_pattern = "2\\d{2}"

  response_parameters = {
    "method.response.header.X-Global-Transaction-ID" = "integration.response.header.X-Global-Transaction-ID"
    "method.response.header.lobtxid"    = "integration.response.header.lobtxid"
  }
  # Transforms the backend JSON response to XML
  # response_templates = {
  #   "application/json" = file("${path.module}/integration-response-template.vtl")
  # }
}

resource "aws_api_gateway_integration_response" "consent_post_integration_response_400" {
  rest_api_id = aws_api_gateway_rest_api.pcoi_api.id
  resource_id = aws_api_gateway_resource.resource_consent.id
  http_method = aws_api_gateway_method.method_consent_post.http_method
  status_code = aws_api_gateway_method_response.consent_post_response_400.status_code
  selection_pattern = "4\\d{2}"

  response_parameters = {
    "method.response.header.X-Global-Transaction-ID" = "integration.response.header.X-Global-Transaction-ID"
    "method.response.header.lobtxid"    = "integration.response.header.lobtxid"
  }  

  # Transforms the backend JSON response to XML
  # response_templates = {
  #   "application/json" = file("${path.module}/integration-response-template.vtl")
  # }
}

resource "aws_api_gateway_integration_response" "consent_post_integration_response_500" {
  rest_api_id = aws_api_gateway_rest_api.pcoi_api.id
  resource_id = aws_api_gateway_resource.resource_consent.id
  http_method = aws_api_gateway_method.method_consent_post.http_method
  status_code = aws_api_gateway_method_response.consent_post_response_500.status_code
  selection_pattern = "5\\d{2}"

  response_parameters = {
    "method.response.header.X-Global-Transaction-ID" = "integration.response.header.X-Global-Transaction-ID"
    "method.response.header.lobtxid"    = "integration.response.header.lobtxid"
  }  

  # Transforms the backend JSON response to XML
  # response_templates = {
  #   "application/json" = file("${path.module}/integration-response-template.vtl")
  # }
}


resource "aws_api_gateway_deployment" "pcoi_deployment" {
  depends_on = [
    aws_api_gateway_integration.integration_consent_post,
  ]

  rest_api_id = aws_api_gateway_rest_api.pcoi_api.id
}

resource "aws_api_gateway_stage" "pcoi_stage" {
  deployment_id = aws_api_gateway_deployment.pcoi_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.pcoi_api.id
  stage_name    = var.stage_name
  variables = {
    "api_name": "olis"
    "lobEndpoint": var.lob_url
  }
}

resource "aws_api_gateway_method_settings" "allMethodsSettings" {
  rest_api_id = aws_api_gateway_rest_api.pcoi_api.id
  stage_name  = aws_api_gateway_stage.pcoi_stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    data_trace_enabled = true
    logging_level   = "INFO"
  }
}


output "base_url" {
  value = aws_api_gateway_deployment.pcoi_deployment.invoke_url
}
