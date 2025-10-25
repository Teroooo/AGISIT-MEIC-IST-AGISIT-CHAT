# Use the official Ubuntu base image
FROM ubuntu:latest

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

ENV ANSIBLE_CONFIG=/root/lab2/ansible/ansible.cfg

# Update package lists and install ansible
RUN apt-get update && \
    apt install -y software-properties-common && \
    apt-add-repository -y -u ppa:ansible/ansible && \
    apt-get update && \
    apt-get install -y ansible

# Install facilities
RUN apt-get install -y supervisor openssh-server iputils-ping

# Create directories for supervisor and sshd
RUN mkdir -p /var/run/sshd /var/log/supervisor

# Copy supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Clean cache packages
RUN apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# Adding our new-ly generated key to authorized keys
ADD ssh-keys/id_rsa.pub /root/.ssh/authorized_keys

# Set working directory
WORKDIR /root

# Supervisor is our "init". Launches ssh and waits forever.
CMD ["/usr/bin/supervisord"]
