resource "google_compute_instance" "default" {
  name         = "redhat-terraform"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "rhel-cloud/rhel-8"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = file("${path.module}/mysql.sh")
}