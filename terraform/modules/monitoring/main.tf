resource "helm_release" "kube_prometheus_stack" {
  count = var.enable_prometheus ? 1 : 0

  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "56.0.0"
  create_namespace = true

  set = [
    {
      name  = "prometheus.prometheusSpec.retention"
      value = "7d"
    },
    {
      name  = "grafana.adminPassword"
      value = "admin"
    },
    {
      name  = "grafana.ingress.enabled"
      value = "true"
    },
    {
      name  = "grafana.ingress.ingressClassName"
      value = "traefik"
    },
    {
      name  = "grafana.ingress.hosts[0]"
      value = "grafana.local"
    },
    {
      name  = "alertmanager.enabled"
      value = "false"
    },
    {
      name  = "grafana.plugins[0]"
      value = "grafana-polystat-panel"
    },
    {
      name  = "grafana.sidecar.dashboards.enabled"
      value = "true"
    },
    {
      name  = "grafana.sidecar.dashboards.label"
      value = "grafana_dashboard"
    }
  ]
}

resource "kubernetes_config_map_v1" "grafana_dashboard" {
  count = var.enable_prometheus ? 1 : 0

  metadata {
    name      = "demo-dashboard"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "demo-dash.json" = file("${path.module}/resources/demo-dash.json")
  }

  depends_on = [helm_release.kube_prometheus_stack]
}
