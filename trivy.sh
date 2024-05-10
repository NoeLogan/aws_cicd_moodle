#!/bin/bash
#trivy - Container Image Security Scanner 

RELEASE_VERSION=$(grep -Po '(?<=VERSION_ID=")[0-9]' /etc/os-release)
cat << EOF | sudo tee -a /etc/yum.repos.d/trivy.repo
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/$RELEASE_VERSION/\$basearch/
gpgcheck=0
enabled=1
EOF

sudo yum update -y

sudo yum install trivy -y

mv /usr/local/bin/trivy /usr/bin/trivy 

