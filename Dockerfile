FROM jenkins/slave:3.19-1 AS builder
MAINTAINER Rio Fujita <rifujita@microsoft.com>

USER root

COPY jenkins-slave /usr/local/bin/jenkins-slave
RUN chmod 755 /usr/local/bin/jenkins-slave

# Working directory where repo runs in
ENV WORKING_DIRECTORY="/usr/local/aosp/master/"

# Gerrit master server
ENV GERRIT_MASTER="172.16.0.4" \
  GERRIT_USER="root" \
  GERRIT_DIR="/media/repo/aosp/mirror"

# Mitigating amount of files to be synced
ENV REPO_GROUP="default,-arm,-mips,-darwin"

# Avoiding Debian Frontend errors
ENV DEBIAN_FRONTEND noninteractive

# /bin/sh points to Dash by default, reconfigure to use bash until Android build becomes POSIX compliant
RUN \
  echo "dash dash/sh boolean false" | debconf-set-selections && \
  dpkg-reconfigure -p critical dash

# Installing Repo
# See the section, https://source.android.com/setup/build/downloading#installing-repo
RUN \
  mkdir ~/bin && \
  curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo && \
  chmod a+x ~/bin/repo
ENV PATH=~/bin:$PATH

# Initializing a Repo client to use a local mirror
# See the section, https://source.android.com/setup/build/downloading#initializing-a-repo-client and
# https://source.android.com/setup/build/downloading#using-a-local-mirror
COPY gitconfig /root/.gitconfig

# Using Authentication
# See the section, https://source.android.com/setup/build/downloading#using-authentication
# THIS WORKAROUND IS AGAINST ABOVE. DIRTY HACK.
RUN \
  mkdir /root/.ssh && \
  chmod 700 /root/.ssh && \
  echo -e "Host *"                            > /root/.ssh/config && \
  echo -e "  User $GERRIT_USER"              >> /root/.ssh/config && \
  echo -e "  IdentityFile /root/.ssh/id_rsa" >> /root/.ssh/config && \
  echo -e "  StrictHostKeyChecking no"       >> /root/.ssh/config
COPY id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa

ARG BASEBRANCH
ARG TGTBRANCH
RUN echo $BASEBRANCH
FROM $BASEBRANCH

RUN \
  mkdir -p $WORKING_DIRECTORY && \
  cd $WORKING_DIRECTORY && \
  repo init -u ssh://$GERRIT_MASTER$GERRIT_DIR/platform/manifest.git -g $REPO_GROUP -b $TGTBRANCH --depth 1
RUN \
  cd $WORKING_DIRECTORY && \
  cpus=$(grep ^processor /proc/cpuinfo | wc -l) && \
  repo sync -j $cpus

RUN \
  rm -f /root/.ssh/id_rsa

# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME ["/tmp/ccache", "/aosp"]

ENTRYPOINT ["jenkins-slave"]
