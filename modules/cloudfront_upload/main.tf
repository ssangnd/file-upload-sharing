resource "aws_cloudfront_origin_access_control" "oac_s3_bucket_upload" {
  name                              = "oac_s3_bucket_upload"
  description                       = "s3 Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cloudfront_upload" {
  depends_on = [
    aws_cloudfront_origin_access_control.oac_s3_bucket_upload
  ]

  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = var.bucket_regional_domain_name
    origin_id                = var.bucket_id
    origin_access_control_id = aws_cloudfront_origin_access_control.oac_s3_bucket_upload.id
  }

  custom_error_response {
    error_caching_min_ttl = 3000
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.bucket_id
    
    cache_policy_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    /* Link Lambda@Edge to the CloudFront distribution */
    # lambda_function_association   {
    #   event_type   = "viewer-request"
    #   include_body = true
    #   lambda_arn   = var.lambda_edge_validate_token_qualified_arn
    # } 
  }
  
  origin {
    domain_name = "${var.api_gw_id}.execute-api.${var.region}.amazonaws.com"
    origin_id   = var.api_gw_id
    origin_path = "/dev"
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

 ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.api_gw_id
    /* cache_policy_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" */

    forwarded_values {
      query_string = true
      headers      = ["Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers"]
      cookies {
        forward = "none"
      }
    }

    /* viewer_protocol_policy = "https-only" */
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    /* Link Lambda@Edge to the CloudFront distribution */
    # lambda_function_association   {
    #   event_type   = "viewer-request"
    #   include_body = true
    #   lambda_arn   = var.lambda_edge_validate_token_qualified_arn
    # } 
  } 

  ordered_cache_behavior {
    path_pattern     = "/parseauth"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.bucket_id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  
    /* Link Lambda@Edge to the CloudFront distribution */
    # lambda_function_association   {
    #   event_type   = "viewer-request"
    #   include_body = true
    #   lambda_arn   = var.lambda_edge_validate_token_qualified_arn
    # }   
  } 

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  tags = var.tags
}


/* Declare policy for cloudfront access to S3 bucket */
data "aws_iam_policy_document" "iam_policy_for_access_s3" {
  depends_on = [
    aws_cloudfront_distribution.cloudfront_upload,
    /*  */
  ]
  statement {
    sid    = "s3"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["cloudfront.amazons.com"]
      type        = "*"
    }
    resources = [
      "${var.bucket_arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cloudfront_upload.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_upload" {
  depends_on = [
    data.aws_iam_policy_document.iam_policy_for_access_s3
  ]
  bucket = var.bucket_id
  policy = data.aws_iam_policy_document.iam_policy_for_access_s3.json
}

