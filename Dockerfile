FROM jenkins/jenkins:2.277.4-lts-alpine
ARG docker_gid=1001
ENV MAVEN_REPO_PATH=/var/lib/maven/.m2
USER root
RUN apk add docker shadow
RUN groupmod -g $docker_gid docker
RUN usermod -aG docker jenkins
RUN mkdir -p $MAVEN_REPO_PATH
RUN chown -R jenkins:jenkins $MAVEN_REPO_PATH
USER jenkins
COPY config/security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy
COPY config/casc/* /usr/share/jenkins/ref/casc-configs/
COPY config/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Xms512m -Xmx2g"
ENV CASC_JENKINS_CONFIG="/usr/share/jenkins/ref/casc-configs"