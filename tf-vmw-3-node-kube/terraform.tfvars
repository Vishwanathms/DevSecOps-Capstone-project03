vsphere_user     = "administrator@vsphere.local"
vsphere_password = "VMware1!"
vsphere_server   = "vcenter.vishwacloudlab.in"

datacenter = "LAB-DC"
datastore  = "datastore1"
cluster    = "Lab-Cluster"
network    = "private-192"
template   = "ubuntu-temp01"

vm_name   = [ "Kube-master", "Kube-WN01", "Kube-WN02" ]
cpu       = 2
memory    = 4096
disk_size = 16

domain   = "lab.local"

vm_folder = "dev/kube"