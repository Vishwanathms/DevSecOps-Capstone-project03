# Lab VM NFS Backup Playbook

This directory contains an Ansible playbook to verify that the NFS share is mounted on each lab VM and copy the full user profile into a VM-specific folder under the share.

## Files

- `backup_labvm.yml` - main playbook
- `inventory/hosts` - sample inventory for lab VMs
- `ansible.cfg` - local Ansible configuration
 - `inventory/group_vars/all.yml` - shared connection/sudo variables (placeholders — use Ansible Vault in production)

## Usage

1. Update `inventory/hosts` with your lab VM host entries.
2. Run the playbook with the NFS mount path:

```bash
cd B2.tf-vmw-guacamole-server/6.LabVM-data-Backup-ansi
ansible-playbook -i inventory/hosts backup_labvm.yml -e nfs_mount_point=/mnt/nfsshare
```

3. If the SSH user home directory is not `/home/student`, override `home_dir`:

```bash
ansible-playbook -i inventory/hosts backup_labvm.yml -e nfs_mount_point=/mnt/nfsshare -e home_dir=/home/labvm1
```

4. If your VMs use password authentication, add `--ask-pass` or set `ansible_password` in inventory.

## Behavior

- Checks that the configured `nfs_mount_point` is mounted on the lab VM
- Creates a destination folder named `stu<hostname>` under the share
- Copies the entire user home profile into that folder, including:
  - `Downloads`
  - `Documents`
  - `GNS3`
  - other files and folders stored in the profile
- The final destination path is:
  - `/mnt/nfsshare/stu<hostname>`
