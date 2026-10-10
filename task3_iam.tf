
# ============================================================
# TASK 3 — MULTI-ACCOUNT IAM AND CROSS-ACCOUNT ACCESS
# File: task3_iam.tf
# Code-only assessment configuration; do not deploy yet.
# ============================================================

# ------------------------------------------------------------
# PROVIDERS
# These profiles must be configured locally if you ever deploy.
# Account IDs below are assignment placeholders.
# ------------------------------------------------------------

provider "aws" {
  alias   = "account_a"
  region  = "us-east-1"
  profile = "account-a"
}

provider "aws" {
  alias   = "account_b"
  region  = "us-east-1"
  profile = "account-b"
}

# ============================================================
# ACCOUNT A — 000000000000
# ============================================================

# ------------------------------------------------------------
# 1. IAM GROUPS
# ------------------------------------------------------------

resource "aws_iam_group" "group1" {
  provider = aws.account_a
  name     = "group1"
}

resource "aws_iam_group" "group2" {
  provider = aws.account_a
  name     = "group2"
}

# ------------------------------------------------------------
# 2. GROUP 1 USERS — engine and ci
# No console login profiles are created for these users here.
# ------------------------------------------------------------

resource "aws_iam_user" "engine" {
  provider = aws.account_a
  name     = "engine"
}

resource "aws_iam_user" "ci" {
  provider = aws.account_a
  name     = "ci"
}

resource "aws_iam_user_group_membership" "group1_members" {
  provider = aws.account_a
  name     = "group1-membership"

  users = [
    aws_iam_user.engine.name,
    aws_iam_user.ci.name
  ]

  groups = [
    aws_iam_group.group1.name
  ]
}

# ------------------------------------------------------------
# 3. GROUP 2 USERS — two named users
# Console login and CLI credentials must be configured securely.
# ------------------------------------------------------------

resource "aws_iam_user" "developer1" {
  provider = aws.account_a
  name     = "developer1"
}

resource "aws_iam_user" "developer2" {
  provider = aws.account_a
  name     = "developer2"
}

resource "aws_iam_user_group_membership" "group2_members" {
  provider = aws.account_a
  name     = "group2-membership"

  users = [
    aws_iam_user.developer1.name,
    aws_iam_user.developer2.name
  ]

  groups = [
    aws_iam_group.group2.name
  ]
}

# ============================================================
# 4. roleA — ADMINISTRATIVE ACCESS EXCEPT IAM
# ============================================================

resource "aws_iam_role" "roleA" {
  provider = aws.account_a
  name     = "roleA"

  # Account A principals may assume this role only when
  # separately authorized by applicable identity permissions.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        AWS = "arn:aws:iam::000000000000:root"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "roleA_permissions" {
  provider = aws.account_a
  name     = "roleA-admin-except-iam"
  role     = aws_iam_role.roleA.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect    = "Allow"
      NotAction = "iam:*"
      Resource  = "*"
    }]
  })
}

# ============================================================
# 5. roleB — PERMISSION ONLY TO ASSUME roleC
# ============================================================

resource "aws_iam_role" "roleB" {
  provider = aws.account_a
  name     = "roleB"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        AWS = "arn:aws:iam::000000000000:root"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "roleB_permissions" {
  provider = aws.account_a
  name     = "roleB-assume-roleC-only"
  role     = aws_iam_role.roleB.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "sts:AssumeRole"
      ]

      Resource = "arn:aws:iam::111111111111:role/roleC"
    }]
  })
}

# ============================================================
# ACCOUNT B — 111111111111
# ============================================================

# ------------------------------------------------------------
# 6. roleC — TRUST ONLY roleB FROM ACCOUNT A
# ------------------------------------------------------------

resource "aws_iam_role" "roleC" {
  provider = aws.account_b
  name     = "roleC"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        AWS = "arn:aws:iam::000000000000:role/roleB"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

# ------------------------------------------------------------
# 7. roleC — ACCESS TO ONE NAMED S3 BUCKET ONLY
# ------------------------------------------------------------

resource "aws_iam_role_policy" "roleC_s3_access" {
  provider = aws.account_b
  name     = "roleC-single-bucket-access"
  role     = aws_iam_role.roleC.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "s3:*"
      ]

      Resource = [
        "arn:aws:s3:::company-build-artifacts",
        "arn:aws:s3:::company-build-artifacts/*"
      ]
    }]
  })
}

