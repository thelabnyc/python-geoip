#!/usr/bin/env bash
set -euxo pipefail

SOURCE_AMD64="${CI_REGISTRY_IMAGE}:${IMMUTABLE_TAG_NAME}-amd64"
SOURCE_ARM64="${CI_REGISTRY_IMAGE}:${IMMUTABLE_TAG_NAME}-arm64"

SOURCE_GEO_AMD64="${CI_REGISTRY_IMAGE}:${IMMUTABLE_TAG_NAME}-geospatial-amd64"
SOURCE_GEO_ARM64="${CI_REGISTRY_IMAGE}:${IMMUTABLE_TAG_NAME}-geospatial-arm64"

# Standard image manifests
for TAG in "${CI_REGISTRY_IMAGE}:${IMMUTABLE_TAG_NAME}" "${CI_REGISTRY_IMAGE}:${MUTABLE_TAG_NAME}"; do
    docker buildx imagetools create \
        --tag "$TAG" \
        "$SOURCE_AMD64" \
        "$SOURCE_ARM64"
done

# Geospatial image manifests
for TAG in "${CI_REGISTRY_IMAGE}:${IMMUTABLE_TAG_NAME}-geospatial" "${CI_REGISTRY_IMAGE}:${MUTABLE_TAG_NAME}-geospatial"; do
    docker buildx imagetools create \
        --tag "$TAG" \
        "$SOURCE_GEO_AMD64" \
        "$SOURCE_GEO_ARM64"
done
