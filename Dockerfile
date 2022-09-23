ARG ALPINE_VERSION

FROM alpine:${ALPINE_VERSION}

ENV APP=infra \
    APP_HOME=/opt  

ARG TERRAFORM_VERSION
ARG TERRAGRUNT_VERSION
ARG PACKER_VERSION
ARG UID
ARG GID

# install packages and dependencies
RUN apk update && apk upgrade --available && apk add --no-cache \
  curl python3 py3-pip aws-cli && \
  # terraform
  curl -sSLo /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  unzip /tmp/terraform.zip -d /usr/local/bin/ && \
  # terragrunt
  curl -sSLo /tmp/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 && \
  mv /tmp/terragrunt /usr/local/bin/terragrunt && \
  chmod +x /usr/local/bin/terragrunt && \
  # packer
  curl -sSLo /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
  unzip /tmp/packer.zip -d /usr/local/bin/ && \ 
  # clean up
  rm /tmp/*.zip && \
  # add non-root user, set non-root user shell and $HOME
  addgroup -g $GID -S $APP && \
  adduser -u $UID -S $APP -G $APP -s /bin/ash --home $APP_HOME -g "${APP} user"

# set container Working Directory and copy over local src files
WORKDIR ${APP_HOME}/${APP}-app
# recursively change app directory ownership to non-root user
COPY --chown=${APP}:${APP} ./ ${APP_HOME}/${APP}-app

# switch to non-root user
USER $APP
