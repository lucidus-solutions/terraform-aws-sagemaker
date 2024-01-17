variable "app" {
  type        = string
  description = "The name of the application or project that the stack supports"
  sensitive   = false
}

variable "env" {
  type        = string
  description = "The target environment for the stack - could be a tier or account level reference"
  validation {
    condition     = contains(["dev", "qa", "stage", "prod", "demo", "perf", "nonprod", "prod"], var.env)
    error_message = "Must be one of the following: dev, qa, stage, prod, demo, perf,nonprod, prod"
  }
  sensitive = false
}

variable "program" {
  type        = string
  description = "The name of the program that the application or project belongs to"
  sensitive   = false
}

variable "app_network_access_type" {
  type        = string
  description = "The network access type for the SageMaker domain"
  default     = "VpcOnly"
  sensitive   = false
}

variable "app_security_group_management" {
  type        = string
  description = "The security group management for the SageMaker domain"
  default     = "Customer"
  sensitive   = false
}

variable "auth_mode" {
  type        = string
  description = "The authentication mode for the SageMaker domain"
  default     = "IAM"
  sensitive   = false
}

variable "code_repository" {
  type        = set(string)
  description = "The code repository for the SageMaker domain"
  default     = []
  sensitive   = false
}

variable "cognito_users" {
  type = list(object({
    username = string,
    email    = string
    })
  )
  description = "The Cognito users for the SageMaker domain"
  default     = []
}

variable "create_sagemaker_default_user" {
  type        = bool
  description = "Whether to create a SageMaker default user for the SageMaker domain"
  default     = true
  sensitive   = false
}

variable "create_sagemaker_space" {
  type        = bool
  description = "Whether to create a SageMaker space for the SageMaker domain"
  default     = true
  sensitive   = false
}

variable "create_sagemaker_workforce" {
  type        = bool
  description = "Whether to create a SageMaker workforce for the SageMaker domain"
  default     = true
  sensitive   = false
}

variable "ebs_storage_size_gb_default" {
  type        = number
  description = "The default EBS storage size in GB for the SageMaker domain"
  default     = 5
  sensitive   = false
}

variable "ebs_storage_size_gb_maximum" {
  type        = number
  description = "The maximum EBS storage size in GB for the SageMaker domain"
  default     = 100
  sensitive   = false
}

variable "home_efs_retention_policy" {
  type        = string
  description = "The home EFS retention policy for the SageMaker domain"
  default     = "Retain"
  sensitive   = false
}

variable "execution_role" {
  type        = string
  description = "The execution role ARN for the SageMaker domain"
  sensitive   = false
}

variable "instance_type" {
  type        = string
  description = "The instance type for the SageMaker domain (kernel gateway)"
  default     = "ml.t3.medium"
  sensitive   = false
}

variable "jupyter_server_image" {
  type        = string
  description = "The Jupyter server image for the SageMaker domain"
  default     = null
  sensitive   = false
}

variable "kernel_gateway_image" {
  type        = string
  description = "The kernel gateway image for the SageMaker domain"
  default     = null
  sensitive   = false
}

variable "kms_key_id" {
  type        = string
  description = "The KMS key ID for the SageMaker domain to encrypt the EFS volume"
  default     = null
  sensitive   = false
}

variable "security_group_ids" {
  type        = set(string)
  description = "The security group IDs for the SageMaker domain"
  default     = []
  sensitive   = false
}

variable "subnet_ids" {
  type        = set(string)
  description = "The subnet IDs for the SageMaker domain"
  default     = []
  sensitive   = false
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID for the SageMaker domain"
  default     = null
  sensitive   = false
}