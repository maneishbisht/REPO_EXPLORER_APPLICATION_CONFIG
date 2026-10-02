This directory contains the Argo CD Application manifests rendered by the Helm chart.

They are intentionally plain `Application` resources rather than Terraform-owned resources. Each Helm release represents exactly one target environment; the release itself is bootstrapped into an Argo CD control-plane cluster by `CLUSTER_ADMIN_TF`.
