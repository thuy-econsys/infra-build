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

# AWS

ensure container can run AWS CLI API calls:
```bash
~/infra-app $ aws sts get-caller-identity
```

# Packer

run Packer job:
```bash
packer build -var-file=infrastructure/packer/packer-vars-stage.json -var 'source_ami_rhel7_hvm=ami-04ccdf5793086ea95' -only 'minimal-rhel-7-hvm' infrastructure/packer/spel/minimal-linux.json
```