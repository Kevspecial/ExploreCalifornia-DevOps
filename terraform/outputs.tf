output "container_name" {
  description = "Name of the running container."
  value       = docker_container.website.name
}

output "site_url" {
  description = "URL where the site is reachable on the Docker host."
  value       = "http://localhost:${var.external_port}"
}

output "image_id" {
  description = "ID of the deployed image."
  value       = docker_image.website.image_id
}
