# Docker

```bash
# preview configs
$ docker compose -f docker-compose.yml --env-file .env config

# build image, if none exists, and run container(s)
$ docker compose -f docker-compose.yml --env-file .env up -d

# stop container(s) and remove as well as dangling images 
$ docker compose down
```

access interactive shell of running container:
```bash
$ docker compose exec infra /bin/ash
```

clean out all including dangling images and containers
```bash 
$ docker system prune -af
```

AWS has a Docker container for running AWS CLI:
```bash
$ docker container run --rm -it -v ~/.aws:/root/.aws -e AWS_PROFILE=default amazon/aws-cli s3 ls
```

## .env

some necessary variables for your `.env` file:
```
ALPINE_VERSION = latest
TERRAFORM_VERSION = 0.13.7
TERRAGRUNT_VERSION = 0.25.5
PACKER_VERSION = 1.8.3
UID = 1000
GID = 1000
AWS_ACCESS_KEY_ID = <aws_access_key_id>
AWS_SECRET_ACCESS_KEY = <aws_secret_access_key>
AWS_PROFILE = default
AWS_REGION = us-gov-west-1
REMOTE_STATE_BUCKET = econsys-gov-security-infrastructure-test
REMOTE_STATE_PROFILE = econsys-gov-security-infrastructure-test
STATE_LOCK_DYNAMODB_TABLE = econsys-gov-security-infrastructure-test
```

# AWS

ensure container can run AWS CLI API calls:
```bash
~/infra-app $ aws sts get-caller-identity
```

# Packer

run Packer job:
```bash
~/infra-app $ packer build -var-file=infrastructure/packer/packer-vars-stage.json -var 'source_ami_rhel7_hvm=ami-04ccdf5793086ea95' -only 'minimal-rhel-7-hvm' infrastructure/packer/spel/minimal-linux.json
```