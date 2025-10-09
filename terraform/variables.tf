# GKE Kubernetes Cluster Configuration
# Author: Jose Perez
# Company: SecuredPress LLC
# Created: December 2024
# License: MIT
#
# Variables

variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "us-west4"
}

variable "zone" {
  description = "Google Cloud Zone"
  type        = string
  default     = "us-west4-a"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "demo-cluster"
}

variable "node_count" {
  description = "Initial number of nodes in the cluster"
  type        = number
  default     = 1 # Single node for minimal cost
}

variable "min_nodes" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 3 # Lower max for cost control
}

variable "machine_type" {
  description = "Machine type for cluster nodes"
  type        = string
  default     = "e2-small" # Smallest cost-effective option
}
