# GKE Kubernetes Cluster Configuration
# Author: Jose Perez
# Company: SecuredPress LLC
# Created: December 2024
# License: MIT
#
# Output Values

output "cluster_name" {
  value       = google_container_cluster.security_demo_cluster.name
  description = "GKE Cluster Name"
}

output "cluster_endpoint" {
  value       = google_container_cluster.security_demo_cluster.endpoint
  description = "GKE Cluster Endpoint"
  sensitive   = true
}

output "cluster_ca_certificate" {
  value       = google_container_cluster.security_demo_cluster.master_auth[0].cluster_ca_certificate
  description = "GKE Cluster CA Certificate"
  sensitive   = true
}

output "project_id" {
  value       = var.project_id
  description = "GCP Project ID"
}

output "region" {
  value       = var.region
  description = "GCP Region"
}

output "zone" {
  value       = var.zone
  description = "GCP Zone"
}

output "kubectl_config_command" {
  value       = "gcloud container clusters get-credentials ${var.cluster_name} --zone=${var.zone} --project=${var.project_id}"
  description = "Command to configure kubectl"
}

output "cluster_info" {
  value = {
    name         = google_container_cluster.security_demo_cluster.name
    location     = google_container_cluster.security_demo_cluster.location
    node_count   = var.node_count
    machine_type = var.machine_type
  }
  description = "Cluster information summary"
}
