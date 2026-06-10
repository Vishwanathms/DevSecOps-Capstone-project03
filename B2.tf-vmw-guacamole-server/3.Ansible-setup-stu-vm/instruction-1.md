For a scalable training institute solution, I would structure it like this:

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
│       │   ├── main.yml
│       │   ├── login.yml
│       │   ├── create_student.yml
│       │   ├── create_rdp.yml
│       │   ├── create_ssh.yml
│       │   ├── assign_permissions.yml
│       │   ├── disable_student.yml
│       │   ├── delete_student.yml
│       │   └── export_credentials.yml
│       │
│       ├── templates/
│       │   ├── rdp_connection.json.j2
│       │   ├── ssh_connection.json.j2
│       │   └── user.json.j2
│       │
│       └── vars/
│           └── main.yml
│
└── reports/
```

---

# inventory/localhost.yml

```yaml
all:
  hosts:
    localhost:
      ansible_connection: local
```

---

# csv/batches.csv

```csv
batch_id,course_name,start_date,end_date,instructor,status
DEVOPS-JUL26,AWS-DEVOPS,2026-07-01,2026-08-30,Vishwanath,ACTIVE
AZURE-AUG26,AZURE-DEVOPS,2026-08-01,2026-09-30,Vishwanath,ACTIVE
```

---

# csv/students.csv

```csv
batch_id,student_id,student_name,email,vm_name,vm_ip,os_type,os_user,os_password
DEVOPS-JUL26,001,John,john@test.com,ubuntu-devops-001,10.0.1.10,ubuntu,student,Student@123
DEVOPS-JUL26,002,Mary,mary@test.com,ubuntu-devops-002,10.0.1.11,ubuntu,student,Student@123
DEVOPS-JUL26,003,Alex,alex@test.com,ubuntu-devops-003,10.0.1.12,ubuntu,student,Student@123
```

---

# roles/guacamole/vars/main.yml

```yaml
guac_url: "http://localhost:8080/guacamole"

guac_admin_user: "guacadmin"
guac_admin_password: "guacadmin"

datasource: "mysql"

students_csv: "../csv/students.csv"
batches_csv: "../csv/batches.csv"

report_dir: "../reports"
```

---

# playbooks/create_students.yml

```yaml
---
- name: Create Student Access
  hosts: localhost
  gather_facts: false

  vars:
    action: create

  roles:
    - guacamole
```

Run:

```bash
ansible-playbook playbooks/create_students.yml \
-e batch_id=DEVOPS-JUL26
```

---

# playbooks/disable_students.yml

```yaml
---
- name: Disable Student Access
  hosts: localhost
  gather_facts: false

  vars:
    action: disable

  roles:
    - guacamole
```

Run:

```bash
ansible-playbook playbooks/disable_students.yml \
-e batch_id=DEVOPS-JUL26
```

---

# playbooks/delete_students.yml

```yaml
---
- name: Delete Student Access
  hosts: localhost
  gather_facts: false

  vars:
    action: delete

  roles:
    - guacamole
```

Run:

```bash
ansible-playbook playbooks/delete_students.yml \
-e batch_id=DEVOPS-JUL26
```

---

# roles/guacamole/tasks/main.yml

```yaml
---
- name: Read Students CSV
  community.general.read_csv:
    path: "{{ students_csv }}"
  register: students

- name: Login
  include_tasks: login.yml

- name: Filter Batch
  set_fact:
    selected_students: >-
      {{
        students.list
        | selectattr('batch_id','equalto',batch_id)
        | list
      }}

- name: Create Students
  include_tasks: create_student.yml
  loop: "{{ selected_students }}"
  loop_control:
    loop_var: student
  when: action == "create"

- name: Disable Students
  include_tasks: disable_student.yml
  loop: "{{ selected_students }}"
  loop_control:
    loop_var: student
  when: action == "disable"

- name: Delete Students
  include_tasks: delete_student.yml
  loop: "{{ selected_students }}"
  loop_control:
    loop_var: student
  when: action == "delete"
```

---

# roles/guacamole/tasks/login.yml

```yaml
---
- name: Login to Guacamole
  uri:
    url: "{{ guac_url }}/api/tokens"
    method: POST
    body_format: form-urlencoded
    body:
      username: "{{ guac_admin_user }}"
      password: "{{ guac_admin_password }}"
  register: login

- set_fact:
    token: "{{ login.json.authToken }}"
```

---

# roles/guacamole/tasks/create_student.yml

```yaml
---
- name: Build Username
  set_fact:
    guac_user: "{{ student.batch_id }}-{{ student.student_id }}"

- name: Generate Password
  set_fact:
    guac_password: "{{ lookup('password', '/dev/null chars=ascii_letters,digits length=12') }}"

- name: Create User
  uri:
    url: "{{ guac_url }}/api/session/data/{{ datasource }}/users?token={{ token }}"
    method: POST
    body_format: json
    src: "{{ role_path }}/templates/user.json.j2"

- include_tasks: create_rdp.yml

- include_tasks: create_ssh.yml

- include_tasks: export_credentials.yml
```

---

# roles/guacamole/tasks/create_rdp.yml

```yaml
---
- name: Render RDP JSON
  template:
    src: rdp_connection.json.j2
    dest: /tmp/{{ guac_user }}-rdp.json

- name: Create RDP Connection
  uri:
    url: "{{ guac_url }}/api/session/data/{{ datasource }}/connections?token={{ token }}"
    method: POST
    body_format: json
    src: "/tmp/{{ guac_user }}-rdp.json"
  register: rdp_connection

- set_fact:
    rdp_id: "{{ rdp_connection.json.identifier }}"
```

---

# roles/guacamole/tasks/create_ssh.yml

```yaml
---
- name: Render SSH JSON
  template:
    src: ssh_connection.json.j2
    dest: /tmp/{{ guac_user }}-ssh.json

- name: Create SSH Connection
  uri:
    url: "{{ guac_url }}/api/session/data/{{ datasource }}/connections?token={{ token }}"
    method: POST
    body_format: json
    src: "/tmp/{{ guac_user }}-ssh.json"
  register: ssh_connection

- set_fact:
    ssh_id: "{{ ssh_connection.json.identifier }}"

- include_tasks: assign_permissions.yml
  vars:
    connection_id: "{{ rdp_id }}"

- include_tasks: assign_permissions.yml
  vars:
    connection_id: "{{ ssh_id }}"
```

---

# roles/guacamole/tasks/assign_permissions.yml

```yaml
---
- name: Grant Permission
  uri:
    url: "{{ guac_url }}/api/session/data/{{ datasource }}/users/{{ guac_user }}/permissions?token={{ token }}"
    method: PATCH
    body_format: json
    body:
      - op: add
        path: "/connectionPermissions/{{ connection_id }}"
        value: READ
```

---

# roles/guacamole/tasks/disable_student.yml

```yaml
---
- name: Build Username
  set_fact:
    guac_user: "{{ student.batch_id }}-{{ student.student_id }}"

- name: Disable User
  uri:
    url: "{{ guac_url }}/api/session/data/{{ datasource }}/users/{{ guac_user }}?token={{ token }}"
    method: PUT
    body_format: json
    body:
      username: "{{ guac_user }}"
      attributes:
        disabled: "true"
```

---

# roles/guacamole/tasks/delete_student.yml

```yaml
---
- name: Build Username
  set_fact:
    guac_user: "{{ student.batch_id }}-{{ student.student_id }}"

- name: Delete User
  uri:
    url: "{{ guac_url }}/api/session/data/{{ datasource }}/users/{{ guac_user }}?token={{ token }}"
    method: DELETE
```

---

# roles/guacamole/tasks/export_credentials.yml

```yaml
---
- name: Create Report Directory
  file:
    path: "{{ report_dir }}"
    state: directory

- name: Save Credentials
  lineinfile:
    path: "{{ report_dir }}/{{ batch_id }}.csv"
    create: true
    line: "{{ guac_user }},{{ guac_password }},{{ student.vm_ip }}"
```

---

# roles/guacamole/templates/user.json.j2

```json
{
  "username": "{{ guac_user }}",
  "password": "{{ guac_password }}"
}
```

---

# roles/guacamole/templates/rdp_connection.json.j2

```json
{
  "parentIdentifier": "ROOT",
  "name": "Lab Desktop",
  "protocol": "rdp",
  "parameters": {
    "hostname": "{{ student.vm_ip }}",
    "port": "3389",
    "username": "{{ student.os_user }}",
    "password": "{{ student.os_password }}",
    "security": "any",
    "resize-method": "display-update",
    "enable-drive": "true",
    "drive-name": "TrainingFiles",
    "create-drive-path": "true",
    "disable-copy": "false",
    "disable-paste": "false",
    "enable-wallpaper": "false",
    "enable-theming": "false",
    "enable-font-smoothing": "false"
  }
}
```

---

# roles/guacamole/templates/ssh_connection.json.j2

```json
{
  "parentIdentifier": "ROOT",
  "name": "Lab Terminal",
  "protocol": "ssh",
  "parameters": {
    "hostname": "{{ student.vm_ip }}",
    "port": "22",
    "username": "{{ student.os_user }}",
    "password": "{{ student.os_password }}"
  }
}
```

### Operations Supported

```bash
# Create complete batch
ansible-playbook playbooks/create_students.yml -e batch_id=DEVOPS-JUL26

# Disable complete batch
ansible-playbook playbooks/disable_students.yml -e batch_id=DEVOPS-JUL26

# Delete complete batch
ansible-playbook playbooks/delete_students.yml -e batch_id=DEVOPS-JUL26
```

This structure keeps batch management, student provisioning, reporting, SSH access, RDP access, and future AWS/Azure/Kubernetes lab expansion separated and maintainable.
