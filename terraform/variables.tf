variable "docker_host" {
  description = "Docker daemon endpoint Terraform connects to."
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "image_name" {
  description = "Container image to deploy. Defaults to building locally from the repo Dockerfile."
  type        = string
  default     = "explorecalifornia:local"
}

variable "build_local" {
  description = "When true, build the image from the repo Dockerfile instead of pulling image_name."
  type        = bool
  default     = true
}

variable "container_name" {
  description = "Name of the running container."
  type        = string
  default     = "explorecalifornia"
}

variable "external_port" {
  description = "Host port that maps to the container's port 80. (8080 is avoided since cAdvisor uses it.)"
  type        = number
  default     = 8088
}
