For a training institute, I would design the CSV and Ansible solution to support:

* Multiple batches
* Multiple courses
* SSH and RDP access
* Dedicated VM per student
* Future expansion to Windows/Linux VMs
* Bulk provisioning (100–500 students)

---

# Directory Structure

```text
training-lab/
├── inventory/
│   └── localhost.yml
│
├── csv/
│   ├── students.csv
│   └── batches.csv
│
├── playbooks/
│   ├── create_students.yml
│   ├── disable_students.yml
│   └── delete_students.yml
│
├── roles/
│   └── guacamole/
│       ├── tasks/
│       ├── templates/
│       └── vars/
│
└── reports/
```

---

# Scalable Student CSV

Instead of only storing VM IPs, store everything required for provisioning.

## students.csv

```csv
batch_id,student_id,student_name,email,vm_name,vm_ip,os_type,os_user,os_password
DEVOPS-JUL26,001,John,john@test.com,ubuntu-devops-001,10.0.1.10,ubuntu,student,Student@123
DEVOPS-JUL26,002,Mary,mary@test.com,ubuntu-devops-002,10.0.1.11,ubuntu,student,Student@123
DEVOPS-JUL26,003,Alex,alex@test.com,ubuntu-devops-003,10.0.1.12,ubuntu,student,Student@123
```

---

# Batch Metadata CSV

## batches.csv

```csv
batch_id,course_name,start_date,end_date,instructor
DEVOPS-JUL26,AWS-DEVOPS,2026-07-01,2026-08-30,Vishwanath
AZURE-AUG26,AZURE-DEVOPS,2026-08-01,2026-09-30,Vishwanath
```

This allows future automation:

```bash
ansible-playbook create_students.yml \
-e batch_id=DEVOPS-JUL26
```

---

# Generated Naming Convention

For:

```text
batch_id=DEVOPS-JUL26
student_id=001
```

Generate:

```text
Guacamole User:
DEVOPS-JUL26-001

Connections:
Lab Desktop
Lab Terminal
```

Student sees:

```text
Lab Desktop
Lab Terminal
```

Admin sees:

```text
DEVOPS-JUL26-001
DEVOPS-JUL26-001-RDP
DEVOPS-JUL26-001-SSH
```

---

# Ansible Playbook

## Read CSV

```yaml
---
- hosts: localhost
  gather_facts: false

  vars:
    csv_file: csv/students.csv

  tasks:

    - name: Read student CSV
      community.general.read_csv:
        path: "{{ csv_file }}"
      register: students
```

---

## Filter Specific Batch

```yaml
    - name: Select Batch
      set_fact:
        selected_students: >-
          {{
            students.list
            | selectattr('batch_id','equalto',batch_id)
            | list
          }}
```

Run:

```bash
ansible-playbook create_students.yml \
-e batch_id=DEVOPS-JUL26
```

---

## Create Student User

```yaml
    - name: Create Student
      include_tasks: create_student.yml
      loop: "{{ selected_students }}"
      loop_control:
        loop_var: student
```

---

# create_student.yml

## Generate Guacamole Username

```yaml
- name: Username
  set_fact:
    guac_user: "{{ student.batch_id }}-{{ student.student_id }}"
```

Result:

```text
DEVOPS-JUL26-001
```

---

## Generate Random Password

```yaml
- name: Password
  set_fact:
    guac_password: "{{ lookup('password', '/dev/null length=12') }}"
```

---

## Create RDP Connection

```yaml
- name: Create RDP Connection
  uri:
    url: "{{ guac_url }}/api/session/data/mysql/connections?token={{ token }}"
    method: POST
    body_format: json
    body:

      parentIdentifier: ROOT

      name: "{{ guac_user }}-RDP"

      protocol: rdp

      parameters:
        hostname: "{{ student.vm_ip }}"
        port: "3389"
        username: "{{ student.os_user }}"
        password: "{{ student.os_password }}"

        resize-method: display-update
        enable-drive: true
        drive-name: TrainingFiles
        create-drive-path: true

        disable-copy: false
        disable-paste: false
```

---

## Create SSH Connection

```yaml
- name: Create SSH Connection
  uri:
    url: "{{ guac_url }}/api/session/data/mysql/connections?token={{ token }}"
    method: POST
    body_format: json
    body:

      parentIdentifier: ROOT

      name: "{{ guac_user }}-SSH"

      protocol: ssh

      parameters:
        hostname: "{{ student.vm_ip }}"
        port: "22"
        username: "{{ student.os_user }}"
        password: "{{ student.os_password }}"
```

---

# Credential Export

```yaml
- name: Export Credentials
  lineinfile:
    path: reports/{{ batch_id }}.csv
    create: yes
    line: >-
      {{ guac_user }},
      {{ guac_password }},
      {{ student.vm_ip }}
```

Output:

```csv
guac_user,password,vm_ip
DEVOPS-JUL26-001,T4v@9kLmP1Qx,10.0.1.10
DEVOPS-JUL26-002,R7m#2JsKq8Wp,10.0.1.11
DEVOPS-JUL26-003,X5n@3TdLp7Rs,10.0.1.12
```

---

# Bulk Operations

### Disable Entire Batch

```bash
ansible-playbook disable_students.yml \
-e batch_id=DEVOPS-JUL26
```

### Delete Entire Batch

```bash
ansible-playbook delete_students.yml \
-e batch_id=DEVOPS-JUL26
```

### Password Reset

```bash
ansible-playbook reset_passwords.yml \
-e batch_id=DEVOPS-JUL26
```

---

# Enterprise-Scale CSV

For future growth, I recommend this structure:

```csv
batch_id,student_id,student_name,email,vm_name,vm_ip,os_type,os_user,os_password,course_name,instructor,status
DEVOPS-JUL26,001,John,john@test.com,ubuntu-devops-001,10.0.1.10,ubuntu,student,Student@123,AWS-DEVOPS,Vishwanath,ACTIVE
```

This supports:

* AWS batches
* Azure batches
* Kubernetes batches
* Linux administration batches
* Windows administration batches

all from the same automation framework.
