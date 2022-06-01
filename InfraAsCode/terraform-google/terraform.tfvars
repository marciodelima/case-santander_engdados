project_id = "engdados-santander"
region     = "southamerica-east1"
gcp_zone   = "southamerica-east1-a"

engdados_serviceAccount = "engdados-user@engdados-santander.iam.gserviceaccount.com"

bucket_install = "engdados-santander-install"

iam_engdados_roles = {  
    role5 = "roles/container.admin"
    role7 = "roles/compute.admin" 
    role8 = "roles/logging.logWriter" 
    role9 = "roles/logging.bucketWriter" 
    role10 = "roles/monitoring.metricWriter"
    role11 = "roles/compute.storageAdmin" 
    role12 = "roles/storage.objectViewer"
}

projetct_apis_list = ["iam.googleapis.com", "iamcredentials.googleapis.com", "servicenetworking.googleapis.com", "compute.googleapis.com", "container.googleapis.com", "monitoring.googleapis.com", "cloudtrace.googleapis.com", "storage-component.googleapis.com"]

