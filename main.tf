resource "aws_sagemaker_domain" "this" {
  domain_name                   = "${local.stack}-domain"
  auth_mode                     = var.auth_mode
  vpc_id                        = var.vpc_id
  subnet_ids                    = var.subnet_ids
  kms_key_id                    = var.kms_key_id
  app_network_access_type       = var.app_network_access_type
  app_security_group_management = var.app_security_group_management

  default_space_settings {
    execution_role  = var.execution_role
    security_groups = var.security_group_ids

    jupyter_server_app_settings {
      default_resource_spec {
        instance_type       = "system"
        sagemaker_image_arn = local.jupyter_server_image
      }
    }

    kernel_gateway_app_settings {
      default_resource_spec {
        instance_type       = var.instance_type
        sagemaker_image_arn = local.kernel_gateway_image
      }
    }
  }

  default_user_settings {
    default_landing_uri = "studio::"
    execution_role      = var.execution_role
    security_groups     = var.security_group_ids
    studio_web_portal   = "ENABLED"

    canvas_app_settings {
      direct_deploy_settings {
        status = "ENABLED"
      }

      model_register_settings {
        status = "ENABLED"
      }

      time_series_forecasting_settings {
        amazon_forecast_role_arn = var.execution_role
        status                   = "ENABLED"
      }
    }

    jupyter_server_app_settings {
      # lifecycle_config_arns = [aws_sagemaker_studio_lifecycle_config.auto_shutdown.arn]

      dynamic "code_repository" {
        for_each = var.code_repository

        content {
          repository_url = each.value
        }
      }

      default_resource_spec {
        instance_type       = "system"
        sagemaker_image_arn = local.jupyter_server_image
      }
    }

    sharing_settings {
      notebook_output_option = "Disabled"
      s3_kms_key_id          = var.kms_key_id
    }

    space_storage_settings {
      default_ebs_storage_settings {
        default_ebs_volume_size_in_gb = var.ebs_storage_size_gb_default
        maximum_ebs_volume_size_in_gb = var.ebs_storage_size_gb_maximum
      }
    }
  }

  domain_settings {
    security_group_ids             = var.security_group_ids
    execution_role_identity_config = "USER_PROFILE_NAME"
  }

  retention_policy {
    home_efs_file_system = var.home_efs_retention_policy
  }
}

resource "aws_sagemaker_space" "this" {
  count = var.create_sagemaker_space ? 1 : 0

  domain_id          = aws_sagemaker_domain.this.id
  space_name         = "${local.stack}-space"
  space_display_name = "${local.stack}-space"


  space_settings {

    jupyter_server_app_settings {
      default_resource_spec {
        instance_type       = "system"
        sagemaker_image_arn = local.jupyter_server_image
      }
    }

    kernel_gateway_app_settings {
      default_resource_spec {
        instance_type       = "ml.t3.medium"
        sagemaker_image_arn = local.kernel_gateway_image
      }
    }
  }
}

resource "aws_sagemaker_user_profile" "user" {
  count = var.create_sagemaker_default_user ? 1 : 0

  domain_id         = aws_sagemaker_domain.this.id
  user_profile_name = "${local.stack}-default-user"

  user_settings {
    execution_role = var.execution_role

    canvas_app_settings {

      direct_deploy_settings {
        status = "ENABLED"
      }

      model_register_settings {
        status = "ENABLED"
      }

      time_series_forecasting_settings {
        amazon_forecast_role_arn = var.execution_role
        status                   = "ENABLED"
      }
    }

    jupyter_server_app_settings {
      lifecycle_config_arns = []

      default_resource_spec {
        instance_type       = "system"
        sagemaker_image_arn = local.jupyter_server_image
      }

      dynamic "code_repository" {
        for_each = var.code_repository

        content {
          repository_url = each.value
        }
      }
    }

    space_storage_settings {
      default_ebs_storage_settings {
        default_ebs_volume_size_in_gb = var.ebs_storage_size_gb_default
        maximum_ebs_volume_size_in_gb = var.ebs_storage_size_gb_maximum
      }
    }
  }
}

resource "aws_sagemaker_workforce" "this" {
  count = var.create_sagemaker_workforce ? 1 : 0

  workforce_name = "${local.stack}-workforce"

  cognito_config {
    client_id = aws_cognito_user_pool_client.this.id
    user_pool = aws_cognito_user_pool.this.id
  }

  source_ip_config {
    cidrs = data.aws_vpc.this.cidr_block
  }

  workforce_vpc_config {
    security_group_ids = var.security_group_ids
    subnets            = var.subnet_ids
    vpc_id             = var.vpc_id
  }
}

resource "aws_sagemaker_workteam" "this" {
  count = var.create_sagemaker_workforce ? 1 : 0

  description    = "A team of workers that label data examples and correct the work of other workers"
  workforce_name = aws_sagemaker_workforce.this[0].workforce_name
  workteam_name  = "${local.stack}-workteam"

  member_definition {
    cognito_member_definition {
      client_id  = aws_cognito_user_pool_client.this[0].id
      user_pool  = aws_cognito_user_pool.this[0].id
      user_group = aws_cognito_user_group.this[0].id
    }
  }
}

resource "aws_cognito_user_pool" "this" {
  count = var.create_sagemaker_workforce ? 1 : 0

  name                     = "${local.stack}-user-pool"
  auto_verified_attributes = ["email"]
  deletion_protection      = "INACTIVE"
  mfa_configuration        = "OFF"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = true

    invite_message_template {
      email_message = "Your username is {username} and temporary password is {####}."
      email_subject = "Your SageMaker Augmented AI Account is Ready"
      sms_message   = "Your username is {username} and temporary password is {####}."
    }
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 1
  }

  user_pool_add_ons {
    advanced_security_mode = "OFF"
  }

  username_configuration {
    case_sensitive = true
  }
}

resource "aws_cognito_user_group" "this" {
  count = var.create_sagemaker_workforce ? 1 : 0

  name         = "${local.stack}-user-group"
  user_pool_id = aws_cognito_user_pool.this[0].id
  description  = "Users in this group can perform sagemaker review tasks"
  precedence   = 1
}

resource "aws_cognito_user" "this" {
  for_each = { for u in var.cognito_users : u.username => u }

  enabled      = true
  user_pool_id = aws_cognito_user_pool.this.id
  username     = each.value.username

  attributes = {
    email          = each.value.email
    email_verified = true
  }
}

resource "aws_cognito_user_in_group" "this" {
  for_each = { for u in var.cognito_users : u.username => u }

  group_name   = aws_cognito_user_group.this[0].name
  user_pool_id = aws_cognito_user_pool.this[0].id
  username     = each.value.username
}

resource "aws_cognito_user_pool_client" "this" {
  count                                = var.create_sagemaker_workforce ? 1 : 0

  name                                 = "${local.stack}-user-pool-client"
  user_pool_id                         = aws_cognito_user_pool.this[0].id
  generate_secret                      = true
  supported_identity_providers         = ["COGNITO"]
  explicit_auth_flows                  = ["USER_PASSWORD_AUTH"]
  enable_token_revocation              = true
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  allowed_oauth_flows                  = ["implicit", "code"]
  allowed_oauth_flows_user_pool_client = true
}

resource "aws_cognito_user_pool_domain" "this" {
  count        = var.create_sagemaker_workforce ? 1 : 0

  domain       = local.stack
  user_pool_id = aws_cognito_user_pool.this[0].id
}