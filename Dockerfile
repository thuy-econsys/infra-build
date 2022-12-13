ARG ALPINE_VERSION

FROM alpine:${ALPINE_VERSION} AS baseimage

ENV APP=infra \
    APP_HOME=/opt  

ARG TERRAFORM_VERSION
ARG TERRAGRUNT_VERSION
ARG PACKER_VERSION
ARG GLIBC_URL
ARG GLIBC_VERSION
ARG UID
ARG GID

# install packages and dependencies
RUN apk update && apk upgrade --available && apk add --no-cache \
  binutils make python3 py3-pip && \
  # terraform
  wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  unzip /tmp/terraform.zip -d /usr/local/bin/ && \
  # terragrunt
  wget -O /tmp/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 && \
  mv /tmp/terragrunt /usr/local/bin/terragrunt && \
  chmod +x /usr/local/bin/terragrunt && \
  # packer
  wget -O /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
  unzip /tmp/packer.zip -d /usr/local/bin/ && \
  # create non-root user, and assign shell and home directory for non-root user
  addgroup -g $GID -S $APP && \
  adduser -u $UID -S $APP -G $APP -s /bin/ash --home $APP_HOME -g "${APP} user"

FROM baseimage

RUN \  
  # GNU C Library compatibility package for Alpine's MUSL libc
  wget -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
  wget -O /tmp/glibc-${GLIBC_VERSION}.apk ${GLIBC_URL}/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
  wget -O /tmp/glibc-bin-${GLIBC_VERSION}.apk ${GLIBC_URL}/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
  wget -O /tmp/glibc-i18n-${GLIBC_VERSION}.apk ${GLIBC_URL}/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk && \
  apk add --no-cache --force-overwrite /tmp/glibc-*.apk && \
  /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 && \
  ln -sf /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2 && \
  # install AWS CLI V2
  wget -O awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip && \
  unzip awscliv2.zip && \
  ./aws/install

# based on hardened alpine base image https://github.com/ironpeakservices/iron-alpine/blob/master/Dockerfile
RUN rm -fr \
    ./awscliv2.zip \
    ./aws \
    /usr/local/aws-cli/v2/*/dist/aws_completer \
    /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
    /usr/local/aws-cli/v2/*/dist/awscli/examples \
    /var/cache/apk/* \
    /tmp/* && \
  apk del --no-cache binutils

# set container Working Directory and copy over local src files
WORKDIR ${APP_HOME}/${APP}-app
# recursively change app directory ownership to non-root user
COPY --chown=${APP}:${APP} ./ ${APP_HOME}/${APP}-app

# switch to non-root user
USER $APP
