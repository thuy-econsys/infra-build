ARG ALPINE_VERSION=latest

FROM alpine:${ALPINE_VERSION} as BuildImage

ENV APP=infra \
    APP_HOME=/opt \
    TERRAFORM_VERSION=0.13.7 \
    TERRAGRUNT_VERSION=0.25.5 \
    PACKER_VERSION=1.8.3 \
    UID=1000 \
    GID=1000

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
  rm /tmp/*.zip && \
  addgroup -g $GID -S $APP && \
  adduser -u $UID -S $APP -G $APP -s /bin/ash --home $APP_HOME


# set container Working Directory and copy over local src files
WORKDIR ${APP_HOME}/${APP}-app

# RUN addgroup -g $GID -S $APP && \
#     adduser -u $UID -S $APP -G $APP -s /bin/ash --home $APP_HOME && \
#     apk add --no-cache sudo && \
#     echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel
    # echo '${APP} ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    # adduser $APP wheel

COPY --chown=${APP}:${APP} ./ ${APP_HOME}/${APP}-app

USER $APP

EXPOSE 3001
