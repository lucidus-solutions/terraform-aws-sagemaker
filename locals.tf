locals {
  stack                = "${var.program}-${var.env}-${var.app}"
  jupyter_server_image = var.jupyter_server_image != null ? var.jupyter_server_image : "arn:aws:sagemaker:us-east-1:081325390199:image/jupyter-server-3"
  kernel_gateway_image = var.kernel_gateway_image != null ? var.kernel_gateway_image : "arn:aws:sagemaker:us-east-1:081325390199:image/sagemaker-data-science-310-v1"
}