#Template
resource "google_compute_instance_template" "template_hadoopm" {
  name        = "template-engdados-appserver"
  description = "Template - Maquinas / VM da engdados - Hadoop/Spark"
  project = var.project_id

  tags = ["engdados", "hadoop", "http-server", "https-server"]

  labels = {
    appserver = "engdados"
  }

  instance_description = "Maquinas / VM da engdados "
  machine_type         = "n1-standard-4"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    disk_name = "boot-engdados-hm"
    source_image = "projects/centos-cloud/global/images/centos-7-v20220406"
    auto_delete  = true
    boot         = true
    mode = "READ_WRITE"
    disk_type= "pd-balanced"
    disk_size_gb = "100"
    type = "PERSISTENT"
  }

  network_interface {
    network    = "projects/engdados-santander/global/networks/engdados-vpc"
    subnetwork = "projects/engdados-santander/regions/southamerica-east1/subnetworks/engdados-subnet"
    access_config {}
  }

  metadata = {
    startup-script-url = "gs://${var.bucket_install}/install_hadoop.sh"
  }

  service_account {
    email = var.engdados_serviceAccount
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_compute_instance_template" "template_hadoopd" {
  name        = "template-engdados-appserver1"
  description = "Template - Maquinas / VM da engdados - Hadoop/Spark"
  project = var.project_id

  tags = ["engdados", "hadoop", "http-server", "https-server"]

  labels = {
    appserver = "engdados"
  }

  instance_description = "Maquinas / VM da engdados "
  machine_type         = "n1-standard-4"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    disk_name = "boot-engdados-hd"
    source_image = "projects/centos-cloud/global/images/centos-7-v20220406"
    auto_delete  = true
    boot         = true
    mode = "READ_WRITE"
    disk_type= "pd-balanced"
    disk_size_gb = "100"
    type = "PERSISTENT"
  }

  network_interface {
    network    = "projects/engdados-santander/global/networks/engdados-vpc"
    subnetwork = "projects/engdados-santander/regions/southamerica-east1/subnetworks/engdados-subnet"
    access_config {}
  }

  metadata = {
    startup-script-url = "gs://${var.bucket_install}/install_nodes.sh"
  }

  service_account {
    email = var.engdados_serviceAccount
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_compute_instance_template" "template_sparkm" {
  name        = "template-engdados-appserver2"
  description = "Template - Maquinas / VM da engdados - Hadoop/Spark"
  project = var.project_id

  tags = ["engdados", "spark", "http-server", "https-server"]

  labels = {
    appserver = "engdados"
  }

  instance_description = "Maquinas / VM da engdados "
  machine_type         = "n1-standard-4"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    disk_name = "boot-engdados-sm"
    source_image = "projects/centos-cloud/global/images/centos-7-v20220406"
    auto_delete  = true
    boot         = true
    mode = "READ_WRITE"
    disk_type= "pd-balanced"
    disk_size_gb = "100"
    type = "PERSISTENT"
  }

  network_interface {
    network    = "projects/engdados-santander/global/networks/engdados-vpc"
    subnetwork = "projects/engdados-santander/regions/southamerica-east1/subnetworks/engdados-subnet"
    access_config {}
  }

  metadata = {
    startup-script-url = "gs://${var.bucket_install}/install_spark.sh"
  }

  service_account {
    email = var.engdados_serviceAccount
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_compute_instance_template" "template_sparkw" {
  name        = "template-engdados-appserver3"
  description = "Template - Maquinas / VM da engdados - Hadoop/Spark"
  project = var.project_id

  tags = ["engdados", "spark", "http-server", "https-server"]

  labels = {
    appserver = "engdados"
  }

  instance_description = "Maquinas / VM da engdados "
  machine_type         = "n1-standard-4"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    disk_name = "boot-engdados-sw"
    source_image = "projects/centos-cloud/global/images/centos-7-v20220406"
    auto_delete  = true
    boot         = true
    mode = "READ_WRITE"
    disk_type= "pd-balanced"
    disk_size_gb = "100"
    type = "PERSISTENT"
  }

  network_interface {
    network    = "projects/engdados-santander/global/networks/engdados-vpc"
    subnetwork = "projects/engdados-santander/regions/southamerica-east1/subnetworks/engdados-subnet"
    access_config {}
  }

  metadata = {
    startup-script-url = "gs://${var.bucket_install}/install_spark.sh"
  }

  service_account {
    email = var.engdados_serviceAccount
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_compute_instance_group_manager" "instance-group-engdados" {
  name               = "instance-group-engdados"
  base_instance_name = "instance-group-engdados"
  project   = var.project_id
  zone      = var.gcp_zone
  target_size = 1
  version {
      name = "instance_group_manager-engdados"
      instance_template  = google_compute_instance_template.template_hadoopm.self_link
  }
}

resource "google_compute_instance_group_manager" "instance-group-engdados1" {
  name               = "instance-group-engdados1"
  base_instance_name = "instance-group-engdados1"
  project   = var.project_id
  zone      = var.gcp_zone
  target_size = 1
  version {
      name = "instance_group_manager-engdados"
      instance_template  = google_compute_instance_template.template_hadoopd.self_link
  }
}

resource "google_compute_instance_group_manager" "instance-group-engdados2" {
  name               = "instance-group-engdados2"
  base_instance_name = "instance-group-engdados2"
  project   = var.project_id
  zone      = var.gcp_zone
  target_size = 1
  version {
      name = "instance_group_manager-engdados"
      instance_template  = google_compute_instance_template.template_sparkm.self_link
  }
}

resource "google_compute_instance_group_manager" "instance-group-engdados3" {
  name               = "instance-group-engdados3"
  base_instance_name = "instance-group-engdados3"
  project   = var.project_id
  zone      = var.gcp_zone
  target_size = 1
  version {
      name = "instance_group_manager-engdados"
      instance_template  = google_compute_instance_template.template_sparkw.self_link
  }
}


## CRIACAO DAS MAQUINAS
resource "google_compute_instance_from_template" "maq-engdados1" {
  name = "namenode"
  project = var.project_id
  zone = var.gcp_zone

  source_instance_template = google_compute_instance_template.template_hadoopm.self_link
}

resource "google_compute_instance_from_template" "maq-engdados2" {
  name = "datanode"
  project = var.project_id
  zone = var.gcp_zone

  source_instance_template = google_compute_instance_template.template_hadoopd.self_link
}

resource "google_compute_instance_from_template" "maq-engdados3" {
  name = "master"
  project = var.project_id
  zone = var.gcp_zone

  source_instance_template = google_compute_instance_template.template_sparkm.self_link
}

resource "google_compute_instance_from_template" "maq-engdados4" {
  name = "worker"
  project = var.project_id
  zone = var.gcp_zone

  source_instance_template = google_compute_instance_template.template_sparkw.self_link
}

