resource "kubernetes_namespace_v1" "backend" {
  metadata {
    name = "backend"
  }
}

resource "helm_release" "demo_app" {
  name             = "demo-app"
  namespace        = kubernetes_namespace_v1.backend.metadata[0].name
  chart            = var.chart_path
  create_namespace = false

  set = [{
    name  = "serviceMonitor.enabled"
    value = "true"
  }]
}
