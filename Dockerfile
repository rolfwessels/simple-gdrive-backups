FROM alpine:latest

# Base Development Packages
RUN apk update \
  && apk upgrade \
  && apk add ca-certificates wget && update-ca-certificates \
  && apk add --no-cache --update \
  git \
  curl \
  wget \
  bash \
  make \
  rsync \
  zip \
  nano 

# For the project
RUN git config --global --add safe.directory /simple-gdrive-backups

# Working Folder
WORKDIR /simple-gdrive-backups
ENV TERM xterm-256color
RUN printf 'export PS1="\[\e[0;34;0;33m\][DCKR]\[\e[0m\] \\t \[\e[40;38;5;28m\][\w]\[\e[0m\] \$ "' >> ~/.bashrc

