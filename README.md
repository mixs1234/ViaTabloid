### Complete Integration Flow
## 1. Developer Workflow:

Developer pushes code → Dockerfiles build/cache → PR created → Tests run

## 2. Merge Workflow:

PR approved & merged → Dockerfiles build → Images published to ghcr.io

## 3. Deployment Workflow:

Images published → K8s deployment triggered → Images pulled and deployed

## 4. Runtime Integration:

K8s pulls images → Containers start → Services expose ports → App runs
