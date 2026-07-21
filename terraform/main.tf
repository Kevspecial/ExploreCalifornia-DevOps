# Explore California deployed as a Docker container via Terraform.
# Uses the kreuzwerker/docker provider so the full deploy is reproducible
# infrastructure-as-code with zero cloud cost.

resource "docker_image" "website" {
  name = var.image_name

  # Build from the repo Dockerfile when build_local is true, otherwise
  # treat image_name as an existing image (e.g. pulled from GHCR).
  dynamic "build" {
    for_each = var.build_local ? [1] : []
    content {
      context    = "${path.module}/.."
      dockerfile = "Dockerfile"
      tag        = [var.image_name]
    }
  }

  keep_locally = true
}

resource "docker_container" "website" {
  name    = var.container_name
  image   = docker_image.website.image_id
  restart = "unless-stopped"

  ports {
    internal = 80
    external = var.external_port
  }

  healthcheck {
    test     = ["CMD", "wget", "--spider", "-q", "http://127.0.0.1/index.htm"]
    interval = "30s"
    timeout  = "3s"
    retries  = 3
  }
}
