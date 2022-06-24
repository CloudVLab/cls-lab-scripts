# Declare local variables
locals {
  my_random_integer = random_integer.random_int.result
  random_zone = random_shuffle.zone_choices.result[0]
  user_1_username = "${var.user_1_userName}@qwiklabs.net"
  user_2_username = "${var.user_2_userName}@qwiklabs.net"
}

# Save Project ID as a data resource
data "google_project" "project" {
  project_id = var.gcp_project_id
}

# GCE Instance that runs the dynamic startup script
resource "google_compute_instance" "startup-vm" {
  description = "Runs a dynamic script to remove viewer role from customer users"
  name         = "startup-vm"
  machine_type = "f1-micro"
  zone         = local.random_zone
  tags         = ["http-server"]
  # metadata_startup_script = templatefile("scripts/startup_script.tftpl", { user_1_username = "${local.user_1_username}", user_2_username = "${local.user_2_username}", random_zone = "${local.random_zone}"})
  # 
  metadata_startup_script = templatefile("scripts/startup_script.tftpl", { random_integer = "${local.my_random_integer}", gcp_region = "${var.gcp_region}"})
  
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }
  service_account {
    scopes = ["cloud-platform"]
  }
}

# Grant Project IAM Admin role to compute@developer service account (add permissions as necessary for what commands you need to run)
resource "google_project_iam_binding" "compute_sa" {
  role    = "roles/resourcemanager.projectIamAdmin"
  project = var.gcp_project_id
  members = [
    "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com",
  ]
}

#
# ------------------------------------
#

# Random elements

resource "random_integer" "random_int" {
  min = 1
  max = 100
}

# Randomized zone list
resource "random_shuffle" "zone_choices" {
  input        = ["us-central1-a", "us-central1-b", "us-east1-b", "us-east1-c", "us-west1-a", "us-west1-b"]
  result_count = 1
}

