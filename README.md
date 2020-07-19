# docker-stack-ci-solution :whale: :bar_chart: :handshake:
CI solution to build multistage Docker images for stack/docker-compose as a GitHub Action.

This solution provides a full GitHub workflow for building images using previous builds as cache
for achieving fast CI pipelines.

# Purpose
This action gives an opinionated CI workflow for building and caching multistage docker builds.

1. Write a Dockerfile for multistage builds specifying which stages should be cached in a registry 
2. Pull resulting images in the environment where they are needed (production/staging/test)
