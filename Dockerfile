FROM ubuntu:18.04

LABEL maintainer="Clement Wong <kenshi08@gmail.com>"

# Make sure the package repository is up to date.
RUN apt-get update -qq && apt-get -qy full-upgrade && apt-get install -qqy git  
# Install a basic SSH server
RUN apt-get install -qqy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd
# Install JDK 8 (latest stable edition at 2019-04-01) and Docker stuff
RUN apt-get install -qqy openjdk-8-jdk \ 
    maven \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables

# Install Docker from Docker Inc. repositories.
RUN curl -sSL https://get.docker.com/ | sh

# Install the magic wrapper.
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Cleanup old packages
RUN apt-get -qqy autoremove

# Add user jenkins to the image
RUN adduser --quiet jenkins

# Set password for the jenkins user (you may want to alter this).
RUN echo 'jenkins:jenkins' | chpasswd && mkdir /home/jenkins/.m2

# add user to docker/sudo group
RUN usermod -aG docker jenkins

# Standard SSH port
EXPOSE 22

# Define additional metadata for our image.
VOLUME /var/lib/docker

CMD ["/usr/sbin/sshd", "-D", "wrapdocker"]