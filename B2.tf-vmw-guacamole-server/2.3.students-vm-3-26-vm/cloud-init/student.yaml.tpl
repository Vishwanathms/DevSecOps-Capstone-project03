#cloud-config

hostname: ${vm_name}

package_update: true

packages:
  - ubuntu-desktop

users:
  - default
  - name: labuser
    groups: sudo,docker
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: $6$ANWnPSUVa7/XtMLX$FCAa8zyWEUeoeixHfdhdZdd6RznPqupgVsjav3B9vFC3BcBiot49k5hu6tgtqJ2s.RU7yoG2UUiYfGO.EbIJW/

ssh_pwauth: true

runcmd:
  - sudo mkdir -p /mnt/nfsshare/${vm_name}
  - sudo mkdir -p /home/student/workspace
  - sudo mount --bind /mnt/nfsshare/${vm_name} /home/student/workspace
  - echo "/mnt/nfsshare/${vm_name} /home/student/workspace none bind 0 0" >> /etc/fstab
  - sudo chown -R student:student /mnt/nfsshare/${vm_name}
  - sudo chown -R student:student /home/student/workspace
