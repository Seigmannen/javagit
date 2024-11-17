# Use an Ubuntu base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/temurin-21-jdk

# Update and install dependencies (Java, Git, Gradle, OpenSSH)
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    git \
    gradle \
    openssh-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Eclipse Temurin JDK 21
RUN mkdir -p /usr/share/keyrings \
    && wget -q -O /usr/share/keyrings/adoptium.asc https://packages.adoptium.net/artifactory/api/gpg/key/public \
    && echo "deb [signed-by=/usr/share/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb focal main" | tee /etc/apt/sources.list.d/adoptium.list \
    && apt-get update && apt-get install -y temurin-21-jdk

# Set up SSH
RUN mkdir /var/run/sshd

# Allow root login with password
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Expose SSH port
EXPOSE 22

# Add Gradle to PATH
ENV PATH="$PATH:/usr/share/gradle/bin"

# Set working directory
WORKDIR /workspace

# Ensure JAVA_HOME is available in SSH sessions
RUN echo "JAVA_HOME=/usr/lib/jvm/temurin-21-jdk" >> /etc/environment

# Start SSH service
CMD ["/bin/bash", "-c", "echo root:${ROOT_PASSWORD} | chpasswd && /usr/sbin/sshd -D"]
