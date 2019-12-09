Repo to reproduce issue in GKE network policy addon
====

This repo aims to recreate [this issue](https://issuetracker.google.com/issues/145873160). Apply this terraform configuration, then run `kubectl get pods -A`. Observe pod `calico-policy-controller` is not present.

