resource "aws_sagemaker_domain" "domain" {
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
