provider "aws" { 
    #profile = "myprofile"
    region = "us-east-1"
    #access_key = "AKIAZQ3DSFHFSAVHZ6JA"
    #secret_key = "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"
    access_key = "AKIAZQ3DSFHF2IRKPTTW"
    secret_key = "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"
    #access_key = "AKIAZQ3DSFHF3D2PKWFK"
    #secret_key = "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"
}

/***
resource "aws_instance" "azubi_server" {
   # ami = "ami-04175dfed7619fb38"
    ami = "ami-02d7fd1c2af6eead0"
    instance_type = "t2.micro"

    user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 && sudo apt install nginx -y
  echo "*** Completed Installing apache2 and nginx"
  EOF
 
 tags = {
        Name = "My-Terraform-Server1"
    }
}

resource "aws_security_group" "allow_http1" {
  name        = "allow_http1"
  description = "Allow inbound HTTP traffic"

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_all_outbound1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_http1.id
}
***/

resource "aws_s3_bucket" "prod_media" {
  bucket = "prod_media_bucket"
}

resource "aws_s3_bucket_cors_configuration" "prod_media" {
  bucket = aws_s3_bucket.prod_media.id  

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }  
}

resource "aws_s3_bucket_acl" "prod_media" {
    bucket = aws_s3_bucket.prod_media.id
    acl    = "private"
    depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.prod_media.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.example]
}

resource "aws_iam_user" "prod_media_bucket" {
  name = "prod-media-bucket"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.prod_media.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "prod_media_bucket" {
    bucket = aws_s3_bucket.prod_media.id
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${"prod_media_bucket"}",
          "arn:aws:s3:::${"prod_media_bucket"}/*"
        ]
      },
      {
        Sid = "PublicReadGetObject"
        Principal = "*"
        Action = [
          "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${"prod_media_bucket"}",
          "arn:aws:s3:::${"prod_media_bucket"}/*"
        ]
      },
    ]
  })
  
  depends_on = [aws_s3_bucket_public_access_block.example]
}

/***
resource "aws_s3_bucket" "Codearnival_AA_bucket" {
   bucket = "Codearnival_AA_bucket"
   acl = "private"  
}

resource "aws_s3_bucket" "NatureEscape_AA_bucket" {
   bucket = "NatureEscape_AA_bucket"
   acl = "private"  
}
***/