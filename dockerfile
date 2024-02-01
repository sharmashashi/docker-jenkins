FROM jenkins/jenkins:2.426.3-jdk17
USER root
RUN apt-get update && apt-get install -y lsb-release
# Install prerequisites
RUN apt-get update && apt-get install -y \
    git \
    xz-utils

# Set up Flutter environment variables
ENV FLUTTER_HOME=/Tools/flutter
RUN mkdir -p ${FLUTTER_HOME}

# Download and extract Flutter SDK
RUN curl -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.9-stable.tar.xz
RUN tar -xvf flutter.tar.xz -C ${FLUTTER_HOME} 
RUN rm flutter.tar.xz
ENV PATH=${FLUTTER_HOME}/flutter/bin:$PATH
# Run flutter doctor to initialize Flutter
RUN flutter doctor 

RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
