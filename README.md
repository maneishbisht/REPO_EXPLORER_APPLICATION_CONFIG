# REPO_EXPLORER_APPLICATION_CONFIG

This repository is the **Argo application configuration repository** for Repo Explorer.

It is a Helm chart whose rendered objects are Argo CD `Application` manifests. It owns the application-level deployment definitions that used to be embedded inside the `CLUSTER_ADMIN_TF` ApplicationSets.

## What the chart deploys

For one selected environment, the chart renders:

- AWS Load Balancer Controller Application
- Gateway API CRD source as a second source of the LBC Application
- AWS Secrets Store CSI Driver + AWS provider Application
- Repo Explorer frontend configuration Application
- Repo Explorer backend configuration Application

The chart does not install Argo CD itself. `CLUSTER_ADMIN_TF` installs Argo CD and then bootstraps this chart.

## Values files

The repository contains three environment-specific values files:

```text
values-dev.yaml
values-test.yaml
values-prod.yaml
```

They contain environment-specific data such as:

- `target.clusterName`
- `target.endpoint`
- AWS region
- service-account names
- platform chart versions
- frontend/backend Git repository URLs and paths

The Root/EKS infrastructure GitHub Actions workflow updates `target.endpoint` after Terraform discovers the current EKS API endpoints.

## Why `values-test.yaml` is still used without Argo CD in test

`test_cluster` deliberately does not run Argo CD.

The dev Argo CD control plane bootstraps this chart twice:

```text
dev Argo CD
  -> chart(values-dev.yaml)  -> child Applications target dev
  -> chart(values-test.yaml) -> child Applications target test
```

The `Application` resources rendered by the Helm chart are created in the dev Argo CD cluster because the chart is itself a child of the dev bootstrap Application. Their `spec.destination.server` then points to the correct target cluster.

For dev and prod, the target server is `https://kubernetes.default.svc` because the Argo CD control plane and target cluster are the same cluster.

For test, the target server is read from `target.endpoint`, which is the EKS API endpoint registered in dev Argo CD by the `argocd cluster add test_cluster --core` workflow step.

## Private repositories

The child frontend/backend Applications use the URLs in the values files. The Argo CD repositories must therefore be registered with the correct credentials before synchronization.

The `CLUSTER_ADMIN_TF` GitHub Actions workflow registers:

- this application-config repository
- frontend config repository
- backend config repository

in both the dev and prod Argo CD instances.

## Editing versions

Platform chart versions are intentionally stored here rather than in Terraform. To change a dependency version, update the relevant value in the appropriate environment values files and let Argo CD reconcile the change.

Keep the environment files consistent unless a deliberate environment-specific version difference is required.
