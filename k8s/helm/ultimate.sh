#!/usr/bin/env sh

helm upgrade \
    --install \
    --namespace kit-helm \
    --wait \
    --create-namespace \
    --atomic \
    --cleanup-on-fail \
    --timeout 300s \
    --values helm/webserver.values.yaml \
    webserver \
    helm/webserver/
