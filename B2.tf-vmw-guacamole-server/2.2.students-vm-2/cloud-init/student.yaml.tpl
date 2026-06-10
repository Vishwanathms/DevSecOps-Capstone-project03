#cloud-config

hostname: ${vm_name}

package_update: true

packages:
  - ubuntu-desktop
  - xrdp
  - openssh-server
  - docker.io
  - git
  - curl
  - nfs-common

users:
  - default
  - name: student
    groups: sudo,docker
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: $6$ANWnPSUVa7/XtMLX$FCAa8zyWEUeoeixHfdhdZdd6RznPqupgVsjav3B9vFC3BcBiot49k5hu6tgtqJ2s.RU7yoG2UUiYfGO.EbIJW/

ssh_pwauth: true

runcmd:
  - systemctl enable ssh
  - systemctl start ssh
  - systemctl enable xrdp
  - systemctl start xrdp
  - echo "student:Student@123" | chpasswd
  - mkdir -p /mnt/nfsshare
  - echo "192.168.1.99:/mnt/nfsshare /mnt/nfsshare nfs defaults,_netdev,nofail 0 0" >> /etc/fstab
  - mount -a
  - mkdir -p /mnt/nfsshare/${vm_name}
  - mkdir -p /home/student/workspace
  - mount --bind /mnt/nfsshare/${vm_name} /home/student/workspace
  - echo "/mnt/nfsshare/${vm_name} /home/student/workspace none bind 0 0" >> /etc/fstab
  - chown -R student:student /mnt/nfsshare/${vm_name}
  - chown -R student:student /home/student/workspace
