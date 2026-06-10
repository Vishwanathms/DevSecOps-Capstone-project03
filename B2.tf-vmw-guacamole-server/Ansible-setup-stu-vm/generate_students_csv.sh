#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
ipfile="${script_dir}/ipfile"
output_file="${script_dir}/csv/students.csv"

if [[ $# -ge 1 ]]; then
  ipfile="$1"
fi

if [[ ! -f "$ipfile" ]]; then
  echo "Error: ipfile not found: $ipfile" >&2
  exit 1
fi

mapfile -t ips < <(grep -Eo '^[^#][^[:space:]]*' "$ipfile" | tr -d '\r')

if [[ ${#ips[@]} -lt 26 ]]; then
  echo "Error: ipfile must contain at least 26 IP addresses. Found ${#ips[@]}." >&2
  exit 1
fi

cat > "$output_file" <<'EOF'
batch_id,student_id,student_name,email,vm_name,vm_ip,os_type,os_user,os_password
EOF

for i in $(seq 1 26); do
  student_id=$(printf "%03d" "$i")
  student_name="Student${i}"
  email="Student${i}@test.com"
  vm_name="stuvm-${student_id}"
  vm_ip="${ips[$((i - 1))]}"
  echo "DEVOPS-JUL26,${student_id},${student_name},${email},${vm_name},${vm_ip},ubuntu,student,Student@123" >> "$output_file"
done

echo "Generated ${output_file} with 26 student entries using IPs from ${ipfile}."
