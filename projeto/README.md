# AGISIT Project — Chat Microservices (Educational)

This repository contains an educational microservices chat application used for the AGISIT project work.
The project includes multiple backend services, a static frontend served by nginx, per-service PostgreSQL databases, and monitoring stacks (Prometheus + Grafana). It can be run locally with Docker Compose or deployed to google cloud using the provided manifests.

## Contents

- `Application/` — main application code and orchestration (Dockerfiles, docker-compose.yml, supervisord, ansible, infra, k8s manifests).
	- `backend/services/` — microservices (auth-users, contacts, groups, messages).
	- `frontend/` — nginx + static frontend files.
	- `db/` — SQL initialisation and sample data for each service.
	- `infra/` — Terraform, Prometheus, Grafana provisioning and  CI configuration and pipeline helpers.
	- `k8s/` — Kubernetes manifests for each service and DBs.
- `report/` — project report and documentation.

![LOGIN](/assets/login.png)

![CHAT](/assets/chat.png)

![GRAFANA](/assets/grafana.png)

## Quick architecture overview

The system follows a small microservice layout:

- Four backend services (each with its own Postgres DB):
	- `auth-users` — authentication and user management
	- `contacts` — user contacts
	- `groups` — group management
	- `messages` — messaging functionality
- Frontend served by nginx (static files) that talks to the backend services.
- Monitoring: Prometheus scrapes service metrics and Grafana is used for dashboards.

Internal service-to-service communication uses HTTP. Each service exposes a simple REST API used by the frontend and other services.

## Run locally (quick start)

```powershell
cd Application
docker compose up --build
```

This will build the service images and start the entire stack. To run in detached mode:

```powershell
docker compose up --build -d
```

To stop and remove containers:

```powershell
docker compose down
```

If you only want a subset (for example frontend + auth), you can start them by service name, e.g.:

```powershell
docker compose up --build frontend auth-users
```

To deploy on google cloud follow "Application/README.md"

## Environment variables & configuration

Each service reads connection settings from environment variables (configured in the compose file). Important values to review before production:

- `JWT_SECRET` — change this default secret to a strong secret in production
- Database credentials: `DB_USER`, `DB_PASSWORD`, `DB_NAME` — currently set to `chat` / `chatpass` in the compose file for convenience

When deploying to a remote platform, keep secrets out of source control and provide them via environment/secret managers.

## Kubernetes & Infra

Kubernetes manifests live under `Application/k8s/`. The Terraform and monitoring provisioning are under `Application/infra/terraform` and `Application/infra/*`.

There are also Ansible playbooks under `Application/ansible/` used for cluster bootstrap and deployment in the project.
