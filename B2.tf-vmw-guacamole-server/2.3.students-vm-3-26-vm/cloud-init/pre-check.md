## run the below before templating the vm on vmware 

```
sudo cloud-init clean --logs

sudo truncate -s 0 /etc/machine-id

sudo rm -f /var/lib/dbus/machine-id

sudo rm -rf /var/lib/cloud/*
```