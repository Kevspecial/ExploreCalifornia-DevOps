# ExploreCalifornia-DevOps

[![CI/CD](https://github.com/Kevspecial/ExploreCalifornia-DevOps/actions/workflows/ci.yml/badge.svg)](https://github.com/Kevspecial/ExploreCalifornia-DevOps/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A DevOps portfolio project that takes the **Explore California** static travel site
and wraps it in a complete, production-style delivery pipeline: containerized build,
automated browser testing, CI/CD to a container registry, infrastructure-as-code
deployment, and runtime observability.

The application itself is a static website served by nginx — the focus of this
repository is the **DevOps tooling around it**.

## Architecture

```
        push / PR
           │
           ▼
   GitHub Actions (CI/CD)
   ┌──────────────────────────────┐
   │ 1. hadolint  (lint image)    │
   │ 2. RSpec + Capybara +        │
   │    Selenium (browser tests)  │
   │ 3. build & push → GHCR       │
   └──────────────────────────────┘
           │ image
           ▼
   Traefik ──▶ nginx container ──▶ /stub_status
                                        │
                    nginx-exporter ◀────┘
                          │ metrics (proxy network)
      existing homelab Prometheus ──▶ existing homelab Grafana
                                       (import monitoring/grafana/dashboards/nginx.json)
```

## Tech stack

| Concern              | Tooling                                              |
|----------------------|------------------------------------------------------|
| Web server           | nginx (`nginx:1.27-alpine`), hardened config         |
| Containerization     | Docker, Docker Compose                               |
| Testing              | RSpec, Capybara, Selenium (remote Chrome grid)       |
| CI/CD                | GitHub Actions → GitHub Container Registry (GHCR)    |
| Infrastructure       | Terraform (`kreuzwerker/docker` provider)            |
| Observability        | Prometheus, Grafana, nginx-prometheus-exporter       |

## Repository layout

```
.
├── Dockerfile                     # nginx image (pinned, HEALTHCHECK)
├── nginx.conf                     # hardened config: security headers, /stub_status
├── rspec.dockerfile               # test runner image (Bundler + Gemfile)
├── Gemfile                        # pinned test dependencies
├── docker-compose.yml             # Traefik-routed deployment + nginx-exporter
├── docker-compose.test.yml        # self-contained test stack (site + selenium + rspec)
├── spec/                          # unit + integration browser tests
├── terraform/                     # IaC: deploy the container via Terraform
└── monitoring/                    # scrape snippet + Grafana dashboard for existing stack
```

## Getting started

### Prerequisites
- Docker + Docker Compose
- (optional) Terraform ≥ 1.5 for the IaC workflow

### Deploy the site (homelab)
The site is fronted by Traefik on the shared external `proxy` network, alongside an
nginx-exporter that feeds your existing homelab monitoring stack:
```bash
docker compose up -d --build
```
This starts the `website` (routed to `explorecalifornia.kancodes.de`) and the
`explorecalifornia-nginx-exporter` container.

### Run the test suite
Spins up the site, a Selenium Chrome grid, and the RSpec runner, then exits with the suite's status:
```bash
docker compose -f docker-compose.test.yml up --build \
  --abort-on-container-exit --exit-code-from tests
```

### Deploy with Terraform
```bash
cd terraform
terraform init
terraform apply          # builds the image and runs the container
terraform output site_url
```

## CI/CD

On every push and pull request, [GitHub Actions](.github/workflows/ci.yml):
1. **Lints** the Dockerfile with hadolint.
2. **Tests** the site end-to-end via the Selenium-driven RSpec suite.
3. On merges to `main`, **builds and pushes** the image to GHCR at
   `ghcr.io/kevspecial/explorecalifornia-devops` (tagged `latest` and the commit SHA).

## Observability

This project **integrates with an existing homelab monitoring stack** (Prometheus +
Grafana + cAdvisor) rather than duplicating it:

1. The nginx config exposes an internal `/stub_status` endpoint.
2. `explorecalifornia-nginx-exporter` (in [docker-compose.yml](docker-compose.yml)) scrapes it and
   exposes Prometheus metrics on the shared `proxy` network.
3. Add the job in [monitoring/prometheus-scrape-snippet.yml](monitoring/prometheus-scrape-snippet.yml)
   to your homelab `prometheus.yml` and reload Prometheus.
4. Import [monitoring/grafana/dashboards/nginx.json](monitoring/grafana/dashboards/nginx.json) into
   Grafana for active-connections, request-rate, and connection-state panels.

## License

Licensed under the [MIT License](LICENSE).
