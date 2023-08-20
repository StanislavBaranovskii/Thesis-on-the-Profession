resource "yandex_compute_snapshot_schedule" "project_snapshot_schedule" {
  name           = "project-snapshot-schedule"
  description    = "Ежедневные снимки. Срок хранения снимков 7 дней"

  schedule_policy {
    expression = "10 0 ? * *"
  }

  retention_period = "168h"

  snapshot_spec {
    description = "retention-snapshot"

  }

disk_ids = ["${yandex_compute_disk.disk_web_1.id}", "${yandex_compute_disk.disk_web_2.id}", "${yandex_compute_disk.disk_elastic.id}", "${yandex_compute_disk.disk_kibana.id}", "${yandex_compute_disk.disk_prometheus.id}", "${yandex_compute_disk.disk_grafana.id}"]
  
  depends_on = [
     yandex_compute_instance.vm_web_1,
     yandex_compute_instance.vm_web_2,
     yandex_compute_instance.vm_elastic,
     yandex_compute_instance.vm_kibana,
     yandex_compute_instance.vm_prometheus,
     yandex_compute_instance.vm_grafana,
  ]
}

