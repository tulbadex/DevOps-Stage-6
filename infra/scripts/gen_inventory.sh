#!/usr/bin/env bash
set -e
IP="${1:-$(terraform -chdir=infra/terraform output -raw public_ip)}"
cat <<EOF
[app_servers]
$IP ansible_user=ubuntu ansible_ssh_private_key_file=../../../hng13-stage6-us-east-2.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR'
[app_servers:vars]
ansible_python_interpreter=/usr/bin/python3
domain=${DOMAIN}
email=${EMAIL}
duckdns_token=${DUCKDNS_TOKEN}
github_repo=${GITHUB_REPO}
github_branch=${GITHUB_BRANCH}
EOF